use Bank
-- câu 1 :Viết đoạn code thực hiện việc chuyển đổi đầu số điện thoại di động 
--theo quy định của bộ Thông tin và truyền thông cho một khách hàng bất kì, 
--ví dụ với: Dương Ngọc Long

Declare @sdt nvarchar(20)  
select  @sdt = case when Cust_phone like '016%' then replace(Cust_phone, '016','03')
				when Cust_phone like '012[0,1,8,2,6]%' then replace(Cust_phone, '012','07')
				when Cust_phone like '012[3,4,5,7,9]%' then replace(Cust_phone, '012','08')
				else N'Không đổi'
			end
from customer 
where Cust_name = N'Dương Ngọc Long' 

UPDATE customer
SET Cust_phone = @sdt
WHERE Cust_name = N'Dương Ngọc Long'
 


--check : 
select customer.Cust_phone from customer 
where Cust_name like N'%Dương Ngọc Long%'


/* 2. Trong vòng 10 năm trở lại đây Nguyễn Lê Minh Quân 
có thực hiện giao dịch nào không? 
Nếu có, hãy trừ 50.000 phí duy trì tài khoản. */
--declare @count int,
--		@Sodutaikhoan int,
--		@phigiaodich int
--select @count=count(transactions.t_id),
--	   @Sodutaikhoan = account.ac_balance,
--	   @phigiaodich=5000
--from transactions inner join account on account.Ac_no= transactions.ac_no
--inner join customer on account.cust_id=customer.Cust_id
--inner join Branch on customer.Br_id = Branch.BR_id
--WHERE YEAR(t_date) >= DATEADD(YEAR, -10, GETDATE())
--and customer.Cust_name like N'%Nguyễn Lê Minh Quân%'
--group by ac_balance
--if @count>1
--begin 
--	print 'Có thực hiện giao dịch'
--	set @Sodutaikhoan=@Sodutaikhoan-@phigiaodich
--	PRINT N'Số tiền sau khi trừ phí '+cast(@phigiaodich as nvarchar) + ' là ' + cast(@Sodutaikhoan as nvarchar)
--END
--ELSE
--BEGIN
--	PRINT N'Không thực hiện giao dịch'
--END


DECLARE @count int,
        @Sodutaikhoan int,
        @phigiaodich int,
        @tienconlai int 

SELECT @count = COUNT(transactions.t_id),
       @Sodutaikhoan =(account.ac_balance),
       @phigiaodich = 5000
FROM transactions
INNER JOIN account ON account.Ac_no = transactions.ac_no
INNER JOIN customer ON account.cust_id = customer.Cust_id
INNER JOIN Branch ON customer.Br_id = Branch.BR_id
WHERE YEAR(t_date) >= DATEADD(year, -10, GETDATE())
AND customer.Cust_name LIKE N'%Nguyễn Lê Minh Quân%'
GROUP BY account.ac_balance 
IF @count > 0 
BEGIN
    PRINT 'Có thực hiện giao dịch'
    SET @tienconlai = @Sodutaikhoan - @phigiaodich
    PRINT N'Số tiền sau khi trừ phí ' + CAST(@phigiaodich AS nvarchar) + ' là ' + CAST(@tienconlai AS nvarchar)
END
ELSE
BEGIN
    PRINT N'Không thực hiện giao dịch'
END

--câu 3 Trần Quang Khải thực hiện giao dịch gần đây nhất vào thứ mấy? 
--(thứ hai, thứ ba, thứ tư,…, chủ nhật) 
--và vào mùa nào (mùa xuân, mùa hạ, mùa thu, mùa đông)? */ 
DECLARE @ngaygiaodich NVARCHAR(20), @ngay NVARCHAR(20), @mua NVARCHAR(10), @season INT

