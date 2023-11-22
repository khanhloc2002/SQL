/* 1.Trả về tên chi nhánh ngân hàng nếu biết mã của nó. */
-- cách 1 : dùng hàm : 
create function Cau4_1 (@manganhang varchar(20))
returns nvarchar(100)
begin
	declare @tenchinhanh nvarchar(100)
	select @tenchinhanh=  Branch.BR_name from Branch where BR_id=  @manganhang
	return @tenchinhanh
end
--
print dbo.Cau4_1('VB002')
-- cách 2 : dùng proc : 
go
alter proc spGetBrName @macn varchar(20) , @ten nvarchar(50) out
as
begin
	set @ten = (select BR_name from Branch where BR_id = @macn)
	print @ten
end
-- test 
go
DECLARE @macn varchar(20) , @ten nvarchar(50)
SET @macn = 'VB001'
EXEC spGetBrName @macn, @ten out
--
select * from Branch
/*2.Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách.*/
-- chỉ có thể dùng proc
go
create proc get_name_ad_phone @makh varchar(20), @ten nvarchar(50) out, @ad nvarchar(100) out , @sdt varchar(12) out
as
begin
	select @ten =  Cust_name from customer where Cust_id = @makh
	select @ad =  Cust_ad from customer where Cust_id = @makh
	select @sdt =  Cust_phone from customer where Cust_id = @makh
print @ten
print @ad
print @sdt
end
--
go
declare @makh varchar(20),@ten nvarchar(50) , @ad nvarchar(100) ,@sdt varchar(12)
set @makh='000013'
exec get_name_ad_phone @makh,@ten out , @ad out , @sdt out
--
select * from customer where Cust_id='000013'

/* 3.In ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó.*/
go 
create proc list_customer @ma_cn varchar(50)
as
begin
	select Cust_name from customer where Br_id = @ma_cn
end
drop proc list_customer
-- test
exec list_customer 'VT009'

/* 4.Kiểm tra một khách hàng nào đó đã tồn tại trong hệ thống CSDL của ngân hàng chưa nếu biết: họ tên, số điện thoại của họ. 
Đã tồn tại trả về 1, ngược lại trả về 0*/
-- cả hai : dùng hàm đã viết ở query function
-- dùng proc
go
-- chưa fix ra lỗi
alter proc spTestCustomer @hoten nvarchar(100), @sdt varchar(13), @check int output
as
begin
	declare @dem int
	select @dem =count(customer.Cust_id) from customer where Cust_name = @hoten and Cust_phone = @sdt
	IF @dem>0
	BEGIN
		set @check = 1
	END
	ELSE
	BEGIN
		set @check = 0
	END
	print @check
END
-- 
DECLARE @hoten nvarchar(100), @sdt varchar(13), @check int 
SET @hoten = 'Trần Đức Quý'
set @sdt ='01638843209'
EXEC spTestCustomer @hoten, @sdt,@check out

/* 5.\Cập nhật số tiền trong tài khoản nếu biết mã số tài khoản và số tiền mới. Thành công trả về 1, thất bại trả về 0*/
-- vì là cập nhật nên chỉ sài proc 
--input: STK, số tiền mới
--output: 0, 1
go
alter PROC spCau5 @stk varchar(10), @newblance int , @kq int out
AS
BEGIN
	UPDATE account 
	set ac_balance = @newblance where Ac_no = @stk
	set @kq = case when @@ROWCOUNT > 0 then 1
					else 0
					end
	print @kq
END
--
select Ac_no , ac_balance from account
where Ac_no = '1000000001'
go
declare @kq int
exec spCau5 '1000000001' , 100000 , @kq out

/*6.Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. Thành công trả về 1, thất bại trả về 0*/
-- vì là cập nhật nên chỉ sài proc 
--input: mã kh
--output: 0, 1
go
create proc spcau6 @ma_kh varchar(20), @diachi nvarchar(100) , @kq int out 
as
begin
	update customer set Cust_ad = @diachi where Cust_id = @ma_kh
	set @kq = case when @@ROWCOUNT > 0 then 1
				   else 0
			  end
