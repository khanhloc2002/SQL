use Bank
-- KHAI BÁO BIẾN
declare @numTest int
--set @numTest =(select 8count(*) from customer)
select @numTest = count(*) from customer
print(@numTest)

-- RẺ NHÁNH
--In ra loại tài khoản của ac_no:'1000000001'

declare @ac_Type int
set @ac_Type = (select ac_type from account where ac_no='1000000001')
if @ac_Type=1
begin
	print('Vip')
end
else if @ac_Type=0
begin
print 'Thuong'
end
else
begin
print 'Khong hop le'
end

go --- để giữa các khối lệnh

declare @ac_Type int, @nx varchar(20)
set @ac_Type = (select ac_type from account where ac_no='1000000001')
set @nx = case @ac_Type when '1' then 'Vip'
						when '0' then 'Thuong'
						else 'Khong hop le'
		end

declare @ac_Type int,  @nx varchar(20)
set @ac_Type = (select ac_type from account where ac_no='1000000001')
set 


--WHILE

declare @count int
set @count=1
while @count <=100
begin
	if @count %2=0
	begin
		print @count
		set @count+=1
	end
	else
	begin
		set @count+=1	
	end
end


declare @count int
set @count=1
while @count <=100
begin
	if @count %2=0
	begin
		print @count
	end
	set @count+=1	
end

-- in ra tên chi nhanh VB012
use Bank
declare @tenchinhanh nvarchar(30)
select @tenchinhanh = Branch.BR_name from Branch where BR_id ='VB012'
if @@ROWCOUNT >0
begin 
	print(@tenchinhanh)
end
else
begin 
	print N'Có chết liền'
end

-- cái hàm @@rowcount dùng để check xem đúng ko , vì t-sql có vài cái in ra :v nó ra trắng :v thì dùng rowcount để check , ko thfi viết sql mà check 
select @tenchinhanh as tenchinhanh
-- check
select Branch.BR_name from Branch where BR_id ='VB012'


-- in ra tên chi nhanh VB001
declare @tenchinhanh nvarchar(30)
select @tenchinhanh = Branch.BR_name from Branch where BR_id ='VB001'

if @@ROWCOUNT >0
begin 
	print(@tenchinhanh)
end
else
begin 
	print N'Có chết liền'
end
--in ra số lẻ : 
declare @count int
set @count=1
while @count <1000
begin
	if @count %2=1
	begin
		print @count
	end
	set @count+=2	
end

-- in dãy số chẵn 
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
-- ngày 26/9
-- trần văn thiện thanh đã thực hiện giao dịch nào chưa 
declare @sogiaodich1 int 
select @sogiaodich1 = count(distinct transactions.t_id) 
							from transactions inner join account on account.Ac_no= transactions.ac_no
							inner join customer on account.cust_id=customer.Cust_id
							inner join Branch on customer.Br_id = Branch.BR_id
							where customer.Cust_name like N'Trần Văn Thiện Thanh'
if @sogiaodich1 >0
begin 
	print(@sogiaodich1)
	print N'rồi'
end
else
begin 
	print N'Có chết liền'
	
end
-- câu 2 :	Chi Nhanh Hue có bao nhiêu khách hàng 
declare @sokhachhang int 
select @sokhachhang = count(distinct customer.Cust_id) 
					from customer inner join Branch on customer.Br_id=Branch.BR_id
					where BR_name like N'% Huế'
if @sokhachhang >0
begin 
	print(@sokhachhang)
end
else
begin 
	print N'Có chết liền'
end


-- câu 3 : Trần Văn Thiện Thanh sống ở thành phố nào 
declare @thanhpho nvarchar(100) 
select @thanhpho = SUBSTRING(Cust_ad , (len(Cust_ad)-CHARINDEX(' ',reverse(Cust_ad),8)+2),15) from customer
					where Cust_name liKe N'%Trần Văn Thiện Thanh%'
print(N'Trần Văn Thiện Thanh sống ở ' + @thanhpho) 
-- câu 4 : In ra bảng cửu chương 
-- bảng cửu chương 2
DECLARE @i INT
SET @i = 1

WHILE @i <= 9
BEGIN
    DECLARE @j INT
    SET @j = 1
    declare @row nvarchar(max)='  '
    WHILE @j <= 10
    BEGIN
        PRINT CAST(@i AS VARCHAR) + ' x ' + CAST(@j AS VARCHAR) + ' = ' + CAST(@i * @j AS VARCHAR)
        SET @j = @j + 1
    END
    
	print @row
    SET @i = @i + 1
    PRINT '' -- In ra dòng trống để phân tách bảng cửu chương
END



DECLARE @i INT = 1
DECLARE @j INT

WHILE @i <= 10
BEGIN
    SET @j = 1
    DECLARE @row NVARCHAR(max) = ''
    WHILE @j <= 10
    BEGIN
        SET @row = @row + CAST(@i AS NVARCHAR(5)) + ' x ' + CAST(@j AS NVARCHAR(5)) + ' = ' + CAST(@i * @j AS NVARCHAR(5)) + '       '
        SET @j = @j + 1
    END

    PRINT @row
    SET @i = @i + 1
END