SELECT TOP 1
    @ngaygiaodich = CAST(DATEPART(WEEKDAY, transactions.t_date) AS NVARCHAR(20)),
    @ngay = CASE @ngaygiaodich
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
WHERE customer.Cust_name LIKE N'Trần Quang Khải'
if  @ngaygiaodich IS NOT NULL
BEGIN
    PRINT N'Gần đây nhất, Trần Quang Khải thực hiện giao dịch vào ngày ' + @ngay + N' và vào mùa ' + @mua
END
ELSE
BEGIN
    PRINT N'Trần Quang Khải chưa thực hiện giao dịch'
END

--4.Đưa ra nhận xét về nhà mạng mà Lê Anh Huy đang sử dụng? 
--(Viettel, Mobi phone, Vinaphone, Vietnamobile, khác) 
declare @nhamang nvarchar(20), @comment nvarchar(30)	
select @nhamang=( select customer.Cust_phone from customer 
					where customer.Cust_name like N'Lê Anh Huy') ,
	   @comment = case 
	 WHEN @nhamang LIKE '086%' 
		OR @nhamang LIKE '09[6,7,8]%'
		OR @nhamang LIKE '016[2,3,4,5,6,7,8,9]%'
		OR @nhamang LIKE '03[2,3,4,5,6,7,8,9]%'  THEN 'Viettel'
	 WHEN @nhamang LIKE '088%'
		OR @nhamang LIKE '09[1,4]%'
		OR @nhamang LIKE '012[3,4,5,7,9]%'
		OR @nhamang LIKE '08[1,2,3,4,5]%'		 THEN 'VinaPhone'
	 WHEN @nhamang LIKE '089%'
		OR @nhamang LIKE '09[0,3]%'
		OR @nhamang LIKE '012[0,1,2,6,8]%'
		OR @nhamang LIKE '07[0,6,7,8,9]%'	     THEN 'MoBiFone' 
	 WHEN @nhamang LIKE '092%'
		OR @nhamang LIKE '056%'
		OR @nhamang LIKE '058%'				     THEN 'Vietnamobile'
	ELSE N'Khác'
END
from customer
print (N'Với số điện thoại '+@nhamang +  N' thì Lê Anh Huy sử dụng nhà mạng ' +@comment)

--5.Số điện thoại của Trần Quang Khải là số tiến, số lùi hay số lộn xộn. 
--Định nghĩa: trừ 3 số đầu tiên, các số còn lại tăng dần gọi là số tiến,
--ví dụ: 098356789 là số tiến 
DECLARE @Phone NVARCHAR(15)
SELECT @Phone = Cust_phone from customer
WHERE customer.Cust_name = N'Trần Quang Khải'

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
            PRINT N'Số điện thoại của Trần Quang Khải là số tiến.'
        ELSE IF @giamdan = 1
            PRINT N'Số điện thoại của Trần Quang Khải là số lùi.'
        ELSE
            PRINT N'Số điện thoại của Trần Quang Khải là số lộn xộn.'
    END
    ELSE
        PRINT N'Số điện thoại không hợp lệ.'
END
ELSE
    PRINT N'Không tìm thấy khách hàng có tên "Trần Quang Khải".'

/* câu 6: Hà Công Lực thực hiện giao dịch gần đây nhất vào buổi nào
(sáng, trưa, chiều, tối, đêm)?  */
declare @thoigiangiaodich int, @buoi nvarchar(20)
select @thoigiangiaodich =	(select top 1 DATEPART(hour,transactions.t_time) from 
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_name like N'Hà Công Lực'
							order by t_date),
	   @buoi = case 
					when  @thoigiangiaodich between 5 and 9 then N'buổi sáng'
					when  @thoigiangiaodich between 10 and 12 then N' buổi trưa'
					when  @thoigiangiaodich between 13 and 17 then N' buổi chiều'
					when  @thoigiangiaodich between 16 and 21 then N' buổi tối'
					else  N'ban đêm'
				end
print(@thoigiangiaodich)
print(@buoi)

-- check
select customer.Cust_name,
t_time,
t_date
							from transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_name like N'Hà Công Lực'
							order by t_date

