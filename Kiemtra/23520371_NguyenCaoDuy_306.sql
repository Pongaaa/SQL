--Cau 1
create database QLKB
use QLKB
set dateformat ymd
create table BENHNHAN(
	MaBN char(5),
	HoTenBN nvarchar(50),
	NgaySinh smalldatetime,
	CCCD nvarchar(12),
	SoBHYT nvarchar(15),
	BHYTChiTra float,
	DiaChi nvarchar(15),
	constraint pk_bn primary key(MaBN)
)

create table BACSI(
	MaBS char(5),
	HoTenBS nvarchar(50),
	NgayBDLV smalldatetime,
	ChuyenKhoa nvarchar(50),
	constraint pk_bs primary key(MaBS)
)

create table KHAMBENH(
	MaKB char(5),
	MaBN char(5),
	MaBS char(5),
	NgayKham smalldatetime,
	TrieuChung nvarchar(255),
	KetLuan nvarchar(255),
	TaiKham int,
	constraint pk_kb primary key(MaKB)
)

create table THUOC(
	MaThuoc char(5),
	TenThuoc nvarchar(50),
	LoaiThuoc nvarchar(50),
	DVT nvarchar(20),
	DonGia money,
	constraint pk_thuoc primary key(MaThuoc),
)

create table DONTHUOC(
	MaDT char(5),
	MaKB char(5),
	TriGiaDT money,
	BHYTChiTra float,
	NgayCapThuoc smalldatetime,
	TongTienTT money,
	TinhTrangDT nvarchar(30),
	constraint pk_dt primary key(MaDT),
)

create table CHITIETDT(
	MaDT char(5),
	MaThuoc char(5),
	SoLuong int,
	ThanhTien money,
	constraint pk_ct primary key(MaDT, MaThuoc)
)

alter table CHITIETDT add constraint fk_ct01 foreign key(MaDT) references DONTHUOC(MaDT)
alter table CHITIETDT add constraint fk_ct02 foreign key(MaThuoc) references THUOC(MaThuoc)

alter table DONTHUOC add constraint fk_dt01 foreign key(MaKB) references KHAMBENH(MaKB)

alter table KHAMBENH add constraint fk_kb01 foreign key(MaBN) references BENHNHAN(MaBN)
alter table KHAMBENH add constraint fk_kb02 foreign key(MaBS) references BACSI(MaBS)

--Cau 2:
--2.1
alter table KHAMBENH add constraint chk_tk check(TaiKham between 0 and 365)
--2.2
alter table THUOC add constraint chk_dvt check(DVT in('vien', 'hop', 'lo', 'vi'))
--2.3
create trigger trg_del_chititdt
on CHITIETDT
after delete
as
begin
	declare @TriGiaDT money, @ThanhTien money

	select @ThanhTien = d.ThanhTien
	from deleted d join DONTHUOC dt on dt.MADT = d.MaDT

	set @TriGiaDT = (select sum(@ThanhTien)
					from CHITIETDT ct join deleted d on ct.MADT = d.MaDT)
	update DONTHUOC
	set TriGiaDT = @TriGiaDT
end

--Cau 3:
--3.1
select bn.MaBN, HoTenBN, MaDT, TongTienTT
from BENHNHAN bn join KHAMBENH kb on kb.MaBN = bn.MaBN
				join DONTHUOC dt on dt.MaKB = kb.MaKB
where DiaChi = 'Tp.HCM' and year(NgayCapThuoc) = 2024

--3.2
select bn.MaBN, HoTenBN
from BENHNHAN bn join KHAMBENH kb on kb.MaBN = bn.MaBN
				join BACSI bs on bs.MaBS = kb.MABS
where ChuyenKhoa = 'Noi khoa' and BHYTChiTra >= 0.1
intersect
select bn.MaBN, HoTenBN
from BENHNHAN bn join KHAMBENH kb on kb.MaBN = bn.MaBN
				join BACSI bs on bs.MaBS = kb.MABS
where ChuyenKhoa = 'Tai mui hong' and BHYTChiTra >= 0.1

--3.3
select t.MaThuoc, t.TenThuoc
from CHITIETDT ct join THUOC t on t.MaThuoc = ct.MaThuoc
					join DONTHUOC dt on dt.MADT = ct.MaDT
