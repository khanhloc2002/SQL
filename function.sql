/* 19.Kiểm tra khách hàng đã mở tài khoản tại ngân hàng hay chưa nếu biết họ tên và số điện thoại của họ.*/
-- input :họ tên,sđt
-- output : tự in 
go
create FUNCTION hamcau19 (@hoten nvarchar(100), @sdt varchar(12))
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @demsotaikhoan int
	SELECT @demsotaikhoan = COUNT(account.Ac_no)  
	FROM customer 
	LEFT JOIN account ON customer.Cust_id = account.cust_id
	WHERE customer.Cust_name = @hoten
	AND customer.Cust_phone = @sdt

	DECLARE @result nvarchar(100)

	IF @demsotaikhoan > 0
		SET @result = N'Đã có tài khoản'
	ELSE
		SET @result = N'Chưa có tài khoản'

	RETURN @result				
END

drop function ktramotaikhoan
-- test câu 19 
go
declare @result nvarchar(100)
print dbo.hamcau19(N'Hồ Quỳnh Hữu Phát','0978354865')
-- check lại 
												/* Hàm */
/* câu 1 :Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại. 
Tồn tại trả về 1, không tồn tại trả về 0*/
go
CREATE FUNCTION Cau1 (@Hoten nvarchar(50), @SĐT varchar(15))
RETURNS int
AS
BEGIN
    DECLARE @kq int
    IF  exists (SELECT * FROM customer WHERE Cust_name = @Hoten AND Cust_phone = @SĐT)
    BEGIN
        SET @kq = 1
    END
    ELSE
    BEGIN
        SET @kq = 0
    END
    RETURN @kq
END

DROP FUNCTION Cau1
--test--
print dbo.Cau1(N'Trần Đức Quý', '01638843209')
print dbo.Cau1(N'Bùi Minh Hiếu', '0916135004')
select * from customer
/* câu 2 : Tính mã giao dịch mới. 
Mã giao dịch tiếp theo được tính như sau: MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
-- cách ko nhập t_id max
go 
CREATE FUNCTION f_cau2()
returns varchar(10)
begin
	declare @new_mgd varchar(10) , @max_mgd varchar(10) , @trans_max_mgd varchar(10)
	set @max_mgd = (select max(t_id) from transactions)
	set @trans_max_mgd =(select cast(max(cast(t_id as int))+1 as varchar) from transactions)
	set @new_mgd = REPLICATE('0', LEN(@max_mgd)-LEN(cast(@max_mgd as int))) + @trans_max_mgd
	return @new_mgd
end
--
print dbo.f_cau2()
-- cách nhập t_id max
go
CREATE FUNCTION Cau2(@max_mgd varchar(20))
returns varchar(10)
begin
	declare @new_mgd varchar(10) , @trans_max_mgd varchar(10)
	set @max_mgd = (select max(t_id) from transactions)
	set @trans_max_mgd =(select cast(max(cast(t_id as int))+1 as varchar) from transactions)
	set @new_mgd = REPLICATE('0', LEN(@max_mgd)-LEN(cast(@max_mgd as int))) + @trans_max_mgd
	return @new_mgd
end
--
print dbo.Cau2('0000000405')
-- check max t_id
(select max(t_id) from transactions)
/* 3.Tính mã tài khoản mới. (định nghĩa tương tự như câu trên) */
-- cách ko nhập max ac_no
create function f_cau3()
returns varchar(20)
begin
	declare @new_mtk varchar(20) , @max_mtk varchar(20) , @trans_max_mtk varchar(20)
	set @max_mtk = (select max(Ac_no) from account)
	set @trans_max_mtk =(select cast(max(cast(Ac_no as int))+1 as varchar) from account)
	set @new_mtk = REPLICATE('0', LEN(@max_mtk)-LEN(cast(@max_mtk as int))) + @trans_max_mtk
	return @new_mtk
end
--
print dbo.f_cau3()
--
-- cách 2 : nhập max ac_no
go
create function Cau3(@max_mtk varchar(20))
returns varchar(20)
begin
	declare @new_mtk varchar(20) ,  @trans_max_mtk varchar(20)
	set @max_mtk = (select max(Ac_no) from account)
	set @trans_max_mtk =(select cast(max(cast(Ac_no as int))+1 as varchar) from account)
	set @new_mtk = REPLICATE('0', LEN(@max_mtk)-LEN(cast(@max_mtk as int))) + @trans_max_mtk
	return @new_mtk
end
--
print dbo.Cau3('1000000054')
-- check max ac_No
(select max(account.Ac_no) from account)
/* 4.Trả về tên chi nhánh ngân hàng nếu biết mã của nó.*/
go
create function Cau4 (@manganhang varchar(20))
returns nvarchar(100)
begin
	declare @tenchinhanh nvarchar(100)
	select @tenchinhanh=  Branch.BR_name from Branch where BR_id=  @manganhang
	return @tenchinhanh
end
--
print dbo.Cau4('VB002')
/*5.Trả về tên của khách hàng nếu biết mã khách.*/
go
create function Cau5 (@ma_kh varchar(20))
returns nvarchar(100)
begin
	declare @tenkhachhang nvarchar(100)
	select @tenkhachhang=  customer.Cust_name from customer where customer.Cust_id=  @ma_kh
	return @tenkhachhang
end
-- 
print dbo.Cau5('000006')
/*6.Trả về số tiền có trong tài khoản nếu biết mã tài khoản.*/
go
create function Cau6 (@ma_tk varchar(20))
returns int
begin
	declare @sotientaikhoan int
	select @sotientaikhoan=  account.ac_balance from account where account.Ac_no=  @ma_tk
	return @sotientaikhoan
end
--
print dbo.Cau6('1000000001')
/* 7.Trả về số lượng khách hàng nếu biết mã chi nhánh.*/
go
create function Cau7 (@ma_cn varchar(20))
returns int
begin
	declare @soluongkh int
	select @soluongkh=  count(distinct(customer.Cust_id))
							from customer inner join Branch on customer.Br_id=Branch.BR_id
							where Branch.Br_id=@ma_cn
	return @soluongkh
end
-- 
print dbo.Cau7('VB005') -- VB005là Băc Ninh

--select * from customer inner join Branch on customer.Br_id=Branch.BR_id

/* 8.Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am đến 3am*/
CREATE FUNCTION Cau8 (@ma_gd VARCHAR(20))
RETURNS NVARCHAR(50)
BEGIN
    DECLARE @nhanxet NVARCHAR(50)
    IF EXISTS (
        SELECT t_id
        FROM transactions
        WHERE 
            t_id = @ma_gd
            AND (
                (t_type = 1
                AND (t_time < '07:30:00.0000000' OR t_time > '12:00:00.0000000')
                AND (t_time < '13:30:00.0000000' OR t_time > '17:00:00.0000000')
                )
                OR
                (t_type = 0 AND t_time >= '00:00:00.0000000' AND t_time <= '03:00:00.0000000')
            )
    )
    BEGIN
        SET @nhanxet = N'Bất Thường'
    END
    ELSE
    BEGIN
        SET @nhanxet = N'Không Bất Thường'
    END

    RETURN @nhanxet
END
--
print dbo.Cau8('0000000204')
print dbo.Cau8('0000000203')