/* 7.	Chi nhánh ngân hàng mà Trương Duy Tường đang sử dụng thuộc miền nào? 
Gợi ý: nếu mã chi nhánh là VN  miền nam, VT  miền trung, VB  miền bắc, còn lại: bị sai mã */
-- lúc đầu làm là ko có distinct Branch.BR_id , nma sau khi check thì thấy có tận 3 giá trị( giống nhau) trong subquerry nên phải sử dụng distinct
declare @machinhanh char(5), @mien nvarchar(20)
select @machinhanh = (select distinct(Branch.BR_id) from  
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_name like N'Trương Duy Tường'),
	   @mien = case
				when @machinhanh like 'VN%' then N'Miền Nam' 
				when @machinhanh like 'VT%' then N'Miền Trung' 
				when @machinhanh like 'VB%' then N'Miền Bắc' 
				else N'Mã Sai'
			end
print(@machinhanh)
print(@mien)
--check
select Branch.BR_id from  
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_name like N'Trương Duy Tường'

/*8.	Căn cứ vào số điện thoại của Trần Phước Đạt, 
hãy nhận định anh này dùng dịch vụ di động của hãng nào: Viettel, Mobi phone, Vina phone, hãng khác.*/
declare @sodienthoai nvarchar(20), @hang nvarchar(30)
select @sodienthoai= (select customer.Cust_phone from customer
						where customer.Cust_name like N'Trần Phước Đạt'),
	   @hang = case 
				when @sodienthoai LIKE '086%' 
	  OR @sodienthoai LIKE '09[6,7,8]%'
	  OR @sodienthoai LIKE '016[2,3,4,5,6,7,8,9]%'
	  OR @sodienthoai LIKE '03[2,3,4,5,6,7,8,9]%'THEN 'Viettel'
	WHEN @sodienthoai LIKE '088%'
	  OR @sodienthoai LIKE '09[1,4]%'
	  OR @sodienthoai LIKE '012[3,4,5,7,9]%'
	  OR @sodienthoai LIKE '08[1,2,3,4,5]%'		 THEN 'VinaPhone'
	WHEN @sodienthoai LIKE '089%'
	  OR @sodienthoai LIKE '09[0,3]%'
	  OR @sodienthoai LIKE '012[0,1,2,6,8]%'
	  OR @sodienthoai LIKE '07[0,6,7,8,9]%'	     THEN 'MoBiFone' 
	WHEN @sodienthoai LIKE '092%'
	  OR @sodienthoai LIKE '056%'
	  OR @sodienthoai LIKE '058%'				 THEN 'Vietnamobile'
	ELSE  								 N'Khác'
END
PRINT (N'thuộc nhà mạng ' + @hang)
--check 
select customer.Cust_phone from customer
						where customer.Cust_name like N'Trần Phước Đạt'

/* 9.	Hãy nhận định Lê Anh Huy ở vùng nông thôn hay thành thị. 
Gợi ý: nông thôn thì địa chỉ thường có chứa chữ “thôn” hoặc “xóm” hoặc “đội” hoặc “xã” hoặc “huyện”
*/
declare @diachi nvarchar(20) , @nhandinh nvarchar(30)
select @diachi = ( select customer. Cust_ad from customer
					where Cust_name like N' Lê Anh Huy'),
		@nhandinh =case
			when @diachi like N'%thôn%'
				OR @diachi LIKE N'%xóm%'
				OR @diachi LIKE N'%đội%'
				OR @diachi LIKE N'%xã%'
				OR @diachi LIKE N'%huyện%' THEN N'Nông thôn'
			ELSE N'Thành Phố'
		end
print(N'Lê Anh Huy sống ở ' + @nhandinh)
--check 
select customer. Cust_ad from customer
					where Cust_name like N' Lê Anh Huy'

