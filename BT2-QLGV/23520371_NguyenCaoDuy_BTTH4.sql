--PHAN I--
--1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính 
--GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN.
alter table HOCVIEN
add GHICHU varchar(100), DIEMTB decimal(4,2), XEPLOAI varchar(40)

--3. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
alter table HOCVIEN
add constraint gt_chk
check (GIOITINH in ('Nam', 'Nu'));

--4. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22). 
alter table KETQUATHI
add constraint gt_chk
check (DIEM between 0 and 10 and RIGHT(CAST(DIEM as varchar), 3) LIKE '.__');

--5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10  và “Khong dat” nếu điểm nhỏ hơn 5. 
alter table KETQUATHI
add constraint kqt_chk
check ((DIEM between 5 and 10 and KQUA = 'Dat') or (Diem < 5 and KQUA = 'Khong dat'));

--6. Học viên thi một môn tối đa 3 lần. 
alter table KETQUATHI
add constraint lt_chk
check (LANTHI <= 3);


--7. Học kỳ chỉ có giá trị từ 1 đến 3. 
alter table GIANGDAY
add constraint hk_chk
check (HOCKY >= 1 and HOCKY <= 3)

--8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
alter table GIAOVIEN
add constraint jv_chk
check (HOCVI in ('CN', 'KS', 'Ths', 'TS', 'PTS'));

--11. Học viên ít nhất là 18 tuổi. 
alter table HOCVIEN
add constraint tuoi_chk
check (DATEDIFF(YEAR, NGSINH, GETDATE()) >= 18);

--12. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY). 
alter table GIANGDAY
add constraint ngay_chk
check (TUNGAY < DENNGAY);

--13. Giáo viên khi vào làm ít nhất là 22 tuổi. 
alter table GIAOVIEN
add constraint tuoigv_chk
check (DATEDIFF(YEAR, NGSINH, GEtDATE()) >= 22);

--14. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
alter table MONHOC
add constraint tc_chk
check (ABS(TCLT - TCTH) <=3);


--PHAN II--
--1. Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa. 
update GIAOVIEN
set HESO = HESO + 0.2
from GIAOVIEN gv join KHOA kh on gv.MAKHOA = kh.MAKHOA
where MAGV = TRGKHOA;

update GIAOVIEN
set HESO = HESO + 0.2
where MAGV in (select TRGKHOA from KHOA)

--2. Cập nhật giá trị điểm trung bình tất cả các môn học  (DIEMTB) của mỗi học viên (tất cả các môn 
--học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng). 
UPDATE HOCVIEN
SET DIEMTB = (
    SELECT AVG(DIEM)
    FROM (
        SELECT MAHV, MAX(LANTHI) AS max_lanthi
        FROM KETQUATHI
        GROUP BY MAHV
    ) AS latest_attempts
    JOIN KETQUATHI kq ON latest_attempts.MAHV = kq.MAHV AND latest_attempts.max_lanthi = kq.LANTHI
    WHERE HOCVIEN.MAHV = latest_attempts.MAHV
);
									
--3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi 
--lần thứ 3 dưới 5 điểm. 
update HOCVIEN
set GHICHU = 'Cam thi'
from HOCVIEN hv join KETQUATHI kq on hv.MAHV = kq.MAHV
where LANTHI = 3 and DIEM < 5;

--4. Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau: 
--o Nếu DIEMTB  9 thì XEPLOAI =”XS” 
update HOCVIEN
set XEPLOAI = 'XS'
where DIEMTB >= 9;

--o Nếu  8  DIEMTB < 9 thì XEPLOAI = “G” 
update HOCVIEN
set XEPLOAI = 'G'
where DIEMTB >= 8 and DIEMTB < 9;

--o Nếu  6.5  DIEMTB < 8 thì XEPLOAI = “K”
update HOCVIEN
set XEPLOAI = 'K'
where DIEMTB >= 6.5 and DIEMTB < 8;

--o Nếu  5    DIEMTB < 6.5 thì XEPLOAI = “TB” 
update HOCVIEN
set XEPLOAI = 'TB'
where DIEMTB >= 5 and DIEMTB < 6.5;

--o Nếu  DIEMTB < 5 thì XEPLOAI = ”Y” 
update HOCVIEN
set XEPLOAI = 'Y'
where DIEMTB < 5;

