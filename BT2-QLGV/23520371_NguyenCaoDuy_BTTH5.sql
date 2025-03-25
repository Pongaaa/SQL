--QLBH_2020--
--PHẦN I
--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày 
--khách hàng đó đăng ký thành viên (NGDK). 
CREATE TRIGGER trg_CheckNGDK_hoadon
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MAKH varchar(4), @NGHD smalldatetime, @NGDK smalldatetime
	SELECT @MAKH = i.MAKH, @NGHD = i.NGHD
	FROM inserted i

	SELECT NGDK = @NGDK
	FROM KHACHHANG
	WHERE MAKH = @MAKH

	IF @NGHD < @NGDK
	BEGIN
		RAISERROR('Ngay hoa don phai lon hon hoac bang ngay vao lam', 16, 1)
		ROLLBACK
	END
	ELSE
	BEGIN
		PRINT 'Cap nhat thanh cong'
	END
END;

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó 
--vào làm. 
CREATE TRIGGER trg_checkNGVL_hoadon
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MANV varchar(4), @NGHD smalldatetime, @NGVL smalldatetime;
	SELECT @MANV = i.MANV, @NGHD = i.NGHD
	FROM inserted i

	SELECT @NGVL = NGVL
	FROM NHANVIEN
	WHERE MANV = @MANV

	IF @NGHD < @NGVL
	BEGIN
		RAISERROR('Ngay hoa don phai lon hon hoac bang ngay vao lam', 16, 1)
		ROLLBACK
	END
	ELSE
	BEGIN
		PRINT 'C?p nh?t thành công';
	END
END;


--QUANLIGIAOVU_0208--
--PHẦN I
--9. Lớp trưởng của một lớp phải là học viên của lớp đó. 
CREATE TRIGGER trg_loptrg_hocvien
ON HOCVIEN
AFTER UPDATE
AS
BEGIN 
	DECLARE @TRGLOP varchar(4), @MALOP varchar(3)
	SELECT @TRGLOP = i.MAHV, @MALOP = i.MALOP
	FROM inserted i

	IF NOT EXISTS ( 
		SELECT 1
		FROM HOCVIEN hv 
		WHERE hv.MAHV = @TRGLOP AND hv.MALOP = @MALOP )
	BEGIN 
	RAISERROR('L?p tr??ng ph?i là h?c viên c?a l?p ?ó.', 16, 1) ;
	ROLLBACK;
	END
	ELSE
	BEGIN
		PRINT 'C?p nh?t thành công';
	END
END;

--10. Tr??ng khoa ph?i là giáo viên thu?c khoa và có h?c v? “TS” ho?c “PTS”
CREATE TRIGGER trg_gv_khoa
ON KHOA
AFTER INSERT, UPDATE
AS
BEGIN 
	DECLARE @TRGKHOA varchar(4), @MAKHOA varchar(4)
	SELECT @TRGKHOA = i.TRGKHOA, @MAKHOA = i.MAKHOA
	FROM inserted i

	IF not exists (
		SELECT 1
		FROM GIAOVIEN gv
		WHERE gv.MAGV = @TRGKHOA and gv.MAKHOA = @MAKHOA and HOCVI in ('TS', 'PTS')
		)
	BEGIN
		RAISERROR('Tr??ng khoa ph?i là giáo viên thu?c khoa và có h?c v? “TS” ho?c “PTS”', 16, 1);
		ROLLBACK;
	END
	ELSE
	BEGIN
		PRINT 'C?p nh?t thành công';
	END
END;

--15. H?c viên ch? ???c thi m?t môn h?c nào ?ó khi l?p c?a h?c viên ?ã h?c xong môn h?c này.
CREATE TRIGGER trg_check_thi_monhoc
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MAHV varchar(10), @MAMH varchar(10), @NGTHI smalldatetime;
    SELECT @MAHV = MAHV, @MAMH = MAMH, @NGTHI = NGTHI
    FROM inserted;

    DECLARE @MALOP varchar(3);
    SELECT @MALOP = MALOP
    FROM HOCVIEN
    WHERE MAHV = @MAHV;

    IF NOT EXISTS (
        SELECT *
        FROM GIANGDAY
        WHERE MALOP = @MALOP AND MAMH = @MAMH AND DENNGAY <= @NGTHI
    )
    BEGIN
        RAISERROR('H?c viên ch? ???c thi môn h?c khi l?p ?ã h?c xong môn ?ó.', 16, 1)
        ROLLBACK
    END
    ELSE
    BEGIN
        PRINT 'Cập nhật thành công'
    END
END;