/*10.Hãy kiểm tra tài khoản của Trần Văn Thiện Thanh,
nếu tiền trong tài khoản của anh ta nhỏ hơn không hoặc bằng không 
nhưng 6 tháng gần đây không có giao dịch thì hãy đóng tài khoản bằng cách cập nhật ac_type = ‘K’
*/ 
--
declare @tientrongtaikhoan int,@solangiaodich int 
select @tientrongtaikhoan = account.ac_balance ,
	   @solangiaodich = count(transactions.t_id) from 
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where  month(t_date) >= DATEADD(month, -6, GETDATE()) 
							and  customer.Cust_name like N'Trần Văn Thiện Thanh'
							group by  t_date, account.ac_balance
							order by t_date desc
if ( @tientrongtaikhoan>0 and @solangiaodich>0)
print (N'Số tiền trong tài khoản của Trần Văn Thiện Thanh là ' + @tientrongtaikhoan +N'với số lần giao dịch là ' +@solangiaodich)
else
print(N'dsas')

--

--/* 11.Mã số giao dịch gần đây nhất của Huỳnh Tấn Dũng là số chẵn hay số lẻ? */ 
declare @MasoGD int 
select @MasoGD= (select top 1 transactions.t_id from 
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where Cust_name like N'Huỳnh Tấn Dũng'
							order by t_date desc)
print( @MasoGD)
if @MasoGD %2=0 
print(N'Mã số giao dịch mới nhất của Huỳnh Tấn Dũng là số chẵn')
else
print(N'Mã số giao dịch mới nhất của Huỳnh Tấn Dũng là số lẻ')
--check 
select  transactions.t_id ,
		transactions.t_date from 
							transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where Cust_name like N'Huỳnh Tấn Dũng'
							order by t_date desc
 
/* 12.	Có bao nhiêu giao dịch diễn ra trong tháng 9/2016 
với tổng tiền mỗi loại là bao nhiêu (bao nhiêu tiền rút, bao nhiêu tiền gửi) */	
declare @Sogiaodichrut int , @tongtienrut int, @tongtiengui int , @Sogiaodichgui int
		
select @Sogiaodichrut= count(transactions.t_id) ,
	   @tongtienrut=sum(transactions.t_amount)
							from transactions 
							where t_type=0 and 
							MONTH(t_date)=9 and YEAR(t_date)=2016
--kết luận cho rút
print(@Sogiaodichrut)
print(@tongtienrut)

select @Sogiaodichgui= count(transactions.t_id) ,
	   @tongtiengui=sum(transactions.t_amount)
							from transactions 
							where t_type=1 and 
							MONTH(t_date)=9 and YEAR(t_date)=2016
--kết luận cho gửi
print(@Sogiaodichgui)
print(@tongtiengui)
--kết luận 
select 
	@Sogiaodichrut as Sogiaodichrut,
	@Sogiaodichgui as Sogiaodichgui,
	@tongtienrut as Tongtienrut,
	@tongtiengui as Tongtiengui

/*13.Ở Hà Nội ngân hàng Vietcombank có bao nhiêu chi nhánh và có bao nhiêu khách hàng? 
Trả lời theo mẫu: “Ở Hà Nội, Vietcombank có … chi nhánh và có …khách hàng” */ 

declare @chinhanh nvarchar(10), @khachhang nvarchar(10)
select @chinhanh= count (distinct Branch.Br_id) , @khachhang = count(Customer.cust_id)
					from customer left join Branch on customer.Br_id=Branch.Br_id
					where BR_name like N'%Hà Nội'
print(@chinhanh)
print(@khachhang)
print (N'Ở Hà Nội, Vietcombank có' + @chinhanh + N'chi nhánh' + N'và có'+ @khachhang + N'khách hàng')

