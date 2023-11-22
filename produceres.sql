/*trả về số lượng tài khoản của khách hàng nếu biết mã khách : 
--input : số mã khách varchar(10)
--output : số lượng tài khoản - int */
use Bank
go
create proc spGetsoluongtaikhoan @makh varchar(10), @soluongtaikhoan int out
as
begin
	select @soluongtaikhoan = count(account.Ac_no) 
									from customer join account on customer.Cust_id=account.cust_id
									where @makh=customer.Cust_id
end
-- test : 
go
declare @makh nvarchar(10), @soluongtaikhoan int 
--set @makh ='000001'
exec spGetsoluongtaikhoan '000001' ,@soluongtaikhoan out
print @soluongtaikhoan
 
-- chuyển đổi daafuf số điện thoại di động  theo quy định vủa bộ Thông tin và truyền thông nếu biết mã khách của họ 
-- input : mã khách 
-- ouput số điện thoại mới 
go
CREATE PROCEDURE spCHUYENDOI (@maKH varchar(10), @Ktra BIT output )
as
begin 
declare @sdt varchar (20), @sdtmoi varchar (20)
select @sdt = customer.Cust_phone from customer where Cust_id = @maKH
SET @sdtmoi =
    CASE 
        WHEN @sdt LIKE '0120%' THEN '070' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0121%' THEN '071' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0122%' THEN '072' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0126%' THEN '076' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0128%' THEN '078' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0123%' THEN '083' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0124%' THEN '084' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0125%' THEN '085' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0127%' THEN '087' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0129%' THEN '089' + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '0162%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0163%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0164%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0165%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0166%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0167%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0168%'  THEN '03'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '0169%'  THEN '03'  + RIGHT(@sdt, 7)
        WHEN @sdt LIKE '018%'  THEN '05'  + RIGHT(@sdt, 7)
		WHEN @sdt LIKE '019%'  THEN '05'  + RIGHT(@sdt, 7)
        ELSE @sdt
    END
update customer set Cust_phone = @sdtmoi where Cust_id= @maKH 
if @@ROWCOUNT >0 
BEGIN 
	set @Ktra = 1
end
else
begin
	set @Ktra = 0
end
end 

-- test câu 1 : 
go
--select * from customer
declare @b varchar(10), @ret BIT 
set @b = '000012'
exec spCHUYENDOI @b, @ret output
print @ret
select * from customer


/* câu 2 : kiểm tra trong vòng 10 năm trở lại đây khách hàng có thực hiện giao dịch nào không, nếu
biết mã khách hàng của họ ? Nếu có hãy trừ 50.000 phí duy trì tài khoản ? 
input : mã khách hàng 
output : nhận xét có hay ko ? cập nhật tài khoản mới sau khi trừ 50.000
*/
go 
alter proc spSoduTaiKhoanmoi @makh varchar(10), 								
								
								@taikhoanmoi int out
as
begin
	declare @count int , 
			@Sodutaikhoan int, 
			@phigiaodich int = 50000
	SELECT @count = count(t_id)
	FROM transactions INNER JOIN account ON account.Ac_no = transactions.ac_no
						INNER JOIN customer ON account.cust_id = customer.Cust_id
	WHERE t_date >= DATEADD(year, -10, GETDATE())
	and customer.Cust_id = @makh
	
	print @count
	IF @count > 0 
	BEGIN
		PRINT N'Có thực hiện giao dịch'
		--SET @taikhoanmoi = @Sodutaikhoan - @phigiaodich
		--print N'Có thực hiện giao dịch'
		--print @taikhoanmoi
	END
	ELSE
	BEGIN
		--SET @taikhoanmoi=@Sodutaikhoan	
		print N'Không thực hiện giao dịch '
		--print @taikhoanmoi
	END
end
-- test câu 2 : 
go
DECLARE @makh VARCHAR(10), 
        @taikhoanmoi INT 

EXEC spSoduTaiKhoanmoi '000031',  @taikhoanmoi out

PRINT @taikhoanmoi