where LoaiThuoc = 'Thuoc giam dau' and NgayCapThuoc = '2024/12/01' and TinhTrangDT = 'Da thanh toan'
group by t.MaThuoc, TenThuoc
having count(t.MaThuoc) = (select count(t.MaThuoc)
					from THUOC t
					where LoaiThuoc = 'Thuoc giam dau')

--3.4
select bs.MaBS, HoTenBS, count(bn.MaBN) as SoLuot
from BACSI bs join KHAMBENH kb on kb.MaBS = bs.MaBS
				join BENHNHAN bn on bn.MaBN = kb.MaBN
where SoBHYT is not null
group by bs.MaBS, HoTenBS

--3.5
SELECT bn.MABN, bn.HoTenBN
FROM (
    SELECT TOP 1 WITH TIES bn.MABN, bn.HoTenBN
    FROM BENHNHAN bn
    JOIN KHAMBENH kb ON kb.MaBN = bn.MaBN
    GROUP BY bn.MABN, bn.HoTenBN
    ORDER BY count(TAIKHAM) DESC
) AS tk
JOIN BENHNHAN bn ON tk.MABN = bn.MABN
JOIN KHAMBENH kb ON tk.MABN = kb.MaBN
JOIN DONTHUOC dt ON dt.MaKB = kb.MaKB
WHERE YEAR(NgayCapThuoc) = 2024 AND TongTienTT >= 250000;

-- Bảng BENHNHAN
INSERT INTO BENHNHAN (MaBN, HoTenBN, NgaySinh, CCCD, SoBHYT, BHYTChiTra, DiaChi) VALUES
('BN001', 'Nguyen Van Anh', '1985-02-15', '748942819283', 'BHYT001', 0.15, 'Tp.HCM'),
('BN002', 'Tran Thi Binh', '1990-06-20', '746382904712', Null, 0, 'Tp.HCM'),
('BN003', 'Le Van Cuong', '1982-12-10', '742836728987', 'BHYT003', 0.25, 'Tp.HCM'),
('BN004', 'Pham Thi Duong', '1978-03-25', '764738927728', 'BHYT004', 0.15, 'Can Tho'),
('BN005', 'Nguyen Van Bao', '1995-09-15', '745839872712', Null, 0, 'Dong Nai'),
('BN006', 'Tran Van Trung', '1988-11-22', '736378927762', 'BHYT006', 0.15, 'Binh Duong'),
('BN007', 'Pham Thi Giang', '2000-01-01', '763512536847', 'BHYT007', 0.35, 'Tp.HCM'),
('BN008', 'Nguyen Thi Huyen', '1986-07-30', '784391823154', 'BHYT008', 0.25, 'Binh Dinh'),
('BN009', 'Le Van Trinh', '1993-10-05', '748927736275', 'BHYT009', 0.15, 'Tp.HCM'),
('BN010', 'Nguyen Thi Nhung', '1984-04-18', '744343235675', 'BHYT010', 0.25, 'Tay Ninh');

-- Bảng BACSI
INSERT INTO BACSI (MABS, HOTENBS, NGAYBDLV, CHUYENKHOA) VALUES
('BS001', 'Do Van An', '2017-05-15', 'Tai mui hong'),
('BS002', 'Nguyen Van Bach', '2017-08-22', 'Noi khoa'),
('BS003', 'Pham Van Truong', '2018-11-30', 'Ngoai khoa'),
('BS004', 'Tran Thi My', '2019-03-05', 'Tai mui hong'),
('BS005', 'Le Van Chinh', '2019-07-10', 'Ngoai khoa');