-- vì có 2 khách hàng , nma chỉ có 1 chi nhánh , nên khi nó đếm , nó sẽ đếm cả khách hàng có vietcombank , 
/*lưu ý là nếu dưới dạng int , mà bị lỗi Conversion failed when converting the nvarchar value ... to data type int
thì đây là lôi cố gắng cộng 1 chuỗi với dạng biến int , ko được 
có 2 cách : 1 là : đổi biến về dạng chuỗi : nvachar(...) hoặc char(...)
			2 là : dùng lệnh cast ( ở dưới , đại khái lệnh cast sẽ kiểu biến int thành hàm chuỗi , ví dụ 123 sẽ thành '123')
lệnh cast 
--declare @chinhanh_nvarchar nvarchar(10), @khachhang_nvarchar nvarchar(10)
--set @chinhanh_nvarchar = cast(@chinhanh as nvarchar)
--set @khachhang_nvarchar = cast(@khachhang as nvarchar)
--print(N'Ở Hà Nội, Vietcombank có ' + @chinhanh_nvarchar + N' chi nhánh và có ' + @khachhang_nvarchar + N' khách hàng')
*/

-- check		
select Branch.BR_id ,
		Customer.cust_id
from customer inner join Branch on customer.Br_id=Branch.Br_id
where  BR_name like N'%Hà Nội'

/*14.Tài khoản có nhiều tiền nhất là của ai,
số tiền hiện có trong tài khoản đó là bao nhiêu? 
Tài khoản này thuộc chi nhánh nào? */
declare @TenKh nvarchar(100), @sotienhientai int, @chinhanh nvarchar(100)
select @TenKh=customer.Cust_name,
		@chinhanh=Branch.BR_name,
		@sotienhientai=account.ac_balance
from transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							order by account.ac_balance 
print @TenKH
print @sotienhientai
print @chinhanh
-- check 
SELECT TOP 1
    customer.Cust_name AS [Tên khách hàng],
    account.ac_balance AS [Số tiền hiện có],
    Branch.BR_name AS [Chi nhánh]
FROM
    customer
INNER JOIN
    account ON customer.Cust_id = account.cust_id
INNER JOIN
    Branch ON customer.Br_id = Branch.BR_id
ORDER BY
    account.ac_balance DESC

--15.	Có bao nhiêu khách hàng ở Đà Nẵng?
declare @sokhachhangDN nvarchar(5) 
select @sokhachhangDN= count(customer.Cust_id)from customer where Cust_ad like N'%Đà Nẵng%' 
		or Cust_ad like '%ĐÀ NẴNG%' 
		or Cust_ad like '%ĐÀNẴNG%' 
		or  Cust_ad like N'%ĐàNẵng%'
print N'Số khách hàng ở Đà Nẵng là ' +@sokhachhangDN
-- check
select customer.Cust_name , customer. Cust_ad
from customer where  Cust_ad like N'%Đà Nẵng%' or Cust_ad like '%ĐÀ NẴNG%' or Cust_ad like '%ĐÀNẴNG%' or  Cust_ad like N'%ĐàNẵng%'

-- câu 16 : 16.	Có bao nhiêu khách hàng ở Quảng Nam nhưng mở tài khoản Sài Gòn
declare @kh nvarchar(5)
select @kh= count(distinct customer.Cust_id) from  customer inner join Branch on customer.Br_id=Branch.Br_id
			where Cust_ad like N'%Quảng Nam%' and BR_name like N'%Sài Gòn'
print N'Số khách hàng  ở Quảng Nam nhưng mở tài khoản Sài Gòn : ' +@kh

-- check
select customer.Cust_name , customer.Cust_ad , Branch.BR_name 
from  customer inner join Branch on customer.Br_id=Branch.Br_id
where Cust_ad like N'%Quảng Nam%' or Cust_ad like N'%QUẢNG NAM%' or Cust_ad like N'%QUẢNG NAM'

-- câu 17 : Ai là người thực hiện giao dịch có mã số 0000000387, thuộc chi nhánh nào? Giao dịch này thuộc loại nào?
declare @ailakemayman nvarchar(30) , @chinhanh nvarchar(30), @loaigiaodich nvarchar(10),@type int
select @ailakemayman=customer.Cust_name,
		@chinhanh =Branch.BR_name,
		@type = transactions.t_type
		 from transactions	inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where transactions.t_id='0000000387'

