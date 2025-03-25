create database YeuCau1
----------------------------------------------------------------
 -- SACH
create table SACH
(
   MaSach char(5),
   TenSach nvarchar(20),
   TheLoai nvarchar(50),
   NXB nvarchar(20),
   constraint pk_ms primary key(MaSach)
);
----------------------------------------------------------------
 -- KHACHHANG
create table KHACHHANG
(
   MaKH char(5),
   HoTen nvarchar(25),
   NgaySinh smalldatetime,
   DiaChi nvarchar(50),
   SoDT Varchar(15),
   NgDK smalldatetime,
   constraint pk_kh primary key(MAKH)
);
----------------------------------------------------------------
 -- CHITIET_PHIEUMUA
create table CHITIET_PHIEUMUA
(
   MaSach char(5),
   MaPM char(5),
   constraint pk_ctpm primary key(MaSach, MaPM)
);
----------------------------------------------------------------
 -- PHIEUMUA
create table PHIEUMUA
(
   MaPM char(5),
   MaKH char(5),
   NgayMua smalldatetime,
   SoSachMua int,
   constraint pk_pm primary key(MaPM)
);

----------------------------------------------------------------
-- Khoa ngoai cho bang CHITIET_PHIEUMUA
ALTER TABLE CHITIET_PHIEUMUA ADD CONSTRAINT fk01_CTPM FOREIGN KEY(MaSach) REFERENCES SACH(MaSach)
ALTER TABLE CHITIET_PHIEUMUA ADD CONSTRAINT fk02_CTPM FOREIGN KEY(MaPM) REFERENCES PHIEUMUA(MaPM)
-- Khoa ngoai cho bang CHITIET_PHIEUMUA
ALTER TABLE PHIEUMUA ADD CONSTRAINT fk01_PM FOREIGN KEY(MaKH) REFERENCES KHACHHANG(MaKH)

----------------------------------------------------------------
select * from PHIEUMUA
select * from KHACHHANG
select * from CHITIET_PHIEUMUA
select * from SACH
