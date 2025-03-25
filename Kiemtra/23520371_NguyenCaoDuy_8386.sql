-- Câu 1: --
CREATE DATABASE THUCHANH
GO
-----------------------------------------------------
-----------------------------------------------------
USE THUCHANH
GO
---------------------------------------------
-- SACH
CREATE TABLE SACH(
	MaSach	char(5) not null,	
	TenSach	Nvarchar(100),
	TheLoai Nvarchar(30),
	DonGia money,
	SoLuong int,
	constraint pk_sach primary key(MaSach)
)

-- TACGIA
CREATE TABLE TACGIA(
	MaTG	  char(5) not null,	
	HoTen	  nvarchar(100),
	QuocTich  nvarchar(30),
	NgaySinh  smalldatetime,
	DienThoai varchar(15)
	constraint pk_tg primary key(MaTG)
)

-- TACGIA_SACH
CREATE TABLE TACGIA_SACH(
	MaTG   char(5) not null,	
	MaSach char(5) not null,
	constraint pk_tgs primary key(MaTG, MaSach)
)

-- DOCGIA
CREATE TABLE DOCGIA(
	MaDG	  char(5) not null,	
	TenDG	  nvarchar(50),
	DiaChi    nvarchar(50),
	NgaySinh  smalldatetime,
	DienThoai varchar(15),
	NgDK      smalldatetime,
	constraint pk_dg primary key(MaDG)
)

-- PHATHANH
CREATE TABLE PHATHANH(
	MaPH	char(5) not null,	
	MaSach	char(5),
	NgayPH  smalldatetime,
	SoLuong int,
	NXB     nvarchar(100),
	LanPhatHanh int,
	constraint pk_ph primary key(MaPH)
)

-- MUONSACH
CREATE TABLE MUONSACH(
	MaMuon   char(5) not null,
	MaDG	 char(5) not null,
	MaSach	 char(5),
	NgayMuon smalldatetime,
	NgayTra  smalldatetime,
	TrangThai nvarchar(20),
	constraint pk_ms primary key(MaMuon)
)

-- Khoa ngoai cho bang TACGIA_SACH
ALTER TABLE TACGIA_SACH ADD CONSTRAINT fk01_tgs FOREIGN KEY(MaTG) REFERENCES TACGIA(MaTG)
ALTER TABLE TACGIA_SACH ADD CONSTRAINT fk02_tgs FOREIGN KEY(MaSach) REFERENCES SACH(MaSach)

-- Khoa ngoai cho bang SACH
ALTER TABLE SACH ADD CONSTRAINT fk01_sach FOREIGN KEY(MaSach) REFERENCES TACGIA_SACH(MaSach)

-- Khoa ngoai cho bang TACGIA
ALTER TABLE TACGIA ADD CONSTRAINT fk01_tg FOREIGN KEY(MaTG) REFERENCES TACGIA_SACH(MaTG)

-----------------------------------------------------
-----------------------------------------------------
set dateformat dmy


-- Câu 2: --
CREATE TRIGGER trg_checkNgayPH_phathanh
ON phathanh
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MaPH char(5), @NgayPH smalldatetime, @NgaySinh_tg smalldatetime
	select @MaPH = i.MaPH, @NgayPH = i.NgayPH
	from inserted i

	select @NgaySinh_tg = NgaySinh
	from TACGIA tg join TACGIA_SACH tgs on tg.MaTG = tgs.MaTG
					join PHATHANH ph on ph.MaSach = tgs.MaSach
	where MaPH = @MaPH

	if @NgayPH < @NgaySinh_tg
	begin
		raiserror('Ngay phat hanh phai lon hon ngay sinh cua tac gia', 16, 1)
		rollback
	end
	else
	begin
		print 'Cap nhat thanh cong'
	end
END

-- Cau 3: --
CREATE TRIGGER trg_checkSL_phathanh
ON phathanh
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MaPH char(5), @SoLuong int
	select @MaPH = i.MaPH, @SoLuong = i.SoLuong
	from inserted i

	if @SoLuong < 500
	begin
		raiserror('So luong phai tu 500 quyen tro len', 16, 1)
		rollback
	end
	else
	begin
		print 'Cap nhat thanh cong'
	end
END

-- Cau 4: --
select dg.MaDG, TenDG
from MUONSACH ms join DOCGIA dg on dg.MaDG = ms.MaDG
where NgayMuon = '10/12/2024';

-- Cau 5: --
select tg.MaTG, HoTen
from TACGIA tg join TACGIA_SACH tgs on tgs.MaTG = tg.MaTG
				join SACH s on s.MaSach = tgs.MaSach
				join PHATHANH ph on ph.MASACH = tgs.MaSach
where TenSach = 'Cấu trúc rời rạc' and NXB = 'DHQG-TPHCM';

-- Cau 6: --
select tg.MaTG, HoTen, sum(SoLuong) as sl
from TACGIA tg join TACGIA_SACH tgs on tg.MaTG = tgs.MaTG
				join PHATHANH ph on ph.MaSach = tgs.MaSach
where year(NgayPH) = 2024
group by tg.MaTG, HoTen
order by sl DESC;

-- Cau 7: --
select MaDG
from MUONSACH ms join SACH s on s.MaSach = ms.MaSach
where year(NgayMuon) = 2024
group by MaDG
having count(distinct TheLoai) > 3;

--Cau 8: --
select NXB
from PHATHANH ph join SACH s ON ph.MaSach = s.MaSach
				LEFT join MUONSACH ms ON s.MaSach = ms.MaSach
group by NXB
having count(distinct s.TheLoai) = 5 AND count(ms.MaSach) = 0;


--Cau 9: --
select dg.MaDG, TenDG
from DOCGIA dg join MUONSACH ms on dg.MaDG = ms.MaDG
				join SACH s on s.MaSach = ms.MaSach
where TheLoai = 'Khoa học viễn tưởng' and TheLoai = 'Kinh tế' and year(NgayMuon) = 2024
group by dg.MaDG, TenDG
having count(dg.MaDG) = (select count(*)
								from SACH
								where TheLoai = 'Khoa học viễn tưởng' and TheLoai = 'Kinh tế');