print N'Tên Khách Hàng : '+@ailakemayman
print'Chi nhánh : ' +@chinhanh
---- cách 1 sài if begin end 
--if @type=1
--	begin
--		set @loaigiaodich=N'Gửi'
--		print @loaigiaodich
--	end
--	else
--	begin
--		set @loaigiaodich=N'Rút'
--		print @loaigiaodich
--	end
-- cách 2 : sài if else thông thường
set @loaigiaodich=@type
if @type=1
	set @loaigiaodich= N'Gửi'
else
	set @loaigiaodich=N'Rút'
print @loaigiaodich
--check : 
select customer.Cust_name,
		Branch.BR_name,
		transactions.t_type
		 from transactions	inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where transactions.t_id='0000000387'

-- câu 18 : 18.	Hiển thị danh sách khách hàng gồm: 
--họ và tên, số điện thoại, số lượng tài khoản đang có và nhận xét. Nếu < 1 tài khoản  “Bất thường”, còn lại “Bình thường”
DECLARE @DSKH TABLE (HoTenKH nvarchar(30),
					 SoDT nvarchar(11), 
					 SoLuongTK int, 
					 NhanXet nvarchar(30))
INSERT INTO @DSKH 
			SELECT cust_name,
			cust_phone, count(ac_no),
			(CASE WHEN count(ac_no) < 1 THEN N'Bất thường'
				  ELSE N'Bình thường'
				  END)
FROM account join customer ON account.cust_id = customer.Cust_id 
group by Cust_name,Cust_phone
select * from @DSKH

--câu 19 :Viết đoạn code nhận xét tiền trong tài khoản của ông Hà Công Lực. <100.000: ít, < 5.000.000  trung bình, còn lại: nhiều
declare @tien int , @nhanxet nvarchar(30)
select @tien= account.ac_balance from account join customer ON account.cust_id = customer.Cust_id
				where customer.Cust_name like N'Hà Công Lực'
set @nhanxet = case 
	when @tien <100000 then N'Ít'
	when @tien <5000000 then N'Trung Bình'
	else N'Nhiều'
end
print @tien
select * from customer 
where customer.Cust_name like N'Hà Công Lực'
-- câu 20 : Hiển thị danh sách các giao dịch của chi nhánh Huế với các thông tin: 
--mã giao dịch, thời gian giao dịch, số tiền giao dịch, loại giao dịch (rút/gửi), số tài khoản. Ví dụ:
DECLARE @Giaodichchinhanh TABLE (Magiaodich int,
					 Thoigiangiaodich date, 
					 Sotiengiaodich int, 
					 loaigiaodich nvarchar(10),
					 sotaikhoan int
					)
INSERT INTO @Giaodichchinhanh (Magiaodich, Thoigiangiaodich, Sotiengiaodich, loaigiaodich, sotaikhoan)
			SELECT 
			transactions.t_id,
			transactions.t_date, 
			transactions.t_amount, 
			CASE
				WHEN transactions.t_type = 1 THEN N'Gửi'
			ELSE N'Rút'
				 END AS loaigiaodich,
			account.Ac_no
							from transactions inner join account on account.Ac_no= transactions.ac_no							
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id							
							where Branch.BR_name like N'%Huế'
							order by transactions.t_amount
select * from @Giaodichchinhanh

-- câu 21 Kiểm tra xem khách hàng Nguyễn Đức Duy có ở Quang Nam hay không?
declare @kiemtra nvarchar(50) 
select @kiemtra = customer.Cust_ad from customer 
					where customer.Cust_name like N'%Nguyễn Đức Duy%'
print @kiemtra
if @kiemtra like N'% Quảng Nam'
	print N'Đúng'
else	
	print N'Sai'