SELECT *
	FROM transactions INNER JOIN account ON account.Ac_no = transactions.ac_no
						INNER JOIN customer ON account.cust_id = customer.Cust_id
	WHERE t_date >= DATEADD(year, -10, GETDATE())
	
 select DATEADD(year, -10, GETDATE())
/*câu 3 Kiểm tra khách hàngthực hiện giao dịch gần đây nhất vào thứ mấy? 
(thứ hai, thứ ba, thứ tư,…, chủ nhật) 
và vào mùa nào (mùa xuân, mùa hạ, mùa thu, mùa đông)? 
nếu biết mã khách */ 
go 
alter proc  thuhiengiaodich @makh nvarchar(10) , @thumay nvarchar(10) out, @mua nvarchar(10) out 
as
begin 
	declare @ngaygiaodich nvarchar(20), @season int 
	SELECT TOP 1
    @ngaygiaodich = CAST(DATEPART(WEEKDAY, transactions.t_date) AS NVARCHAR(20)),
    @thumay = CASE @ngaygiaodich
                 WHEN '1' THEN N'Chủ Nhật'
                 WHEN '2' THEN N'Thứ Hai'
                 WHEN '3' THEN N'Thứ Ba'
                 WHEN '4' THEN N'Thứ Tư'
                 WHEN '5' THEN N'Thứ Năm'
                 WHEN '6' THEN N'Thứ Sáu'
                 WHEN '7' THEN N'Thứ Bảy'
               END,
    @season = DATEPART(QUARTER, transactions.t_date),
    @mua = CASE @season
               WHEN 1 THEN N'Mùa Xuân'
               WHEN 2 THEN N'Mùa Hè'
               WHEN 3 THEN N'Mùa Thu'
               ELSE N'Mùa Đông'
           END
				FROM transactions
				INNER JOIN account ON account.Ac_no = transactions.ac_no
				INNER JOIN customer ON account.cust_id = customer.Cust_id
			where customer.Cust_id=@makh
			if  @ngaygiaodich IS NOT NULL
			BEGIN
				PRINT N'Gần đây nhất, Khách hàng sẽ thực hiện giao dịch' + @thumay + N' và vào mùa ' + @mua
			END
			ELSE
			BEGIN
				PRINT N'Khách hàng không thực hiện giao dịch'
			END
end 
-- test câu 3: 
go
DECLARE @makh NVARCHAR(10)
DECLARE @thumay NVARCHAR(10)
DECLARE @mua NVARCHAR(10)

SET @makh = '000001'

EXEC thuhiengiaodich @makh, @thumay OUTPUT, @mua OUTPUT

--PRINT @thumay
--PRINT @mua

--4.Đưa ra nhận xét về nhà mạng của khách hàng đang sử dụng nếu biết mã khách? (Viettel, Mobi phone, Vinaphone, Vietnamobile, khác)
go
alter proc nhamang @makh nvarchar(10) , @nhamang nvarchar(10) out
as 
begin
declare  @sdt nvarchar(30)	
select @sdt = customer.Cust_phone from customer
				where customer.Cust_id=@makh
select	@nhamang  = case 
	 WHEN @sdt LIKE '086%' 
		OR @sdt LIKE '09[6,7,8]%'
		OR @sdt LIKE '016[2,3,4,5,6,7,8,9]%'
		OR @sdt LIKE '03[2,3,4,5,6,7,8,9]%'  THEN 'Viettel'
	 WHEN @sdt LIKE '088%'
		OR @sdt LIKE '09[1,4]%'
		OR @sdt LIKE '012[3,4,5,7,9]%'
		OR @sdt LIKE '08[1,2,3,4,5]%'		 THEN 'VinaPhone'
	 WHEN @sdt LIKE '089%'
		OR @sdt LIKE '09[0,3]%'
		OR @sdt LIKE '012[0,1,2,6,8]%'
		OR @sdt LIKE '07[0,6,7,8,9]%'	     THEN 'MoBiphone' 
	 WHEN @sdt LIKE '092%'
		OR @sdt LIKE '056%'
		OR @sdt LIKE '058%'				     THEN 'Vietnamobile'
	ELSE N'Khác'