update HOCVIEN
set XEPLOAI =
(
	CASE	
		When DIEMTB >= 9 then 'XS'
		when DIEMTB >= 8 and DIEMTB < 9 then 'G'
		when DIEMTB >= 6.5 and DIEMTB < 8 then 'K'
		when DIEMTB >= 5 and DIEMTB < 6.5 then 'TB'
		when DIEMTB < 5 then 'Y'
	END
);

-- PHAN 3 --
--1. In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp. 
select MAHV, HO, TEN, NGSINH, hv.MALOP
from HOCVIEN hv join LOP lop on hv.MALOP = lop.MALOP
where MAHV = TRGLOP;

--2. In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, sắp xếp 
--theo tên, họ học viên. 
select hv.MAHV, HO, TEN, LANTHI, DIEM
from KETQUATHI kq join HOCVIEN hv on kq.MAHV = hv.MAHV
where MAMH = 'CTRR' and MALOP = 'K12'

--3. In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ 
--nhất đã đạt. 
select hv.MAHV, HO, TEN, MAMH
from KETQUATHI kq join HOCVIEN hv on kq.MAHV = hv.MAHV
where LANTHI = 1 and KQUA = 'Dat'
group by hv.MAHV, MAMH, HO, TEN;

--4. In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1).
select hv.MAHV, HO, TEN
from KETQUATHI kq join HOCVIEN hv on kq.MAHV = hv.MAHV
where LANTHI = 1 and KQUA = 'Khong dat' and MAMH = 'CTRR' and MALOP = 'K11'
group by hv.MAHV, HO, TEN;

--5. * Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi).
SELECT HV.MAHV,HO,TEN
FROM HOCVIEN HV JOIN KETQUATHI KQ
ON HV.MAHV = KQ.MAHV
WHERE MALOP LIKE 'K%' AND MAMH = 'CTRR' AND KQUA = 'Khong Dat' AND LANTHI = 1
except
(
SELECT HV.MAHV,HO,TEN
FROM HOCVIEN HV JOIN KETQUATHI KQ
ON HV.MAHV = KQ.MAHV
WHERE MALOP LIKE 'K%' AND MAMH = 'CTRR' AND KQUA = 'Dat' AND LANTHI = 2
union
SELECT HV.MAHV,HO,TEN
FROM HOCVIEN HV JOIN KETQUATHI KQ
ON HV.MAHV = KQ.MAHV
WHERE MALOP LIKE 'K%' AND MAMH = 'CTRR' AND KQUA = 'Dat' AND LANTHI = 3);

--6.Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006. 
select TENMH
from MONHOC mh join GIAOVIEN gv on mh.MAKHOA = gv.MAKHOA
				join GIANGDAY gd on gd.MAGV = gv.MAGV
where HOTEN = 'Tran Tam Thanh' and HOCKY = 1 and year(TUNGAY) = 2006;

--7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học 
--kỳ 1 năm 2006. 
select mh.MAMH, TENMH
from MONHOC mh join GIANGDAY gd on mh.MAMH = gd.MAMH
				join LOP lop on lop.MALOP = gd.MALOP
where year(TUNGAY) = 2006 and year(DENNGAY) = 2006 and LOP.MALOP = 'K11' and MAGV = (select MAGVCN
																				from LOP
																				where MALOP = 'K11')

--8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”. 
select HO, TEN
from HOCVIEN hv full join GIANGDAY gd on hv.MALOP = gd.MALOP
				full join GIAOVIEN gv on gv.MAGV = gd.MAGV
				full join MONHOC mh on gd.MAMH = mh.MAMH
				full join LOP lop on lop.MALOP = hv.MALOP
where HOTEN = 'Nguyen To Lan' and TENMH = 'Co So Du Lieu' and MAHV in (select TRGLOP
																		from LOP)

--9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du 
--Lieu”. 
select mh.MAMH, TENMH
from DIEUKIEN dk join MONHOC mh on dk.MAMH_TRUOC = mh.MAMH
where dk.MAMH = 'CSDL'


--10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên 
--môn học) nào. 
select mh.MAMH, TENMH
from DIEUKIEN dk join MONHOC mh on dk.MAMH = mh.MAMH
where MAMH_TRUOC = 'CTRR'

--11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006. 
select HOTEN
from GIAOVIEN gv join GIANGDAY gd on gd.MAGV = gv.MAGV
where HOCKY = '1'and NAM = 2006 and MAMH = 'CTRR' and MALOP ='K11'
INTERSECT
select HOTEN
from GIAOVIEN gv join GIANGDAY gd on gd.MAGV = gv.MAGV
where HOCKY = '1'and NAM = 2006 and MAMH = 'CTRR' and MALOP ='K12'