/*câu 22 : Điều tra số tiền trong tài khoản ông Lê Quang Phong có hợp lệ hay không? 
(Hợp lệ: tổng tiền gửi – tổng tiền rút = số tiền hiện có trong tài khoản). 
Nếu hợp lệ, đưa ra thông báo “Hợp lệ”, 
ngược lại hãy cập nhật lại tài khoản sao cho số tiền trong tài khoản khớp với tổng số tiền đã giao dịch 
(ac_balance = sum(tổng tiền gửi) – sum(tổng tiền rút) */
declare @tongtiengui int , @tongtienrut int, @sotienhientai int, @kiemtra nvarchar(10)

select @tongtiengui =sum(transactions.t_amount)  
									from transactions inner join account on account.Ac_no= transactions.ac_no							
									inner join customer on account.cust_id=customer.Cust_id
									where customer.Cust_name like N'%Lê Quang Phong%' and transactions.t_type=1
select @tongtienrut = sum(transactions.t_amount)  
									from transactions inner join account on account.Ac_no= transactions.ac_no							
									inner join customer on account.cust_id=customer.Cust_id
									where customer.Cust_name like N'%Lê Quang Phong%' and transactions.t_type=0
select @sotienhientai= account.ac_balance 
									from  transactions inner join account on account.Ac_no= transactions.ac_no							
									inner join customer on account.cust_id=customer.Cust_id
									where customer.Cust_name like N'%Lê Quang Phong%'
IF @tongtiengui - @tongtienrut = @sotienhientai
BEGIN
    SET @kiemtra = N'Hợp lệ'
	print @kiemtra
END
ELSE
BEGIN
    SET @kiemtra = N'Không hợp lệ'
	print @kiemtra
    SET @sotienhientai = @tongtiengui - @tongtienrut
	PRINT N'Số tiền hiện tại: ' + CAST(@sotienhientai AS NVARCHAR(10));
end
 SELECT @sotienhientai as Sotienhientai
-- check
select sum(transactions.t_amount) ,
transactions.t_id
from transactions inner join account on account.Ac_no= transactions.ac_no							
inner join customer on account.cust_id=customer.Cust_id
where customer.Cust_name like N'%Lê Quang Phong%' and transactions.t_type=1
group by transactions.t_id

/*câu 23 Chi nhánh Đà Nẵng có giao dịch gửi tiền nào diễn ra vào ngày chủ nhật hay không?
Nếu có, hãy hiển thị số lần giao dịch, nếu không, hãy đưa ra thông báo “không có” */
declare @giaodichcuoituan int
select @giaodichcuoituan = count(distinct transactions.t_id) 
							from transactions inner join account on account.Ac_no= transactions.ac_no							
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where Branch.BR_name like N'%Đà Nẵng' and datepart(WEEKDAY, transactions.t_date) =1
if @giaodichcuoituan>0
	begin	
		print N'Giao dịch cuối tuần thành phố Đà Nẵng : '
		print @giaodichcuoituan
	end
else 
	begin
		print N'Không có'
	end
/*câu 24 Kiểm tra xem khu vực miền bắc có nhiều phòng giao dịch hơn khu vực miền trung ko? 
Miền bắc có mã bắt đầu bằng VB, miền trung có mã bắt đầu bằng VT */

declare @tongchinhanhmienbac int, @tongchinhanhmientrung int 
select @tongchinhanhmienbac =count(Br_id) from Branch where Branch.BR_id like N'VB%'
select @tongchinhanhmientrung =COUNT(Br_id) from Branch where Branch.Br_id like N'VT%'
if @tongchinhanhmienbac>@tongchinhanhmientrung
	print N'Miền Bắc có nhiều chi nhánh ngân hàng hơn Miền Trung'
else
	print N'Miền Trung có nhiều chi nhánh ngân hàng hơn Miền Bấc'
/* 25.	In ra dãy số lẻ từ 1 – n, với n là giá trị tự chọn */
declare @count int
set @count=1
while @count <1000
begin
	if @count %2!=0
	begin
		print @count
	end
	set @count+=2	