END

print (N'Số điện thoại của khách hàng thuộc nhà mạng ' + @nhamang)
end
--test câu 4 :
go
declare @makh nvarchar(10),  @nhamang nvarchar(10)
SET @makh = '000001'
EXEC nhamang @makh,@nhamang OUTPUT
/* 5.Nếu biết mã khách, hãy kiểm tra số điện thoại của họ là số tiến, số lùi hay số lộn xộn. 
Định nghĩa: trừ 3 số đầu tiên, các số còn lại tăng dần gọi là số tiến, ví dụ: 098356789 là số tiến */ -- chưa xong
go
ALTER proc ktrasdt @makh nvarchar(10) ,@nhanxet nvarchar(30) out
as 
begin
DECLARE @Phone NVARCHAR(15)
SELECT @Phone = Cust_phone from customer
WHERE customer.Cust_name = @makh

IF @Phone IS NOT NULL
BEGIN
    DECLARE @RemovePhone NVARCHAR(12) 
	SET @RemovePhone= RIGHT(@Phone, LEN(@Phone) - 3)
    
    IF LEN(@Phone) >= 10
    BEGIN
        DECLARE @tangdan BIT = 1
        DECLARE @giamdan BIT = 1
        DECLARE @conlai INT = 1

        WHILE @conlai < LEN(@RemovePhone)
        BEGIN
            IF CAST(SUBSTRING(@RemovePhone, @conlai, 1) AS INT) >= CAST(SUBSTRING(@RemovePhone, @conlai + 1, 1) AS INT)
                SET @tangdan = 0

            IF CAST(SUBSTRING(@RemovePhone, @conlai, 1) AS INT) <= CAST(SUBSTRING(@RemovePhone, @conlai + 1, 1) AS INT)
                SET @giamdan = 0

            SET @conlai = @conlai + 1
        END

         IF @tangdan = 1
                SET @nhanxet = N'Số điện thoại của khách hàng tăng dần.'
            ELSE IF @giamdan = 1
                SET @nhanxet = N'Số điện thoại của khách hàng giảm dần.'
            ELSE
                SET @nhanxet = N'Số điện thoại của khách hàng không tăng cũng không giảm.'
        END
        ELSE
            SET @nhanxet = N'Số điện thoại không hợp lệ.'
END
ELSE
    PRINT N'Không tìm thấy khách hàng'
end 
-- test 
go
declare @makh nvarchar(10),  @nhanxet nvarchar(10)
SET @makh = '000005'
EXEC ktrasdt @makh,@nhanxet OUTPUT
/*6. Nếu biết mã khách, hãy kiểm tra xem khách thực hiện giao dịch gần đây nhất vào buổi nào(sáng, trưa, chiều, tối, đêm)?*/
go
alter proc gettimetransactions @makh nvarchar(10), @buoi nvarchar(20) out
as
begin 
declare @thoigiangiaodich int
select @thoigiangiaodich =	(select top 1 DATEPART(hour,transactions.t_time) from 
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_id=@makh
							order by t_date)
select	   @buoi = case 
					when  @thoigiangiaodich between 5 and 9 then N'buổi sáng'
					when  @thoigiangiaodich between 10 and 12 then N' buổi trưa'
					when  @thoigiangiaodich between 13 and 17 then N' buổi chiều'
					when  @thoigiangiaodich between 16 and 21 then N' buổi tối'
					else  N'ban đêm'
				end
print N'Khách hàng có mã số cần tìm thực hiện giao dịch vào' +@buoi
end
-- test câu 6 : 
declare @makh nvarchar(10),  @buoi nvarchar(20)
SET @makh = '000005'
EXEC gettimetransactions @makh,@buoi OUTPUT
/* 7.	Nếu biết số điện thoại của khách, hãy kiểm tra chi nhánh ngân hàng mà họ đang sử dụng thuộc miền nào? 
Gợi ý: nếu mã chi nhánh là VN =miền nam, VT =miền trung, VB =miền bắc, còn lại: bị sai mã.*/
go
alter proc getchinhanh @sdt nvarchar(12), @chinhanh nvarchar(20) out
as
begin
declare @machinhanh char(5)
select @machinhanh = (select distinct(Branch.BR_id) from  
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_phone=@sdt)
select	@chinhanh = case
				when @machinhanh like 'VN%' then N'Miền Nam' 
				when @machinhanh like 'VT%' then N'Miền Trung' 
				when @machinhanh like 'VB%' then N'Miền Bắc' 
				else N'Mã Sai'
			end