-- Bảng KHAMBENH
INSERT INTO KHAMBENH (MAKB, MABN, MABS, NGAYKHAM, TRIEUCHUNG, KETLUAN, TAIKHAM) VALUES
('KB001', 'BN001', 'BS001', '2024-12-01', 'Sot cao, ho', 'Viem hong', 3),
('KB002', 'BN002', 'BS001', '2024-12-01', 'Dau dau, met moi', 'Cam cum', 3),
('KB003', 'BN003', 'BS002', '2024-12-02', 'Khan tieng, ho', 'Viem thanh quan', 6),
('KB004', 'BN004', 'BS002', '2024-12-02', 'Dau bung', 'Roi loan tieu hoa', 6),
('KB005', 'BN001', 'BS001', '2024-12-05', 'Noi man do', 'Di ung', 12),
('KB006', 'BN002', 'BS001', '2024-12-05', 'Dau hong', 'Viem hong', 3),
('KB007', 'BN005', 'BS003', '2024-12-05', 'Sot cao', 'Sot sieu vi', 6),
('KB008', 'BN003', 'BS002', '2024-12-07', 'Noi hach', 'Viem hach', 6),
('KB009', 'BN006', 'BS004', '2024-12-07', 'Dau khop', 'Viem khop', 12),
('KB010', 'BN005', 'BS002', '2024-12-09', 'Noi man ngua', 'Phat ban', 3);

-- Bảng THUOC
INSERT INTO THUOC (MATHUOC, TENTHUOC, LOAITHUOC, DVT, DONGIA) VALUES
('TH001', 'Paracetamol 500mg', 'Thuoc giam dau', 'Vien', 5000),
('TH002', 'Amoxicillin 250mg', 'Thuoc khang sinh', 'Vien', 10000),
('TH003', 'Ibuprofen 400mg', 'Thuoc khang viem', 'Vien', 15000),
('TH004', 'Loratadine 10mg', 'Thuoc di ung', 'Hop', 120000),
('TH005', 'Cefuroxime 500mg', 'Thuoc khang sinh', 'Vien', 20000),
('TH006', 'Omeprazole 20mg', 'Thuoc da day', 'Vien', 8000),
('TH007', 'Vitamin C 1000mg', 'Vitamin dinh duong', 'Vien', 7000),
('TH008', 'Diclofenac 50mg', 'Thuoc giam dau', 'Hop', 180000),
('TH009', 'Dextromethorphan 15mg', 'Thuoc giam ho', 'Vien', 6000),
('TH010', 'Cetirizine 10mg', 'Thuoc di ung', 'Vien', 11000);

-- Bảng DONTHUOC
INSERT INTO DONTHUOC (MADT, MAKB, TRIGIADT, BHYTCHITRA, NGAYCAPTHUOC, TONGTIENTT, TINHTRANGDT) VALUES
('DT001', 'KB001', 84000, 0.15, '2024-12-01', 71400, 'Da thanh toan'),
('DT002', 'KB002', 130000, 0, '2024-12-01', 130000, 'Da thanh toan'),
('DT003', 'KB003', 344000, 0.25, '2024-12-02', 258000, 'Da thanh toan'),
('DT004', 'KB004', 78000, 0.15, '2024-12-02', 66300, 'Da thanh toan'),
('DT005', 'KB005', 142000, 0.15, '2024-12-02', 120700, 'Da thanh toan'),
('DT006', 'KB006', 60000, 0, '2024-12-03', 60000, 'Da thanh toan'),
('DT007', 'KB007', 300000, 0, '2024-12-03', 300000, 'Da thanh toan');


-- Bảng CHITIETDT
INSERT INTO CHITIETDT (MADT, MATHUOC, SOLUONG, THANHTIEN) VALUES
('DT001', 'TH001', 4, 20000),
('DT001', 'TH002', 4, 40000),
('DT001', 'TH009', 4, 24000),
('DT002', 'TH001', 3, 15000),
('DT002', 'TH003', 3, 45000),
('DT002', 'TH007', 10, 70000),
('DT003', 'TH003', 4, 60000),
('DT003', 'TH005', 4, 80000),
('DT003', 'TH008', 1, 180000),
('DT003', 'TH009', 4, 24000),
('DT004', 'TH001', 6, 30000),
('DT004', 'TH006', 6, 48000),
('DT005', 'TH004', 1, 120000),
('DT005', 'TH010', 2, 22000),
('DT006', 'TH009', 10, 60000),
('DT007', 'TH001', 10, 50000),
('DT007', 'TH002', 10, 100000),
('DT007', 'TH006', 10, 80000),
('DT007', 'TH007', 10, 70000);