--16. M?i h?c k? c?a m?t n?m h?c, m?t l?p ch? ???c h?c t?i ?a 3 môn.
CREATE TRIGGER trg_max_mon_giangday
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MALOP varchar(3), @HOCKY int, @NAM int;
    SELECT @MALOP = MALOP, @HOCKY = HOCKY, @NAM = NAM
    FROM inserted;
    DECLARE @SO_MON int;
    SELECT @SO_MON = COUNT(*)
    FROM GIANGDAY
    WHERE MALOP = @MALOP AND HOCKY = @HOCKY AND NAM = @NAM;

    IF @SO_MON >= 3
    BEGIN
        RAISERROR('M?i h?c k? c?a m?t n?m h?c, m?t l?p ch? ???c h?c t?i ?a 3 môn', 16, 1)
        ROLLBACK
    END
    ELSE
    BEGIN
        PRINT 'C?p nh?t thành công'
    END
END;

--17. S? s? c?a m?t l?p b?ng v?i s? l??ng h?c viên thu?c l?p ?ó.
--em s? vi?t tigger c?p nh?t l?i s? s? c?a l?p sao cho b?ng v?i s? l??ng h?c viên thu?c l?p ?ó.
CREATE TRIGGER trg_siso_hocvien
ON HOCVIEN
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    UPDATE LOP
    SET SISO = (SELECT COUNT(*)
                FROM HOCVIEN
                WHERE HOCVIEN.MALOP = LOP.MALOP
    )
    WHERE LOP.MALOP IN (
        SELECT MALOP FROM inserted
        UNION
        SELECT MALOP FROM deleted
    );
    PRINT 'Cập nhật thành công'
END;

--18. Trong quan h? DIEUKIEN giá tr? c?a thu?c tính MAMH và MAMH_TRUOC trong cùng m?t b? 
--không ???c gi?ng nhau (“A”,”A”) và c?ng không t?n t?i hai b? (“A”,”B”) và (“B”,”A”).
CREATE TRIGGER trg_mamh_dieukien
ON DIEUKIEN
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT *
        FROM inserted
        WHERE MAMH = MAMH_TRUOC
    )
    BEGIN
        RAISERROR('MAMH và MAMH_TRUOC trong cùng m?t b? không ???c gi?ng nhau', 16, 1)
        ROLLBACK
        RETURN
    END
    IF EXISTS (
        SELECT *
        FROM inserted i
        JOIN DIEUKIEN dk
        ON i.MAMH = dk.MAMH_TRUOC AND i.MAMH_TRUOC = dk.MAMH
    )
    BEGIN
        RAISERROR('MAMH và MAMH_TRUOC trong cùng m?t b? không ???c gi?ng nhau', 16, 1)
        ROLLBACK 
        RETURN
    END
    INSERT INTO DIEUKIEN (MAMH, MAMH_TRUOC)
    SELECT MAMH, MAMH_TRUOC
    FROM inserted;
    PRINT 'C?p nh?t thành công'
END;

--19. Các giáo viên có cùng h?c v?, h?c hàm, h? s? l??ng thì m?c l??ng b?ng nhau.
CREATE TRIGGER trg_mucluong_giaovien
ON GIAOVIEN
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT *
        FROM inserted i
        JOIN GIAOVIEN gv
        ON i.HOCVI = gv.HOCVI AND i.HOCHAM = gv.HOCHAM AND i.HESO = gv.HESO
        WHERE i.MUCLUONG != gv.MUCLUONG
    )
    BEGIN
        RAISERROR('Giáo viên có cùng h?c v?, h?c hàm, và h? s? l??ng ph?i có m?c l??ng b?ng nhau', 16, 1)
        ROLLBACK
        RETURN
    END

    INSERT INTO GIAOVIEN (MAGV, HOTEN, HOCVI, HOCHAM,GIOITINH, NGSINH, NGVL, HESO, MUCLUONG, MAKHOA)
    SELECT MAGV, HOTEN, HOCVI, HOCHAM,GIOITINH, NGSINH, NGVL, HESO, MUCLUONG, MAKHOA
    FROM inserted;

    PRINT 'C?p nh?t thành công'
END;

--20. H?c viên ch? ???c thi l?i (l?n thi >1) khi ?i?m c?a l?n thi tr??c ?ó d??i 5.
CREATE TRIGGER trg_thilai_ketquathi
ON KETQUATHI
FOR INSERT
AS
BEGIN
    DECLARE @MAHV varchar(4);
    DECLARE @MAMH varchar(10);
    DECLARE @LT INT;
    SELECT @MAHV = MAHV, @MAMH = MAMH, @LT = LANTHI
    FROM inserted;

    IF @LT > 1
    BEGIN
        IF NOT EXISTS (
            SELECT *
            FROM KETQUATHI
            WHERE MAHV = @MAHV AND MAMH = @MAMH AND LANTHI = @LT - 1 AND DIEM < 5
        )
        BEGIN
            RAISERROR('H?c viên ch? ???c thi l?i khi ?i?m c?a l?n thi tr??c ?ó d??i 5', 16, 1)
            ROLLBACK
        END
    END
    ELSE
    BEGIN
        PRINT 'C?p nh?t thành công'
    END