print @chinhanh
end
--test câu 7 : 
go
declare @sdt nvarchar(12), @chinhanh nvarchar(20) 
SET @sdt = '01638843209'
EXEC getchinhanh @sdt,@chinhanh OUTPUT


/* 8.	Căn cứ vào số điện thoại của khách, hãy nhận định vị khách này dùng dịch vụ di động của hãng nào: 
Viettel, Mobi phone, Vina phone, hãng khác.*/
go
create proc gethangdienthoai @sdt nvarchar(12), @hang nvarchar(20) out
as
begin

select @sdt= customer.Cust_phone from customer
						where customer.Cust_phone=@sdt
select @hang =case 
	when @sdt LIKE '086%' 
	  OR @sdt LIKE '09[6,7,8]%'
	  OR @sdt LIKE '016[2,3,4,5,6,7,8,9]%'
	  OR @sdt LIKE '03[2,3,4,5,6,7,8,9]%' THEN 'Viettel'
	WHEN @sdt LIKE '088%'
	  OR @sdt LIKE '09[1,4]%'
	  OR @sdt LIKE '012[3,4,5,7,9]%'
	  OR @sdt LIKE '08[1,2,3,4,5]%'		 THEN 'VinaPhone'
	WHEN @sdt LIKE '089%'
	  OR @sdt LIKE '09[0,3]%'
	  OR @sdt LIKE '012[0,1,2,6,8]%'
	  OR @sdt LIKE '07[0,6,7,8,9]%'	     THEN 'MoBiFone' 
	WHEN @sdt LIKE '092%'
	  OR @sdt LIKE '056%'
	  OR @sdt LIKE '058%'				 THEN 'Vietnamobile'
	ELSE   N'Khác'
END
print @hang
end
--test câu 8 : 
go 
declare @sdt nvarchar(12), @hang nvarchar(20) 
SET @sdt = '01638843209'
EXEC gethangdienthoai @sdt,@hang OUTPUT

/* 9.Hãy nhận định khách hàng ở vùng nông thôn hay thành thị nếu biết mã khách hàng của họ. 
Gợi ý: nông thôn thì địa chỉ thường có chứa chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện”*/
go
alter proc getdiachi @makh nvarchar(10), @nhandinh nvarchar(20) out
as
begin
select	@nhandinh =case
			when customer.Cust_ad like N'%thôn%'
				OR customer.Cust_ad LIKE N'%xóm%'
				OR customer.Cust_ad LIKE N'%đội%'
				OR customer.Cust_ad LIKE N'%xã%'
				OR customer.Cust_ad LIKE N'%huyện%' THEN N'Nông thôn'
			ELSE N'Thành Phố'
		end
from customer
where customer.Cust_id=@makh
print N'Khách hàng có mã số vừa nhập sống ở ' +@nhandinh
end
--test câu 9 : 
go 
declare @makh nvarchar(12), @nhandinh nvarchar(20) 
SET @makh = '000005'
EXEC getdiachi @makh,@nhandinh OUTPUT

/* 10.	Hãy kiểm tra tài khoản của khách nếu biết số điện thoại của họ. 
Nếu tiền trong tài khoản của họ nhỏ hơn không hoặc bằng không 
nhưng 6 tháng gần đây không có giao dịch thì hãy đóng tài khoản bằng cách cập nhật ac_type = ‘K’*/