end
/* 26.In ra dãy số chẵn từ 0 – n, với n là giá trị tự chọn */
declare @count int
set @count=0
while @count <=1000
begin
	if @count %2=0
	begin
		print @count
	end
	set @count+=1	
end
/* 27.In ra 100 số đầu tiền trong dãy số Fibonaci */
declare @fibo int
set @fibo=1
while @fibo <=100
begin
	if @fibo=1
	begin
		print(0)
	end
	if @fibo =2
	begin
		print(1)
	end
	else
	begin
		print((@fibo-1)+(@fibo-2))
	end
	set @fibo+=1
end

/* 28.	In ra tam giác sao: */
-- tam giác vuông
DECLARE @tamgiac nvarchar(10), @d int = 1
SET @tamgiac = '*'
WHILE @d < 6
BEGIN	
	PRINT @tamgiac
	SET @tamgiac = @tamgiac + '*'
	SET @d +=1
END
--tam giác cân
declare @a int, @b int
set @a=0
set @b=5
while @b>=1
begin
	print (space(@b) + replicate('*',@a) + replicate('*',@a+1))
	set @a +=1
	set @b -=1
end
/*In bảng cửu chương */
-- cách 1 : 
DECLARE @i INT
SET @i = 1
WHILE @i <= 9
BEGIN
    DECLARE @j INT
    SET @j = 1
    declare @row nvarchar(max)='  '
    WHILE @j <= 10
    BEGIN
        PRINT CAST(@i AS VARCHAR) + 'x ' + CAST(@j AS VARCHAR) + '=' + CAST(@i * @j AS VARCHAR)
        SET @j = @j + 1
    END  
	print @row
    SET @i = @i + 1
    PRINT '' -- In ra dòng trống để phân tách bảng cửu chương
END
-- cách 2 : 
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
/* Kiểm tra số điện thoại của Lê Quang Phong là số tiến hay số lùi*/
DECLARE @Phone NVARCHAR(15)

SELECT @Phone = Cust_phone
FROM customer
WHERE customer.Cust_name = N'Lê Quang Phong'

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
            PRINT N'Số điện thoại của Lê Quang Phong là số tiến.'
        ELSE IF @giamdan = 1
            PRINT N'Số điện thoại của Lê Quang Phong là số lùi.'
        ELSE
            PRINT N'Số điện thoại của Lê Quang Phong là số lộn xộn.'
    END
    ELSE
        PRINT N'Số điện thoại không hợp lệ.'
END
ELSE
    PRINT N'Không tìm thấy khách hàng có tên "Lê Quang Phong".'
-- test : 

-- Onng hà công lực  thực hiện giao dịch gần đây nhất vào ngày cuối tuần hay trong tuần , loại giao dịch là gửi hay rút 

DECLARE @thoigiangiaodich INT, @buoi NVARCHAR(20), @loaigiaodich NVARCHAR(20), @type INT, @loaigiaodich1 NVARCHAR(20)
		
SELECT TOP 1 @thoigiangiaodich = DATEPART(WEEKDAY, transactions.t_date),
            @type = transactions.t_type
FROM transactions
INNER JOIN account ON account.Ac_no = transactions.ac_no
INNER JOIN customer ON account.cust_id = customer.Cust_id
INNER JOIN Branch ON customer.Br_id = Branch.BR_id
WHERE customer.Cust_name LIKE N'Hà Công Lực'
ORDER BY t_date 

SET @buoi = CASE 
    WHEN @thoigiangiaodich >= 2 AND @thoigiangiaodich <= 6 THEN N'Trong Tuần'
    ELSE N'Cuối tuần'
END

SET @loaigiaodich1 = @type

IF @type = 1
    SET @loaigiaodich1 = N'Gửi'
ELSE
    SET @loaigiaodich1 = N'Rút'

PRINT(@buoi)
PRINT(@loaigiaodich1)