END;

--21. Ngày thi c?a l?n thi sau ph?i l?n h?n ngày thi c?a l?n thi tr??c (cùng h?c viên, cùng môn h?c).
CREATE TRIGGER trg_ngaythi_ketquathi
ON KETQUATHI
FOR INSERT
AS
BEGIN
    DECLARE @MAHV varchar(10);
    DECLARE @MAMH varchar(10);
    DECLARE @LANTHI int;
    DECLARE @NGTHI smalldatetime;
    SELECT @MAHV = MAHV, @MAMH = MAMH, @LANTHI = LANTHI, @NGTHI = NGTHI
    FROM inserted;

    IF @LANTHI > 1
    BEGIN
        IF EXISTS (SELECT * --t?n t?i ngày thi trc ?ó l?n h?n @NGTHI
                   FROM KETQUATHI
                   WHERE MAHV = @MAHV AND MAMH = @MAMH AND LANTHI = @LANTHI - 1 AND NGTHI >= @NGTHI
        )
        BEGIN
            RAISERROR('Ngày thi c?a l?n thi sau ph?i l?n h?n ngày thi c?a l?n thi tr??c ?ó', 16, 1)
            ROLLBACK
        END
    END
    ELSE
    BEGIN
        PRINT 'C?p nh?t thành công'
    END
END;

--22. H?c viên ch? ???c thi nh?ng môn mà l?p c?a h?c viên ?ó ?ã h?c xong.
CREATE TRIGGER trg_hocxong_ketquathi
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MAHV varchar(10)
    DECLARE @MAMH varchar(10)
    DECLARE @LANTHI int
    DECLARE @MALOP varchar(3)
    DECLARE @DENNGAY smalldatetime
	DECLARE @NGTHI smalldatetime

    SELECT @MAHV = MAHV, @MAMH = MAMH, @LANTHI = LANTHI, @NGTHI = NGTHI
    FROM inserted

    SELECT @MALOP = MALOP
    FROM HOCVIEN
    WHERE MAHV = @MAHV

    SELECT @DENNGAY = DENNGAY
    FROM GIANGDAY
    WHERE MALOP = @MALOP AND MAMH = @MAMH

    IF @NGTHI < @DENNGAY
    BEGIN
        RAISERROR('Không th? thi khi l?p ch?a h?c xong môn này', 16, 1)
        ROLLBACK
    END
	ELSE
    PRINT 'C?p nh?t thành công'
END;

--23. Khi phân công gi?ng d?y m?t môn h?c, ph?i xét ??n th? t? tr??c sau gi?a các môn h?c (sau khi h?c 
--xong nh?ng môn h?c ph?i h?c tr??c m?i ???c h?c nh?ng môn li?n sau).
CREATE TRIGGER trg_thutu_phancong_giangday
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MALOP varchar(3)
    DECLARE @MAMH varchar(10)
    DECLARE @TUNGAY datetime
    
	SELECT @MALOP = MALOP, @MAMH = MAMH, @TUNGAY = TUNGAY
    FROM inserted

    IF EXISTS (
        SELECT *
        FROM DIEUKIEN DK
        WHERE DK.MAMH= @MAMH
        AND NOT EXISTS (SELECT * 
                        FROM GIANGDAY GD
                        WHERE GD.MALOP = @MALOP
                              AND GD.MAMH = DK.MAMH_TRUOC
                              AND GD.DENNGAY IS NOT NULL 
                              AND GD.DENNGAY < @TUNGAY
                         )
    )
    BEGIN
        RAISERROR('Không th? phân công gi?ng d?y vì môn tr??c ch?a hoàn thành', 16, 1)
        ROLLBACK
        RETURN
    END
    PRINT 'C?p nh?t thành công'
END;

--24. Giáo viên ch? ???c phân công d?y nh?ng môn thu?c khoa giáo viên ?ó ph? trách.
CREATE TRIGGER trg_phutrach_phancong_giangday
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MAGV varchar(4);
    DECLARE @MAMH varchar(10);
    DECLARE @MAKHOA_GV varchar(4);
    DECLARE @MAKHOA_MH varchar(4);
    SELECT @MAGV = i.MAGV, @MAMH = i.MAMH
    FROM inserted i;

    SELECT @MAKHOA_GV = MAKHOA
    FROM GIAOVIEN
    WHERE MAGV = @MAGV;

    SELECT @MAKHOA_MH = MAKHOA
    FROM MONHOC
    WHERE MAMH = @MAMH;

    IF @MAKHOA_GV != @MAKHOA_MH
    BEGIN
        RAISERROR('Giáo viên ch? ???c phân công d?y các môn thu?c khoa mà giáo viên ph? trách!', 16, 1)
        ROLLBACK
        RETURN
    END
    PRINT 'C?p nh?t thành công'
END;