/* 11. Kiểm tra mã số giao dịch gần đây nhất của khách là số chẵn hay số lẻ nếu biết mã khách. */
go
alter proc getmasogiaodich @makh nvarchar(10), @nhandinh nvarchar(100) out
as
begin
declare @MasoGD int 
select @MasoGD= (select top 1 transactions.t_id from 
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_id=@makh
							order by t_date desc)
	if @MasoGD %2=0 
		begin
			set @nhandinh= N'Đây là mã số giao dịch chẵn'
		end
	else
		begin
			set @nhandinh= N'Đây là mã số giao dịch lẻ'
		end
	print @nhandinh
end
--test câu 11 : 
go 
declare @makh nvarchar(10), @nhandinh nvarchar(20) 
SET @makh = '000005'
EXEC getmasogiaodich @makh,@nhandinh OUTPUT
/* 12.Trả về số lượng giao dịch diễn ra trong khoảng thời gian nhất định (tháng, năm), 
tổng tiền mỗi loại giao dịch là bao nhiêu (bao nhiêu tiền rút, bao nhiêu tiền gửi)*/

/* 13.Trả về số lượng chi nhánh ở một địa phương nhất định.*/
go
alter proc getsoluongchinhanh @diaphuong nvarchar(30), @soluong nvarchar(100) out
as
begin
select @soluong= count (distinct Branch.Br_id) 
					from  Branch
					where BR_name like @diaphuong
print N'Số chi nhánh tại địa phương là ' +@soluong
end
-- test câu 12 :
go
declare @diaphuong nvarchar(30), @soluong nvarchar(100)
SET @diaphuong = N'%Hà Nội'
EXEC getsoluongchinhanh @diaphuong,@soluong OUTPUT

/* 14.Trả về tên khách hàng có nhiều tiền nhất là trong tài khoản, số tiền hiện có trong tài khoản đó là bao nhiêu? 
Tài khoản này thuộc chi nhánh nào?*/
go
alter PROCEDURE GetCustomerWithMostMoney
AS
BEGIN
    SELECT TOP 1
        customer.Cust_name AS [Tên khách hàng],
        account.ac_balance AS [Số tiền hiện có],
        Branch.BR_name AS [Tên chi nhánh]
from transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							order by account.ac_balance desc
-- lấy bản ghi cuối dãy ghi (nên thêm top 1) 
END
-- test 
EXEC GetCustomerWithMostMoney

/* 15.Trả về số lượng khách của một chi nhánh nhất định*/
go
create proc getsoluongkhachhang @machinhanh nvarchar(10), @soluong nvarchar(10) out
as
begin
select @soluong= count (distinct customer.Cust_id) 
					from  customer inner join Branch on customer.Br_id=Branch.Br_id
					where Branch.BR_id=@machinhanh
print N'Số chi nhánh tại địa phương có mã chi nhánh  ' +@machinhanh + N' là ' +@soluong
end
--test câu 15
go
declare  @machinhanh nvarchar(10), @soluong nvarchar(10) 
SET @machinhanh = 'VN014'
EXEC getsoluongkhachhang @machinhanh,@soluong OUTPUT

/*16.Tìm tên, số điện thoại, chi nhánh của khách thực hiện giao dịch, nếu biết mã giao dịch.*/
go
alter proc getthongtin @magiaodich nvarchar(10), @ten nvarchar(100) out,@sdt nvarchar(12) out,@chinhanh nvarchar(100) out
as
begin
select @ten=customer.Cust_name,
		@sdt=customer.Cust_phone,
		@chinhanh=Branch.BR_name
		from transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where transactions.t_id=@magiaodich
print N' Với mã giao dịch '+ @magiaodich + N'thì thông tin là :' 
+ N'Tên khách hàng :' +@ten 
+ N'Số điện thoại' +@sdt
+N'chi nhánh '+@chinhanh
end
--test 
go
declare @magiaodich nvarchar(10), @ten nvarchar(100),@sdt nvarchar(12),@chinhanh nvarchar(100)
set @magiaodich ='0000000387'
EXEC  getthongtin @magiaodich , @ten  out,@sdt  out,@chinhanh  out