end
--
select * from customer where customer.Cust_id ='000001'
-- test
declare @kq int

exec spcau6 '000001' , N'215/90 VÕ VĂN KIỆT, PHƯỜNG THANH XUÂN, TP BUÔN MA THUỘT, ĐĂK LĂK' , @kq out
print @kq
--
/*7.Trả về số tiền có trong tài khoản nếu biết mã tài khoản.*/
-- cả hai
-- hàm đã làm ở query hàm 
-- proc
go 
create proc spCau7 @ma_tk varchar(20), @tientk int out
as
begin
	select @tientk=account.ac_balance from account 
					where account.Ac_no=@ma_tk
	print @tientk
end
--
go
declare @ma_tk varchar(20), @tientk int
set @ma_tk='1000000002'
exec spCau7 @ma_tk , @tientk out
--
/* 8.Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh.*/
-- chỉ dùng proc
go
create proc spCau8 @ma_cn varchar(20) , @slkh varchar(10) out , @tongtien varchar(50) out
as
begin
	select @slkh=count(distinct(customer.Cust_id)) from customer join Branch on customer.Br_id=Branch.BR_id
					where Branch.BR_id=@ma_cn
	select @tongtien=sum(account.ac_balance) from 
							 account inner join customer on account.cust_id=customer.Cust_id
									inner join Branch on customer.Br_id = Branch.BR_id
									where Branch.BR_id=@ma_cn
print N'Số lượng khách hàng là '+ @slkh
print N'Tổng tiền là ' +@tongtien
end
--
go
declare @ma_cn varchar(20) , @slkh varchar(10)  , @tongtien varchar(50) 
set @ma_cn='VB005'
exec spCau8 @ma_cn , @slkh out  , @tongtien out
-- test 
select distinct(customer.Cust_id), 
sum(account.ac_balance) from account inner join customer on account.cust_id=customer.Cust_id
									inner join Branch on customer.Br_id = Branch.BR_id
									where Branch.BR_id='VB005'
									group by customer.Cust_id

/*9.Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am đến 3am*/
-- làm được cả hai , hàm làm ở queery function
-- proc:
go
alter proc spCau9_1 @ma_gd varchar(20), @kq nvarchar(50) out
as 
begin
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
		begin
			set @kq = N'Bất thường'
			print @kq
		end
	else
		begin
			set @kq = N'Bình thường'
			print @kq
		end
end
--
go
declare @ma_gd varchar(20), @kq nvarchar(50) 
set @ma_gd='0000000208' -- test binh thường thì 203
exec spCau9_1 @ma_gd,@kq out
--
/*10.Trả về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: 
MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
-- cả hai , hàm làm ở query hàm rồi
-- proc : 
go
alter proc spCau10 @MDG varchar(20), @new_MDG varchar(20) output
AS
BEGIN 
	
	set @new_MDG = (SELECT REPLICATE('0', len(@MDG) - len(cast(@MDG as int) )) + cast(cast(@MDG as int)+1 as char) 
	from transactions
	where @MDG=transactions.t_id)
print @new_MDG
end
--
declare @MGD varchar(20),@new_MDG varchar(20)
set @MGD ='0000000205'
exec spCau10 @MGD, @new_MDG out

--
CREATE FUNCTION Cau10 (@MDG VARCHAR(20))
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @new_MDG VARCHAR(20)
    SET @new_MDG = (SELECT REPLICATE('0', LEN(@MDG) - LEN(CAST(@MDG AS INT)) ) + CAST(CAST(@MDG AS INT) + 1 AS VARCHAR(20)) 
        FROM transactions
        WHERE @MDG = transactions.t_id)
    
    RETURN @new_MDG;
END
--
print dbo.Cau10('0000000205')
--
/* 11.Thêm một bản ghi vào transaction nếu biết các thông tin ngày theo giao dịch 
thời gian giao dịch, số tài khoản , loại giao dịch ,số tiền giao dịch 
công việc cần làm bao gồm:
a. Ktra ngày và thời gian giao dịch có hợp lên không. nếu không ngừng xử lý 
b. ktra số tài khoản có tồn tại trong account ko
c. Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý
d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
e. Tính mã giao dịch mới
f. Thêm mới bản ghi vào bảng TRANSACTIONS
g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch
*/
--input : mấy cái nớ
--output : 0 là sai , 1 là thành công
go
create or alter proc Cau11 (
								@ngaygd date, 
								@tg time, 
								@stkgd varchar(20), 
								@loaigd char(1),
								@tiengd int, 
								@op int out)
