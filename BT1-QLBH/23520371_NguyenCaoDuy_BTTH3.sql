--18. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất. 
select hd.SOHD
from HOADON hd join CTHD ct on hd.SOHD = ct.SOHD
				join SANPHAM sp on sp.MASP = ct.MASP
where NUOCSX = 'Singapore'
group by hd.SOHD 
having count(distinct ct.MASP) = (select count(*)
								from SANPHAM
								where NUOCSX = 'Singapore');

--19. Tìm số hóa đơn trong năm 2006 đã mua tất cả các sản phẩm do Singapore sản 
--xuất. 
select hd.SOHD
from HOADON hd join CTHD ct on hd.SOHD = ct.SOHD
				join SANPHAM sp on sp.MASP = ct.MASP
where NUOCSX = 'Singapore' and year(NGHD) = 2006
group by hd.SOHD
having count(distinct ct.MASP) = (select count(*)
								from SANPHAM
								where NUOCSX = 'Singapore');

--20. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua? 
select count(*) as notDKTV
from HOADON hd join CTHD ct on hd.SOHD = ct.SOHD
where hd.MAKH IS NULL;

--21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006. 
--CACH 1:
select count(distinct MASP) as countSP
from CTHD ct join HOADON hd on hd.SOHD = ct.SOHD
where year(NGHD) = 2006;
--CACH 2:
select count(distinct MASP) as countSP
from CTHD
where SOHD IN (select SOHD 
				from HOADON
				where year(NGHD) = 2006);

--22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ? 
--CACH 1:
select MAX(TRIGIA) maxGia, MIN(TRIGIA) minGia
from HOADON;

--CACH 2:
(select SOHD, TRIGIA
from HOADON 
where TRIGIA = (select MIN(TRIGIA)
				from HOADON))
UNION
(select SOHD, TRIGIA
from HOADON
where TRIGIA = (select MAX(TRIGIA)
				from HOADON));

--23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu? 
select AVG(TRIGIA) avgGia
from HOADON
where year(NGHD) = 2006;

--24. Tính doanh thu bán hàng trong năm 2006. 
select SUM(TRIGIA) sumDT
from HOADON
where year(NGHD) = 2006;

--25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006. 
--CACH 1:
select top 1 with ties SOHD
from HOADON
where year(NGHD) = 2006
order by TRIGIA DESC;
--CACH 2:
select SOHD
from HOADON
where TRIGIA IN (select MAX(TRIGIA)
				from HOADON
				where year(NGHD) = 2006);

--26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006. 
--CACH 1:
select top 1 HOTEN
from HOADON hd join KHACHHANG kh on hd.MAKH = kh.MAKH
where year(NGHD) = 2006
order by TRIGIA DESC;
--CACH 2:
select HOTEN
from HOADON hd join KHACHHANG kh on kh.MAKH = hd.MAKH
where TRIGIA IN (select MAX(TRIGIA)
				from HOADON);

--27. In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm 
--dần. 
select distinct TOP 3 with ties MAKH, HOTEN, DOANHSO
from KHACHHANG
order by DOANHSO DESC;

--28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao 
--nhất. 
select top 3 with ties MASP, TENSP, GIA
from SANPHAM
order by GIA DESC;

--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 
--trong 3 mức giá cao nhất (của tất cả các sản phẩm). 
select MASP, TENSP, NUOCSX, GIA
from ( 
		select top 3 with ties MASP, TENSP, NUOCSX, GIA
		from SANPHAM
		order by GIA DESC) as top3
where NUOCSX = 'Thai Lan';

--30. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 
--trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất). 
select top 3 with ties MASP, TENSP, GIA
from SANPHAM
where NUOCSX = 'Trung Quoc'
order by GIA DESC;

--31. * In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số). 
select *
from KHACHHANG
where DOANHSO in (select distinct top 3 DOANHSO		
					from KHACHHANG
					order by DOANHSO DESC);

--32. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
select count(*)
from SANPHAM
where NUOCSX = 'Trung Quoc';

--33. Tính tổng số sản phẩm của từng nước sản xuất. 
select NUOCSX, count(*) as countSP
from SANPHAM
group by NUOCSX;

--34. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. 
select NUOCSX, MAX(GIA) as maxGia, MIN(GIA) as minGia, AVG(GIA) as avgGia
from SANPHAM
group by NUOCSX;

--35. Tính doanh thu bán hàng mỗi ngày. 
select NGHD, sum(TRIGIA) as sumTriGia
from HOADON
group by NGHD;

--36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
select NGHD, sum(SL) as SLSP
from HOADON hd join CTHD ct on ct.SOHD = hd.SOHD
where month(NGHD) = 10
group by NGHD;

--37. Tính doanh thu bán hàng của từng tháng trong năm 2006.
select month(NGHD) as THANG, sum(TRIGIA) as DOANHTHU
from HOADON
group by month(NGHD);

--38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau. 
select SOHD
from CTHD 
group by SOHD
having count(MASP) >= 4;

--39. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau). 
select SOHD
from CTHD ct join SANPHAM sp on sp.MASP = ct.MASP
where NUOCSX = 'Viet Nam'
group by SOHD
having count(distinct ct.MASP) = 3;

--40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.  
select top 1 with ties hd.MAKH, HOTEN, count(SOHD) as SOLANMUAHANG
from KHACHHANG kh join HOADON hd on kh.MAKH = hd.MAKH
group by hd.MAKH, HOTEN
order by SOLANMUAHANG DESC;

--41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? 
select top 1 with ties month(NGDK) as M_2006, sum(DOANHSO) as DS
from KHACHHANG
group by month(NGDK)
order by DS DESC;

--42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006. 
select top 1 with ties ct.MASP, TENSP, sum(SL) as sumSL_2006
from SANPHAM sp join CTHD ct on sp.MASP = ct.MASP
				join HOADON hd on hd.SOHD = ct.SOHD
where year(NGHD) = 2006
group by ct.MASP, TENSP
order by sumSL_2006 ASC;

--43. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. 
select sp.NUOCSX, MASP, TENSP, GIA
from SANPHAM sp join ( select NUOCSX, max(GIA) as max_GIA
		from SANPHAM
		group by NUOCSX) as NUOC
		on NUOC.NUOCSX = sp.NUOCSX and sp.GIA = MAX_GIA;		

--44. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
select NUOCSX, count(distinct (GIA)) as SLGIA_KHAC_NHAU
from SANPHAM
group by NUOCSX
having count(distinct (GIA)) >= 3;

----45. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều 
--nhất.
select top 1 with ties *
from (
		select distinct top 10 kh.MAKH, HOTEN, DOANHSO, count(SOHD) as SOLANMUAHANG
		from KHACHHANG kh join HOADON hd on kh.MAKH = hd.MAKH
		group by kh.MAKH, HOTEN, DOANHSO
		order by DOANHSO DESC) as top10DS
order by SOLANMUAHANG DESC;