/* 17.	Hiển thị danh sách khách hàng gồm: họ và tên, số điện thoại, số lượng tài khoản đang có và nhận xét. 
Nếu < 1 tài khoản  “Bất thường”, còn lại “Bình thường”*/
go
alter PROCEDURE GetCustomerAccountInfo
AS
BEGIN
    SELECT
        customer.Cust_name AS [Họ và Tên],
        customer.Cust_phone AS [Số điện thoại],
        COUNT(account.Ac_no) AS [Số lượng tài khoản],
        CASE
            WHEN COUNT(account.Ac_no) < 1 THEN N'Bất thường'
            ELSE N'Bình thường'
        END AS [Nhận xét]
    FROM customer 
    LEFT JOIN account  ON customer.Cust_id = account.cust_id
    GROUP BY customer.Cust_name, customer.Cust_phone
END
-- test : 
go
EXEC GetCustomerAccountInfo

-- sài table ( chưa xong , mai fix )
go
ALTER PROCEDURE testthu
    @ten nvarchar(100) out,
    @sdt nvarchar(12) out,
    @soluongtaikhoan int out,
    @nhanxet nvarchar(20) out
AS
BEGIN 
    SELECT
        @ten = customer.Cust_name,
        @sdt = customer.Cust_phone,
        @soluongtaikhoan = COUNT(account.Ac_no)
    FROM customer 
    LEFT JOIN account ON customer.Cust_id = account.cust_id
    GROUP BY Cust_name, Cust_phone

    SELECT @nhanxet = 
        CASE
            WHEN @soluongtaikhoan < 1 THEN N'Bất thường'
            ELSE N'Bình Thường'
        END

    -- Trả về kết quả dưới dạng bảng
    SELECT 
        @ten AS [Họ và Tên],
        @sdt AS [Số điện thoại],
        @soluongtaikhoan AS [Số lượng tài khoản],
        @nhanxet AS [Nhận xét]
END
-- chưa ra 

-- /* 18.Nhận xét tiền trong tài khoản của khách nếu biết số điện thoại. <100.000: ít, < 5.000.000  trung bình, còn lại: nhiều*/
go
alter PROCEDURE nhanxettaikhoan @sdt varchar(12)
AS
BEGIN
    SELECT
        customer.Cust_name AS [Họ và Tên],
		account.ac_balance as [Số tiền trong tài khoản],
        CASE
            WHEN account.ac_balance < 100000 THEN N'Ít'
            WHEN account.ac_balance < 5000000 THEN N'Trung Bình'
			else N'Nhiều'
        END AS [Nhận xét]
    FROM customer 
    LEFT JOIN account  ON customer.Cust_id = account.cust_id
	where customer.Cust_phone=@sdt
END
--
-- test : 
go
EXEC nhanxettaikhoan '01283388103'

/* 19.Kiểm tra khách hàng đã mở tài khoản tại ngân hàng hay chưa nếu biết họ tên và số điện thoại của họ.*/
-- input :họ tên,sđt
-- output : tự in 
go
alter proc ktramotaikhoan @hoten nvarchar(100), @sdt varchar(12)
as
begin
	declare @demsotaikhoan int
	select @demsotaikhoan=count(account.Ac_no)  
		FROM customer LEFT JOIN account  ON customer.Cust_id = account.cust_id
		where customer.Cust_name=@hoten
		and customer.Cust_phone=@sdt
	if @demsotaikhoan >0
		print N'Đã có tài khoản'
	else
		print N'Chưa có tài khoản'				
end
-- test câu 19 
go
declare  @hoten nvarchar(100), @sdt varchar(12)
SET @hoten =N'Hồ Quỳnh Hữu Phát'
set @sdt ='0978354865'
EXEC  ktramotaikhoan  @hoten , @sdt 
-- check lại 
select customer.Cust_name , customer.Cust_phone, count(account.Ac_no ) 
		from transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id							 
							group by customer.Cust_name , customer.Cust_phone
							having count (account.Ac_no)>0

