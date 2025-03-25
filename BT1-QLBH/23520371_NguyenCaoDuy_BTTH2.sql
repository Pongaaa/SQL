 -- 1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

 -- 2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE DVT = 'cay' or DVT = 'quyen';

 -- 3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết 
    -- thúc là “01”. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP like 'B%01';

 -- 4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 
    -- đến 40.000. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' and GIA between 30000 and 40000;

 -- 5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản 
    -- xuất có giá từ 30.000 đến 40.000. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX IN ('Trung Quoc', 'Thai Lan') and GIA between 30000 and 40000;

 -- 6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007. 
set dateformat dmy
SELECT SOHD, TRIGIA
FROM HOADON
WHERE NGHD = '1/1/2007' or NGHD = '2/1/2007';

 -- 7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và
    -- trị giá của hóa đơn (giảm dần). 
SELECT SOHD, TRIGIA
FROM HOADON
WHERE month(NGHD) = 1 and year(NGHD) = 2007
ORDER by NGHD ASC, TRIGIA DESC;

 -- 8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007. 
SELECT kh.MAKH,HOTEN
FROM KHACHHANG kh join HOADON hd on kh.MAKH = hd.MAKH
WHERE NGHD = '1/1/2007';

 -- 9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 
    -- 28/10/2006. 
SELECT hd.SOHD, TRIGIA
FROM HOADON hd join NHANVIEN nv on hd.MANV = nv.MANV
WHERE HOTEN = 'Nguyen Van B' and NGHD = '28/10/2006';

 -- 10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” 
     -- mua trong tháng 10/2006.
SELECT sp.MASP, TENSP
FROM KHACHHANG kh join HOADON hd on kh.MAKH = hd.MAKH
		join CTHD ct on hd.SOHD = ct.SOHD
		join SANPHAM sp on sp.MASP = ct.MASP
WHERE HOTEN = 'Nguyen Van A' and (month(NGHD) = 10 and year(NGHD) = 2006);

 -- 11. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.
 SELECT SOHD
 FROM CTHD
 WHERE MASP = 'BB01'
 UNION
 (SELECT SOHD
 FROM CTHD
 WHERE MASP = 'BB02');

 SELECT distinct SOHD
 FROM CTHD
 WHERE MASP = 'BB01' or MASP = 'BB02';

 -- 12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm 
     -- mua với số lượng từ 10 đến 20. 
SELECT SOHD
FROM CTHD
WHERE MASP = 'BB01' and SL between 10 and 20
UNION
(SELECT SOHD
FROM CTHD
WHERE MASP = 'BB02' and SL between 10 and 20);

 -- 13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản 
     -- phẩm mua với số lượng từ 10 đến 20.
 ----- Cách 1: -----
SELECT SOHD
FROM CTHD
WHERE MASP = 'BB01' and SL between 10 and 20
INTERSECT
(SELECT SOHD
FROM CTHD
WHERE MASP = 'BB02' and SL between 10 and 20);

 ----- Cách 2 -----
SELECT SOHD
FROM CTHD
WHERE (SL between 10 and 20) and MASP = 'BB01' and SOHD in (SELECT SOHD
															FROM CTHD
															WHERE (SL between 10 and 20) and MASP = 'BB02');

 -- 14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản 
     -- phẩm được bán ra trong ngày 1/1/2007. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
UNION
SELECT sp.MASP, TENSP
FROM SANPHAM sp join CTHD ct on ct.MASP = sp.MASP
				join HOADON hd on hd.SOHD = ct.SOHD
WHERE NGHD = '1/1/2007';

 -- 15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
(SELECT MASP, TENSP
FROM SANPHAM)
EXCEPT
(SELECT ct.MASP, TENSP
FROM CTHD ct join SANPHAM sp on sp.MASP = ct.MASP);

SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN(SELECT MASP
				FROM CTHD);

 -- 16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006. 
(SELECT MASP, TENSP
FROM SANPHAM)
EXCEPT
(SELECT ct.MASP, TENSP
FROM CTHD ct join SANPHAM sp on sp.MASP = ct.MASP
			join HOADON hd on ct.SOHD = hd.SOHD
WHERE year(NGHD)=2006);

 -- 17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán 
     -- được trong năm 2006. 
(SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc')
EXCEPT
(SELECT ct.MASP, TENSP
FROM CTHD ct join SANPHAM sp on sp.MASP = ct.MASP
			join HOADON hd on hd.SOHD = ct.SOHD
WHERE year(NGHD) = 2006);