as
begin
	--a
	if @ngaygd > getdate() or @ngaygd is null or @tg is null
	begin
		set @op=0
		return
	end
	--b
	if not exists (select 1 from account where Ac_no=@stkgd)
	begin
		set @op=0
		return
	end
	--c (@loaigd not in ('1','0')
	if (@loaigd<>0) and (@loaigd <>1) 
	begin
		set @op=0
		return
	end
	--d
	if @tiengd <= 0 
	begin
		set @op=0
		return
	end
	--e
	declare @mamoi varchar(20)
	set  @mamoi= dbo.f_cau2()
		--f
	insert into transactions
	values (@mamoi, @loaigd, @tiengd, @ngaygd, @tg, @stkgd) 
	if @@ROWCOUNT<=0
	begin  
		set @op=0
		return
	end
	--g
	update account
	set ac_balance= case when @loaigd ='0' then ac_balance-@tiengd
						 else ac_balance+@tiengd
					end
	where account.Ac_no=@stkgd
	if @@ROWCOUNT<=0
	begin
		set @op=0
		return
	end
end 
--
declare @op bit
exec Cau11 '2015-12-20', '03:19:00.0000000', '1000000041', '0' , 1, @op out
print @op
-- phải nhìn dữ liệu trước khi chạy và sau khi chạy 
select * from transactions
select * from account

-- 227373994
/*
12.	Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. Bao gồm những công việc sau:
a.	Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý
b.	Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý
c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý.
d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1
e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có. */
--
go
create or alter proc spTMtK (@mak varchar(20), 
							@loait char(2), 
							@tient int,  
							@tb int out)
as
begin
	--a
	if not exists (select Cust_id from customer where Cust_id=@mak)
	begin
		set @tb=0
		return
	end
	--b
	if (@loait<>0) and (@loait <>1)
	begin
		set @tb=0
		return
	end
	--c
	if @tient is null 
	begin
		set @tient=50000
	end
	if @tient <0
	begin
		set @tb=0
		return
	end
	--d
	declare @mtkm varchar(20), @matkm varchar(20)
	select @mtkm= MAX(Ac_no) from account
	set @matkm=left(@mtkm,len(@mtkm)-2) + cast((CAST(right(@mtkm,2) AS int) + 1) as varchar)
	
	--e
	insert into account 
	values (@matkm, @tient, @loait, @mak)
	set @tb=1
end

declare @thongb int
exec spTMtK '000018', '0',1, @thongb out
print @thongb
--
/*13.Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại. 
Tồn tại trả về 1, không tồn tại trả về 0*/
-- dùng cả hai , hàm làm ở query function rồi
go
alter proc Cau13 @hoten nvarchar(100), @sdt varchar(15)
as
begin
declare @kq int
 if exists (SELECT * FROM customer WHERE Cust_name = @hoten AND Cust_phone = @sdt)
	begin
	set @kq=1
	end
	else
	begin
	set @kq=0
	end
print @kq
end
--
exec Cau13 N'Bùi Minh Hiếu', '0916135004'
exec Cau13 N'Trần Đức Quý', '01638843209'
--
/* 14.Tính mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: 
MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch*/
-- nhưu câu 13
go
alter proc Cau14
as
begin
declare @new_mgd varchar(10) , @max_mgd varchar(10) , @trans_max_mgd varchar(10)
	set @max_mgd = (select max(t_id) from transactions)
	set @trans_max_mgd =(select cast(max(cast(t_id as int))+1 as varchar) from transactions)
	set @new_mgd = REPLICATE('0', LEN(@max_mgd)-LEN(cast(@max_mgd as int))) + @trans_max_mgd
	print @new_mgd
end
-- 
exec Cau14 
--
(select max(t_id) from transactions)
/*15.Tính mã tài khoản mới. (định nghĩa tương tự như câu trên) */
-- y câu 13 
go 
create proc Cau15
as 
begin
	declare @new_mtk varchar(20) , @max_mtk varchar(20) , @trans_max_mtk varchar(20)
	set @max_mtk = (select max(Ac_no) from account)
	set @trans_max_mtk =(select cast(max(cast(Ac_no as int))+1 as varchar) from account)
	set @new_mtk = REPLICATE('0', LEN(@max_mtk)-LEN(cast(@max_mtk as int))) + @trans_max_mtk
	print @new_mtk
end
--
exec Cau15
-- 
/* 16.Trả về tên chi nhánh ngân hàng nếu biết mã của nó.*/
go
create proc Cau16 (@manganhang varchar(20))
as
begin
	declare @tenchinhanh nvarchar(100)
	select @tenchinhanh=  Branch.BR_name from Branch where BR_id=  @manganhang
	print @tenchinhanh
end
--
exec Cau16 'VB002'


select t_id from transactions
select Ac_no from account
/* 17.Trả về tên của khách hàng nếu biết mã khách.*/
go
alter proc Cau17 (@ma_kh varchar(20))
as
begin
	declare @tenkhachhang nvarchar(100)
	select @tenkhachhang=  customer.Cust_name from customer where customer.Cust_id= @ma_kh
	print @tenkhachhang
end
--
exec Cau17 '000006'
/*18.Trả về số tiền có trong tài khoản nếu biết mã tài khoản.*/
go
alter proc Cau18 @ma_tk varchar(20)
as
begin
	declare @sotientaikhoan int
	select @sotientaikhoan=  account.ac_balance from account where account.Ac_no=  @ma_tk
	print @sotientaikhoan
end
--
exec Cau18 '1000000001'
--
/*19.Trả về số lượng khách hàng nếu biết mã chi nhánh.*/
alter proc Cau19 @ma_cn varchar(20)
as
begin 
declare @soluongkh int
	select @soluongkh=  count(distinct(customer.Cust_id))
							from customer inner join Branch on customer.Br_id=Branch.BR_id
							where Branch.Br_id=@ma_cn
	print @soluongkh
end
--
exec Cau19 'VB005'
/*20 Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. 
Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am -> 3am*/
go 
create proc Cau20 @ma_gd varchar(50)
as 
begin
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

    print @nhanxet
end
--
exec Cau20 '0000000208'
exec Cau20 '0000000204'
--
/*22.Sinh mã chi nhánh tự động. Sơ đồ thuật toán của module được mô tả như sau:*/
go
create function dbo.GenerateNewBrID (@mavung varchar(2))
returns varchar(5)
as 
begin
     declare @newbrid varchar(5)
	 declare @iMax int
	 declare @a varchar(3)
	 if not ( @mavung in ('VB','VT','VN'))
	 begin
	      set @newbrid = @mavung + '001'
     end
	 else
	 begin
	      select @a = right(BR_id,3) from Branch where left(BR_id,2) = @mavung
	      set @iMax = cast(substring(@a,1,3) as int ) + 1
		  set @newbrid = @mavung + right( '000' + cast(@iMax as varchar(3)),3)
	 end
	 return @newbrid
end
select dbo.GenerateNewBrID('VN')