/* 20.Điều tra số tiền trong tài khoản của khách có hợp lệ hay không nếu biết mã khách? 
(Hợp lệ: tổng tiền gửi – tổng tiền rút = số tiền hiện có trong tài khoản). 
Nếu hợp lệ, đưa ra thông báo “Hợp lệ”, ngược lại hãy cập nhật lại tài khoản 
sao cho số tiền trong tài khoản khớp với tổng số tiền đã giao dịch 
(ac_balance = sum(tổng tiền gửi) – sum(tổng tiền rút)*/
go
alter proc dtrataikhoan @makhach varchar(20), @tientaikhoan varchar(20) out
as
begin 
declare @tienrut int , @tiengui int 
select @tienrut= sum(transactions.t_amount)  
									from transactions inner join account on account.Ac_no= transactions.ac_no							
									inner join customer on account.cust_id=customer.Cust_id
									where customer.Cust_id=@makhach and transactions.t_type=0
select @tiengui= sum(transactions.t_amount)  
									from transactions inner join account on account.Ac_no= transactions.ac_no							
									inner join customer on account.cust_id=customer.Cust_id
									where customer.Cust_id=@makhach and transactions.t_type=1
select @tientaikhoan =account.ac_balance 
									from  transactions inner join account on account.Ac_no= transactions.ac_no							
									inner join customer on account.cust_id=customer.Cust_id
										where customer.Cust_id=@makhach
	if @tientaikhoan=@tiengui-@tienrut
		begin
			print N'Hợp Lệ'
		end
		else
		begin 
			print N'Không hợp lệ'
			set @tientaikhoan=@tiengui-@tienrut
			print N'Số tiền hiện tại là '+ @tientaikhoan 
	end
--SELECT @tientaikhoan as Sotienhientai
end
-- test câu 20 : 
go
declare  @makhach varchar(20), @tientaikhoan varchar(20)
SET @makhach ='000012'
EXEC dtrataikhoan  @makhach, @tientaikhoan  out

/* 21:Kiểm tra chi nhánh có giao dịch gửi tiền nào diễn ra vào ngày chủ nhật hay không nếu biết mã chi nhánh? 
Nếu có, trả về lần giao dịch.*/
go
create proc getgiaodichcuoituan @machinhanh varchar(10), @solangiaodich varchar(15) out 
as
begin
select @solangiaodich= count(distinct transactions.t_id) 
							from transactions inner join account on account.Ac_no= transactions.ac_no							
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where Branch.BR_id=@machinhanh 
							and datepart(WEEKDAY, transactions.t_date) =1
if @solangiaodich>0
	begin	
		print N'Giao dịch cuối tuần thành phố Đà Nẵng : '
		print @solangiaodich
	end
else 
	begin
		print N'Không có'
	end
end
-- test 
go 
declare  @machinhanh varchar(10), @solangiaodich varchar(15)
SET @machinhanh ='VN012'
EXEC getgiaodichcuoituan @machinhanh , @solangiaodich  out 
--
/* 22.In ra dãy số lẻ từ 1 – n, với n là giá trị tự chọn*/
go
alter proc daysole @n int
AS
BEGIN
   declare @count int
set @count=1
while @count <@n
begin
	if @count %2!=0
	begin
		print @count
	end
	set @count+=2	
end
end
-- test câu 22 : 
go
DECLARE @n int
SET @n = 10  -- Thay đổi giá trị n tùy ý
EXEC daysole @n
/* In ra dãy số chẵn từ 0 – n, với n là giá trị tự chọn*/
go
create proc daysochan @n int
AS
BEGIN
declare @count int
set @count=0
while @count <=@n
begin
	if @count %2=0
	begin
		print @count
	end
	set @count+=1	
end
end
-- test câu 23 : 
go
DECLARE @n int
SET @n = 10  -- Thay đổi giá trị n tùy ý
EXEC daysochan @n
--
/* 24.In ra 100 số đầu tiền trong dãy số Fibonaci*/
go
alter proc fibonanci
AS
begin
    DECLARE @fibo float
    DECLARE @n1 float
    DECLARE @n2 float
    DECLARE @count float

    SET @n1 = 0
    SET @n2 = 1
    SET @count = 0

    WHILE @count < 100
    BEGIN
        IF @count = 0
        BEGIN
            SET @fibo = 0
        END
        ELSE IF @count = 1
        BEGIN
            SET @fibo = 1
        END
        ELSE
        BEGIN
            SET @fibo = @n1 + @n2
            SET @n1 = @n2
            SET @n2 = @fibo
        END

        PRINT @fibo

        SET @count = @count + 1
    END