--12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi 
--lại môn này. 
select distinct kq.MAHV, HO, TEN
from KETQUATHI kq join HOCVIEN hv on hv.MAHV = kq.MAHV
where KQUA = 'Khong Dat' and MAMH = 'CSDL'
except 
	select kq.MAHV, HO, TEN
	from KETQUATHI kq join HOCVIEN hv on hv.MAHV = kq.MAHV
	where LANTHI = 2;

--13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào. 
select MAGV, HOTEN
from GIAOVIEN
except
	select gd.MAGV, HOTEN
	from GIANGDAY gd join GIAOVIEN gv on gv.MAGV = gd.MAGV

--14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc 
--khoa giáo viên đó phụ trách. 
--14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
SELECT MAGV, HOTEN FROM GIAOVIEN 
WHERE MAGV NOT IN (SELECT GD.MAGV
	               FROM GIANGDAY GD JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV 
				                    JOIN MONHOC MH ON GD.MAMH = MH.MAMH
				   WHERE GV.MAKHOA = MH.MAKHOA)
--15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần 
--thứ 2 môn CTRR được 5 điểm. 
select HO, TEN
from HOCVIEN hv join KETQUATHI kq on kq.MAHV = hv.MAHV
where LANTHI = '3' and KQUA = 'Khong Dat' and MALOP = 'K11'
union
	select HO, TEN
	from HOCVIEN hv join KETQUATHI kq on kq.MAHV = hv.MAHV
	where LANTHI = '2' and MAMH = 'CTRR' and MALOP = 'K11' and DIEM = 5.00

--16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học. 
select HOTEN
from GIANGDAY gd join GIAOVIEN gv on gv.MAGV = gd.MAGV
where MAMH = 'CTRR'
group by HOCKY, HOTEN
having count(MALOP) >= 2;

--17. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng). 
select hv.MAHV, HO, TEN, DIEM, LANTHI
from KETQUATHI kq1 join HOCVIEN hv on hv.MAHV = kq1.MAHV
				join (select MAHV, max(LANTHI) as LANTHI_
						from KETQUATHI
						where MAMH = 'CSDL'
						group by MAHV) as kq2 on kq1.MAHV = kq2.MAHV and kq1.LANTHI = kq2.LANTHI_
where MAMH = 'CSDL'
order by MAHV ASC;

--18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi). 
select hv.MAHV, HO, TEN, DIEM, LANTHI
from KETQUATHI kq1 join HOCVIEN hv on hv.MAHV = kq1.MAHV
					join (select MAHV, MAX(DIEM) as DIEM_
							from KETQUATHI
							where MAMH = 'CSDL'
							group by MAHV) as kq2 on kq1.MAHV = kq2.MAHV and kq1.DIEM = kq2.DIEM_
where MAMH = 'CSDL'

--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 
select MAKHOA, TENKHOA
from KHOA
where NGTLAP in (select min(NGTLAP)
				from KHOA)

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
select HOCHAM, count(HOCHAM) as SOLUONG
from GIAOVIEN
where HOCHAM = 'GS' or HOCHAM = 'PGS'
group by HOCHAM

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
select MAKHOA, HOCVI, count(HOCVI) as SOLUONG
from GIAOVIEN
where HOCVI = 'CN' or HOCVI = 'KS' or HOCVI = 'Ths' or HOCVI = 'TS' or HOCVI = 'PTS'
group by MAKHOA, HOCVI
order by MAKHOA 

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt). 
select mh.MAMH, KQUA, count(KQUA)
from MONHOC mh join KETQUATHI kq on kq.MAMH = mh.MAMH
group by mh.MAMH, KQUA
order by MAMH

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít 
--nhất một môn học. 
select gv.MAGV, HOTEN
from GIAOVIEN gv join LOP lop on lop.MAGVCN = gv.MAGV
				join GIANGDAY gd on gv.MAGV = gd.MAGV
union 
select gv.MAGV, HOTEN
from GIAOVIEN gv join LOP lop on lop.MAGVCN = gv.MAGV
				join GIANGDAY gd on gv.MAGV = gd.MAGV
group by gv.MAGV, HOTEN
having count(MAMH) >= 1;

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
select HO, TEN
from HOCVIEN hv join LOP lop on hv.MAHV = lop.TRGLOP
where SISO in (select max(SISO)
				from LOP)