END
-- test 
exec fibonanci
--
/* 25a tam giác vuông*/
go
create proc tamgiacvuong
as
begin
	declare @tamgiac nvarchar(10), @d int = 1
	set @tamgiac = '*'
	while @d < 6
	begin	
		PRINT @tamgiac
		SET @tamgiac = @tamgiac + '*'
		SET @d +=1
	END
end
-- 
exec tamgiacvuong
/*25. tam giác cân*/
go
create proc tamgiaccan
as
begin
	declare @a int, @b int
	set @a=0
	set @b=5
	while @b>=1
	begin
		print (space(@b) + replicate('*',@a) + replicate('*',@a+1))
		set @a +=1
		set @b -=1
	end
end
--
exec tamgiaccan
--
/*25c. bảng cửu chương*/
go
create proc bangcuuchuong 
as
begin
	DECLARE @i INT = 1
	DECLARE @j INT
	WHILE @i <= 10
	BEGIN
		SET @j = 1
		DECLARE @row NVARCHAR(200) = ''
		WHILE @j <= 10
		BEGIN
			DECLARE @result NVARCHAR(10) = CAST(@i * @j AS NVARCHAR(10))
			SET @row = @row + CAST(@i AS NVARCHAR) + 'x' + CAST(@j AS NVARCHAR) + '=' + RIGHT(REPLICATE('   ',1) + @result,3) + '  '
			SET @j = @j + 1
		END
		PRINT @row
		SET @i = @i + 1
	END
end
--
exec bangcuuchuong 
/*25e. .....*/
go
alter PROCEDURE tienhaylui @makh varchar(10)
AS
BEGIN
    DECLARE @Phone NVARCHAR(15)

    SELECT @Phone = Cust_phone
    FROM customer
    WHERE customer.Cust_id = @makh

    IF @Phone IS NOT NULL
    BEGIN
        DECLARE @RemovePhone NVARCHAR(12) 
        SET @RemovePhone = CASE
            WHEN LEN(@Phone) = 10 THEN RIGHT(@Phone, LEN(@Phone) - 3) -- Trường hợp có 10 số, bỏ 3 số đầu
            WHEN LEN(@Phone) = 11 THEN RIGHT(@Phone, LEN(@Phone) - 4) -- Trường hợp có 11 số, bỏ 4 số đầu
            ELSE NULL -- Trường hợp không hợp lệ
        END
        
        IF @RemovePhone IS NOT NULL
        BEGIN
            DECLARE @tangdan BIT = 1
            DECLARE @giamdan BIT = 1
            DECLARE @conlai INT = 1

            WHILE @conlai < LEN(@RemovePhone)
            BEGIN
                IF CAST(SUBSTRING(@RemovePhone, @conlai, 1) AS INT) >= CAST(SUBSTRING(@RemovePhone, @conlai + 1, 1) AS INT)
                    SET @tangdan = 0

                IF CAST(SUBSTRING(@RemovePhone, @conlai, 1) AS INT) <= CAST(SUBSTRING(@RemovePhone, @conlai + 1, 1) AS INT)
                    SET @giamdan = 0

                SET @conlai = @conlai + 1
            END

            IF @tangdan = 1
                PRINT N'Số điện thoại của khách hàng là số tiến.'
            ELSE IF @giamdan = 1
                PRINT N'Số điện thoại của khách hàng là số lùi.'
            ELSE
                PRINT N'Số điện thoại của khách hàng là số lộn xộn.'
        END
        ELSE
            PRINT N'Số điện thoại không hợp lệ.'
    END
    ELSE
        PRINT N'Không tìm thấy khách hàng có mã ' + CAST(@makh AS NVARCHAR(10)) + '.'
END
-- test : 
go
declare @makh varchar(10)
exec  tienhaylui '000003'

