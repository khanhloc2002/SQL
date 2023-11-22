use Bank
select * from customer
select * from Branch
select * from transactions
select * from account

-- câu 1 : Có bao nhiêu khách hàng có ở Quảng Nam thuộc chi nhánh ngân hàng Vietcombank Đà Nẵng
select distinct(customer.Cust_name) as Ten_Khach_Hang,
customer.Cust_ad as Dia_Chi,
Branch.BR_ad as Dia_chi_chi_nhanh,
Br_name as Ten_Chi_Nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where BR_name = N'Vietcombank Đà Nẵng' and ( Cust_ad like N'QUẢNG NAM' or Cust_ad like N'Quảng Nam')

--câu 2 : Hiển thị danh sách khách hàng thuộc chi nhánh Vũng Tàu và số dư trong tài khoản của họ.
select distinct(customer.Cust_name) as Ten_Khach_Hang,
Branch.BR_ad as Dia_chi_chi_nhanh,
Br_name as Ten_Chi_Nhanh,
account.ac_balance as So_Du_Tai_Khoan
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'%Vũng Tàu'

-- câu 3 :Trong quý 1 năm 2012, có bao nhiêu khách hàng thực hiện giao dịch rút tiền tại Ngân hàng Vietcombank?
select count(distinct(customer.Cust_id)) as Ten_Khach_Hang
--transactions.t_id as ID_Giao_Dich,
--transactions.t_date as Ngay_Thuc_Hien_Giao_Dich,
--transactions.t_type as Loai_Giao_Dich,
--Br_name as Ten_Chi_Nhanh,
--account.Ac_no as Tai_Khoan
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'Vietcombank%' 
and t_type = 0
and DATEPART(quarter,t_date)=1 and YEAR(t_date)=2012
--group by transactions.t_id,transactions.t_date,transactions.t_type,Br_name,account.Ac_no 

--câu 4:Thống kê số lượng giao dịch, tổng tiền giao dịch trong từng tháng của năm 2014
select count (t_id) as So_Luong_Giao_Dich,
sum(t_amount) as Tong_So_Tien_Giao_Dich,
month(t_date) as Thang_Giao_Dich
from transactions
where YEAR(t_date)=2014
group by MONTH(t_date)

--câu 5 : Thống kê tổng tiền khách hàng gửi của mỗi chi nhánh, sắp xếp theo thứ tự giảm dần của tổng tiền
select sum(transactions.t_amount) as Tong_So_Tien_Giao_Dich,
transactions.t_type as Loai_Giao_Dich,
Branch.BR_name as Ten_Chi_Nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where t_type =1
group by Branch.BR_name , transactions.t_type
order by SUM(transactions.t_amount) desc

--câu 6 : Chi nhánh Sài Gòn có bao nhiêu khách hàng không thực hiện bất kỳ giao dịch nào trong vòng 3 năm trở lại đây.
--Nếu có thể, hãy hiển thị tên và số điện thoại của các khách đó để phòng marketing xử lý.

select  Cust_name as ten_khach_hang, 
Cust_phone as So_dien_thoai
from customer join Branch on customer.Br_id = Branch.BR_id
where BR_name = N'Vietcombank Sài Gòn' 
and Cust_name not in (Select Cust_name 
                      from customer join account on customer.Cust_id = account.cust_id
			                        join transactions on account.ac_no = transactions.ac_no
                      where Year(t_date) >= DATEADD(year,-3,GETDATE()))
group by rollup(customer.Cust_name ,customer.Cust_phone)
-- why
select Cust_name, Cust_phone
from customer join Branch on customer.Br_id = Branch.BR_id
where BR_name = N'Vietcombank Sài Gòn' 
and Cust_name not in (Select Cust_name 
                      from customer join account on customer.Cust_id = account.cust_id
			                        join transactions on account.ac_no = transactions.ac_no
                      where Year(t_date) between 2021 and 2023)

--câu 7 : Thống kê thông tin giao dịch theo mùa, 
--nội dung thống kê gồm: số lượng giao dịch, lượng tiền giao dịch trung bình, 
--tổng tiền giao dịch, lượng tiền giao dịch nhiều nhất, lượng tiền giao dịch ít nhất.
select count (t_id) as So_Luong_Giao_Dich,
sum(t_amount) as Tong_So_Tien_Giao_Dich,
AVG(t_amount) as Luong_Tien_Giao_Dich,
MAX(t_amount) as Luong_Tien_Giao_Dich_Lon_Nhat,
min(t_amount) as Luong_Tien_Giao_Dich_It_Nhat,
DATEPART(quarter,t_date) as Mua_Giao_Dich,
CASE
        WHEN DATEPART(quarter,t_date) = 1 THEN N'Mùa Xuân'
        WHEN DATEPART(quarter,t_date) = 2 THEN N'Mùa Hạ'
        WHEN DATEPART(quarter,t_date) = 3 THEN N'Mùa Thu'
        WHEN DATEPART(quarter,t_date) = 4 THEN N'Mùa Đông'
    END AS 'Mùa'
from transactions
group by DATEPART(quarter,t_date)

--câu 8 : Tìm số tiền giao dịch nhiều nhất trong năm 2016 của chi nhánh Huế. 
--Nếu có thể, hãy đưa ra tên của khách hàng thực hiện giao dịch đó.
select customer.Cust_name as Ten_Khach_Hang ,
Branch.Br_name as Ten_Chi_Nhanh,
transactions.t_amount as Tong_Tien_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
WHERE YEAR(t_date)=2016
and transactions.t_amount = (
        SELECT MAX(transactions.t_amount)
        FROM transactions
        INNER JOIN account ON account.Ac_no = transactions.ac_no
        INNER JOIN customer ON account.cust_id = customer.Cust_id
        INNER JOIN Branch ON customer.Br_id = Branch.BR_id
        WHERE Branch.BR_name LIKE N'%Huế%'
		AND YEAR(transactions.t_date) = 2016
    )
    AND Branch.BR_name LIKE N'%Huế%'
--cách 2 : basic hơn 
select TOP 1 Cust_name as Ten_khach_hang, 
max(t_amount) as So_tien_nhieu_nhat,
Branch.BR_name as Ten_chi_nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
where datepart(year, [t_date]) = 2016
and BR_name like N'%Huế' 
group by cust_name, BR_name
order by max(t_amount) DESC

-- câu 9 : Tìm khách hàng có lượng tiền gửi nhiều nhất vào ngân hàng trong năm 2017 (nhằm mục đích tri ân khách hàng)
select top 1 (customer.Cust_name) as Ten_Khach_Hang ,
Branch.Br_name as Ten_Chi_Nhanh,
transactions.t_amount as Tong_Tien_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
WHERE YEAR(t_date)=2017 and t_type=1
and transactions.t_amount = (
        SELECT MAX(transactions.t_amount)
        FROM transactions
        INNER JOIN account ON account.Ac_no = transactions.ac_no
        INNER JOIN customer ON account.cust_id = customer.Cust_id
        INNER JOIN Branch ON customer.Br_id = Branch.BR_id
        WHERE YEAR(transactions.t_date) = 2017
		and t_type=1
    )

--câu 10: Tìm những khách hàng có cùng chi nhánh với ông Phan Nguyên Anh
select distinct(customer.Cust_name) as Ten_Khach_Hang,
customer.Br_id as Ma_Chi_Nhanh,
Br_name as Ten_Chi_Nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
where customer.Br_id=(select customer.Br_id from customer where Cust_name like N'Phan Nguyên Anh')
and Cust_name <> N'Phan Nguyên Anh'




--Câu 11 : Liệt kê những giao dịch thực hiện cùng giờ với giao dịch của ông Lê Nguyễn Hoàng Văn ngày 2016-12-02
select distinct(customer.Cust_name) as Ten_Khach_Hang,
transactions.t_id as Id_Giao_Dich,
transactions.t_time as Gio_Giao_Dich,
transactions.t_date as Ngay_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
WHERE CAST(transactions.t_time AS TIME) = (
    SELECT CAST(transactions.t_time AS TIME)
    from transactions inner join account on account.Ac_no= transactions.ac_no
	inner join customer on account.cust_id=customer.Cust_id												
	inner join Branch on customer.Br_id = Branch.BR_id
    WHERE customer.Cust_name like N'Lê Nguyễn Hoàng Văn'
    AND CAST(transactions.t_date AS DATE) = '2016-12-02'
)
and customer.Cust_name not like N'Lê Nguyễn Hoàng Văn'

--check

select distinct(customer.Cust_name) as Ten_Khach_Hang,
transactions.t_id as Id_Giao_Dich,
transactions.t_time as Gio_Giao_Dich,
transactions.t_date as Ngay_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
where customer.Cust_name like N'Lê Nguyễn Hoàng Văn'

--câu 12 : Hiển thị danh sách khách hàng ở cùng thành phố với Trần Văn Thiện Thanh
with city as
	(
	select SUBSTRING(Cust_ad , (len(Cust_ad)-CHARINDEX(' ',reverse(Cust_ad),8)+2),15) as TP,Cust_id from customer
	)
select Cust_name as TenKhachHang,
Cust_ad as Dia_chi
from city
join customer on city.Cust_id = customer.Cust_id
where Cust_name not like N'%Trần Văn Thiện Thanh%' 
and TP = 
(select SUBSTRING(Cust_ad , (len(Cust_ad)-CHARINDEX(' ',reverse(Cust_ad),8)+2),15)  
from customer where Cust_name like N'%Trần Văn Thiện Thanh%')

--câu 13 : Tìm những giao dịch diễn ra cùng ngày với giao dịch có mã số 0000000217
select transactions.t_id as ID_Giao_Dich,
t_date as Ngay_Giao_Dich
from transactions
where t_date=(select transactions.t_date from transactions where t_id = 0000000217) and t_id <>0000000217
--check
SELECT *
FROM transactions
WHERE transactions.t_date = '2014-07-25'
--
SELECT *
FROM transactions
WHERE transactions.t_id =  0000000217

--câu 14 : Tìm những giao dịch cùng loại với giao dịch có mã số 0000000387
select transactions.t_id as ID_Giao_Dich,
t_type as Loai_Giao_Dich
from transactions
where t_type=(select transactions.t_type from transactions where t_id = 0000000387) and t_id <>0000000387
--check
select * from transactions
where t_type=1

select * from transactions
where t_id=0000000387

-- câu 15 : Những chi nhánh nào thực hiện nhiều giao dịch gửi tiền trong tháng 12/2015 hơn chi nhánh Đà Nẵng
SELECT count(t_id) as so_luong_giao_dich,
BR_name as Ten_chi_nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
WHERE MONTH(t_date) = 12 and YEAR(t_date) = 2015 and t_type = 1
group by BR_name 
having count(t_id) > 
(SELECT COUNT(t_id)
FROM transactions join account ON transactions.ac_no = account.Ac_no 
JOIN customer ON account.cust_id = customer.Cust_id 
JOIN Branch ON customer.br_id = Branch.BR_id
WHERE MONTH(t_date) = 12 and YEAR(t_date) = 2015 and BR_name like N'%Đà Nẵng%' and t_type = 1)
--check
SELECT count(t_id) as so_luong_giao_dich,
Branch.BR_name as Ten_Chi_Nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
WHERE MONTH(t_date) = 12 and YEAR(t_date) = 2015 and t_type = 1 
group by Branch.Br_name

--câu 16 :Hãy liệt kê những tài khoảng trong vòng 6 tháng trở lại đây không phát sinh giao dịch
--cách 1 :
select distinct transactions.ac_no,
customer.Cust_name as Ten_khach_hang,  
account.Ac_no as stk , 
t_date as ngay_giao_dich 
from account 
FULL OUTER JOIN customer on account. cust_id = customer.Cust_id 
FULL OUTER JOIN transactions on transactions.ac_no = account.Ac_no
where  account.Ac_no not in
	(select transactions.ac_no from transactions where transactions.t_date >=dateadd(month,-6,getdate()))
--or (datepart(month,t_date) is null)  

--cách 2 : 
SELECT distinct
    transactions.ac_no AS stk,
    customer.Cust_name AS Ten_khach_hang,
    account.Ac_no AS stk,
    t_date AS ngay_giao_dich
FROM account
FULL OUTER JOIN customer ON account.cust_id = customer.Cust_id
FULL OUTER JOIN transactions ON transactions.ac_no = account.Ac_no
WHERE account.Ac_no NOT IN (
    SELECT transactions.ac_no
    FROM transactions
    WHERE transactions.t_date >= DATEADD(MONTH, -6, GETDATE())
)


--câu 17:Ông Phạm Duy Khánh thuộc chi nhánh nào? 
--Từ 01/2017 đến nay ông Khánh đã thực hiện bao nhiêu giao dịch gửi tiền vào ngân hàng với tổng số tiền là bao nhiêu.
select customer.Cust_name as Ten_Khach_Hang,
count(transactions.t_id) as slgd,
Branch.Br_name as Ten_Chi_Nhanh,
sum(transactions.t_amount) as Tong_tien_gui,
transactions.t_date as Ngay_gui_tien
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
where Cust_name like N'%Phạm Duy Khánh%' 
and year(t_date)>=2017 and month(t_date)>1 
and t_type=1
group by Cust_name,Br_name,t_date

--câu 18 : Thống kê giao dịch theo từng năm, nội dung thống kê gồm: 
--số lượng giao dịch, lượng tiền giao dịch trung bình
select count (t_id) as So_Luong_Giao_Dich,
sum(t_amount) as Tong_So_Tien_Giao_Dich,
AVG(t_amount) as Luong_Tien_Giao_Dich_Trung_Bình,
year(t_date) as Nam_Giao_Dich
from transactions
group by year(t_date)

--câu 19 : Thống kê số lượng giao dịch theo ngày và đêm trong năm 2017 ở chi nhánh Hà Nội, Sài Gòn
select count (transactions.t_id) as So_Luong_Giao_Dich,
Branch.BR_name as Ten_Chi_Nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'%Hà Nội%' or BR_name like N'%Sài Gòn%'
and year(t_date)=2017
group by Br_name

-- câu 19 : 
SELECT
    t_date AS DAYSS,
    SUM(CASE WHEN DATEPART(hour, t_time) BETWEEN 6 AND 17 THEN 1 ELSE 0 END) AS GD_NGAY,
    SUM(CASE WHEN DATEPART(hour, t_time) BETWEEN 18 AND 5 THEN 1 ELSE 0 END) AS GD_DEM,
    Branch.BR_name AS Branch_Name
FROM
    (Branch
    INNER JOIN customer ON Branch.BR_id = customer.Br_id)
    INNER JOIN account ON customer.Cust_id = account.cust_id
    INNER JOIN transactions ON account.Ac_no = transactions.ac_no
WHERE
    DATEPART(year, t_date) = '2017'
    AND (Branch.BR_name LIKE N'%Sài Gòn' OR Branch.BR_name LIKE N'%Hà Nội')
GROUP BY
    t_date, Branch.BR_name
ORDER BY
    DAYSS ASC, Branch.BR_name;

--câu 19 : 
SELECT
    BR_name,
    SUM(CASE WHEN t_time BETWEEN '6:00' AND '18:00' THEN 1 ELSE 0 END) AS gd_ngay,	
    SUM(CASE WHEN t_time BETWEEN '6:00' AND '18:00' THEN 0 ELSE 1 END) AS gd_dem
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
where
    YEAR(transactions.t_date) = 2017
    AND (BR_name LIKE N'%Hà Nội%' OR BR_name LIKE N'%Sài Gòn%')
GROUP BY
    BR_name

--câu 20:Hiển thị danh sách khách hàng chưa thực hiện giao dịch nào trong năm 2017?
select customer.Cust_name as Ten_Khach_Hang,
account.Ac_no as So_Tai_Khoan,
t_date as Ngay_Giao_Dich
from account
FULL OUTER JOIN customer on account. cust_id = customer.Cust_id 
FULL OUTER JOIN transactions on transactions.ac_no = account.Ac_no
where (YEAR(t_date ) = 2017 or YEAR(t_date ) is null)  and  account.Ac_no not in
	(select transactions.ac_no from transactions where YEAR(t_date ) = 2017)

--câu 21 : Hiển thị những giao dịch trong mùa xuân của các chi nhánh miền trung. 
--Gợi ý: giả sử một năm có 4 mùa, mỗi mùa kéo dài 3 tháng; 
--chi nhánh miền trung có mã chi nhánh bắt đầu bằng VT
select transactions.t_id as Ma_Giao_Dich,
Branch.BR_name as Ten_Chi_Nhanh ,
Branch.Br_id as ID_Chi_Nhanh ,
transactions.t_date as Ngay_Giao_Dich 
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id 
where DATEPART(quarter,t_date)=1 and Branch.BR_id like 'VT%' and transactions.t_id is not null

--câu 22:Hiển thị họ tên và các giao dịch của khách hàng sử dụng số điện thoại có 3 số đầu là 093 và 2 số cuối là 02.
select distinct(customer.Cust_name) as Ho_Ten_Khach_Hang,
customer.Cust_phone as So_Dien_Thoai,
transactions.t_id as id_giao_dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id 
Where customer.Cust_phone LIKE '093%02'

--câu23:Hãy liệt kê 2 chi nhánh làm việc kém hiệu quả nhất trong toàn hệ thống 
--(số lượng giao dịch gửi tiền ít nhất) trong quý 3 năm 2017




select top 2 count(transactions.t_id) as slgd,
Branch.BR_name as Chi_nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where t_type=1 and year(t_date)=2017
group by BR_name
order by  count(transactions.t_id) 

--select top2 Branch.BR_name as Ten_Chi_Nhanh
--from transactions inner join account on account.Ac_no= transactions.ac_no
--inner join customer on account.cust_id=customer.Cust_id
--inner join Branch on customer.Br_id = Branch.BR_id
--where transactions.t_id= ( select COUNT(transactions.t_id) from transactions 
--							order by  COUNT(transactions.t_id))
--SELECT TOP 2
--    Branch.BR_name AS Ten_Chi_Nhanh
--FROM transactions
--INNER JOIN account ON account.Ac_no = transactions.ac_no
--INNER JOIN customer ON account.cust_id = customer.Cust_id
--INNER JOIN Branch ON customer.Br_id = Branch.BR_id
--GROUP BY Branch.BR_name
--ORDER BY COUNT(transactions.t_id) 

--câu 24 :Hãy liệt kê 2 chi nhánh có bận mải nhất hệ thống (thực hiện nhiều giao dịch gửi tiền nhất) trong năm 2017.
select top 2 count(transactions.t_id) as slgd,
Branch.BR_name as Chi_nhanh
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where YEAR(t_date)=2017 and t_type=1
group by BR_name
order by  count(transactions.t_id) desc

--câu 25 : Tìm giao dịch gửi tiền nhiều nhất trong mùa đông. 
--Nếu có thể, hãy đưa ra tên của người thực hiện giao dịch và chi nhánh.
select transactions.t_id as id_giao_dich,
customer.Cust_name as Ten_Khach_Hang,
transactions.t_date as Ngay_giao_dich,
transactions.t_amount as So_tien_giao_dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where DATEPART(quarter,t_date)=4 and t_type=1 and 
t_amount=(select max(transactions.t_amount) from transactions where DATEPART(quarter,t_date)=4 and t_type=1)

-- câu 26 :Để bổ sung nhân sự cho các chi nhánh, cần có kết quả phân tích về cường độ làm việc của họ. 
--Hãy liệt kê những chi nhánh phải làm việc qua trưa và loại giao dịch là gửi tiền.
select Branch.BR_name as Ten_chi_nhanh,
transactions.t_type as Loai_giao_dich,
transactions.t_time as Thoi_gian_lam_viec
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where datepart(hour,t_time) between 12 and 13 and t_type=1 
--cách 2 
select Branch.BR_name as Ten_chi_nhanh,
transactions.t_type as Loai_giao_dich,
transactions.t_time as Thoi_gian_lam_viec
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where t_time between '12:00:00' and '13:00:00' and t_type=1 

-- cách 1 và cách 2 có sự khác nhau 

-- câu 27 :Hãy liệt kê các giao dịch bất thường. 
--Gợi ý: là các giao dịch gửi tiền những được thực hiện ngoài khung giờ làm việc và cho phép overtime (từ sau 16h đến trước 7h)

-- cách 1 : sài hẳn t_time between 
SELECT transactions.t_id as Id_giao_dich, 
customer.Cust_name as Ten_khach_hang, 
transactions.t_date as ngay_giao_dich,
transactions.t_time as Gio_giao_dich
FROM transactions 
JOIN account ON transactions.ac_no = account.Ac_no 
JOIN customer ON account.cust_id = customer.Cust_id 
JOIN Branch ON customer.br_id = Branch.BR_id
JOIN Bank ON Branch.B_id = Bank.b_id
WHERE t_type = 1 
and DATEPART(dw, t_date) = 1 or DATEPART(dw, t_date) = 7
and t_time between '16:00:00' and '7:00:00'

--cahcs 2 : sài datepart(hour,t_time) between , nên nhớ chỉ được ghi số , ko được ghi là 16:00:00
SELECT transactions.t_id as Id_giao_dich, 
customer.Cust_name as Ten_khach_hang, 
transactions.t_date as ngay_giao_dich,
transactions.t_time as Gio_giao_dich
FROM transactions 
JOIN account ON transactions.ac_no = account.Ac_no 
JOIN customer ON account.cust_id = customer.Cust_id 
JOIN Branch ON customer.br_id = Branch.BR_id
JOIN Bank ON Branch.B_id = Bank.b_id
WHERE t_type = 1 
and DATEPART(dw, t_date) = 1 or DATEPART(dw, t_date) = 7
and datepart(hour,t_time) between 16 and 7

--câu 28 : Hãy điều tra những giao dịch bất thường trong năm 2017. 
--Giao dịch bất thường là giao dịch diễn ra trong khoảng thời gian từ 12h đêm tới 3 giờ sáng.
SELECT transactions.t_id as Id_giao_dich, 
customer.Cust_name as Ten_khach_hang, 
transactions.t_date as ngay_giao_dich,
transactions.t_time as Gio_giao_dich
FROM transactions 
JOIN account ON transactions.ac_no = account.Ac_no 
JOIN customer ON account.cust_id = customer.Cust_id 
JOIN Branch ON customer.br_id = Branch.BR_id
WHERE (t_time not between '07:30:00.0000000' and '12:00:00.0000000'
					  and	t_time not between '13:30:00.0000000' and '17:00:00.0000000' and t_type = 1)
or t_type = 0 and t_time between '00:00:00.0000000' and '03:00:00.0000000'
--and DATEPART(YEAR, t_date) = 2017
-- có thắc mắc là tại sao sài t_time '24:00:00' lại bị lỗi mà t_time '12:00:00' lại ko lỗi ? 
--Lỗi bị là :Conversion failed when converting date and/or time from character string.

--câu 29 : Có bao nhiêu người ở Đắc Lắc sở hữu nhiều hơn một tài khoản?
select count(*) as slng from 
(select Cust_name from customer
join account on customer.Cust_id = account.cust_id
where Cust_ad like N'%Đăk Lăk' or Cust_ad like N'%ĐăkLăk'
group by Cust_name
having count(Ac_no) > 1 ) as Tai_khoan

--câu 30 : Nếu mỗi giao dịch rút tiền ngân hàng thu phí 3.000 đồng, 
--hãy tính xem tổng tiền phí thu được từ thu phí dịch vụ từ năm 2012 đến năm 2017 là bao nhiêu?
SELECT
    SUM(CASE WHEN YEAR(t_date) BETWEEN 2012 AND 2017 AND t_type=0 THEN 3000 ELSE 0 END) AS Tong_Tien_Phi_Thu_Duoc
FROM transactions



--câu 31 :Hiển thị thông tin các khách hàng họ Trần theo các cột sau: (chưa xong)
-- tạo bảng tạm bảng tạm , xong slect join bảng tạm vs bảng account
select customer.Cust_id,Cust_name,
SUBSTRING(Cust_name, 1, (len(Cust_name)-CHARINDEX(' ',reverse(Cust_name)))) as firstname,
SUBSTRING(Cust_name, (len(Cust_name)-CHARINDEX(' ',reverse(Cust_name))+2),10)as Lastname
into Table1
from customer 

select Table1.Cust_id as Mã_KH,
firstname as Họ,
Lastname as Tên,
account.ac_balance as Số_Dư_Tài_Khoản,
account.Ac_no
from Table1 join account on  account.cust_id = Table1.Cust_id 
where Cust_name like N'Trần%'


--cách 2 : siêu đơn giản : 
select customer.Cust_id as Mã_KH,
SUBSTRING(Cust_name, 1, (len(Cust_name)-CHARINDEX(' ',reverse(Cust_name)))) as Họ,
SUBSTRING(Cust_name, (len(Cust_name)-CHARINDEX(' ',reverse(Cust_name))+2),10) as Tên,
account.ac_balance as So_Du_Tai_Khoan
from customer  join account on  account.cust_id = customer.Cust_id 
where Cust_name like N'Trần%'

--check
select * from customer 
where Cust_name like N'Trần%'

--câu 32 : Cuối mỗi năm, nhiều khách hàng có xu hướng rút tiền khỏi ngân hàng để chuyển sang ngân hàng khác hoặc chuyển sang hình thức tiết kiệm khác. 
--Hãy lọc những khách hàng có xu hướng rút tiền khỏi ngân hàng bằng hiển thị những người rút gần hết tiền trong tài khoản 
--(tổng tiền rút trong tháng 12/2017 nhiều hơn 100 triệu và số dư trong tài khoản còn lại <= 100.000)
select customer.Cust_name as Ten_Khach_Hang, 
account.ac_balance as So_Du_Tai_Khoan,
sum(transactions.t_amount) as Tong_Tien_Rut_Khoi_Ngan_Hang
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where MONTH(t_date)=12 
and YEAR(t_date)=2017 
and t_type=0
group by Cust_name , ac_balance
having sum(transactions.t_amount)>100000 and account.ac_balance <= 100000

-- câu 33 : Thời gian vừa qua, hệ thống CSDL của ngân hàng bị hacker tấn công (giả sử tí cho vui J), tổng tiền trong tài khoản bị thay đổi bất thường. Hãy liệt kê những tài khoản bất thường đó. 
--Gợi ý: tài khoản bất thường là tài khoản có tổng tiền gửi – tổng tiền rút <> số tiền trong tài khoản
select
    account.Ac_no as STK,
	account.ac_balance as so_du_tai_khoan,
    SUM(CASE WHEN transactions.t_type = 1 THEN transactions.t_amount ELSE 0 END) AS Tong_tien_gui,
    SUM(CASE WHEN transactions.t_type = 0 THEN transactions.t_amount ELSE 0 END) AS Tong_tien_rut
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
GROUP BY account.Ac_no, account.ac_balance
HAVING SUM(CASE WHEN transactions.t_type = 1 THEN transactions.t_amount ELSE -transactions.t_amount END) <> account.ac_balance

--câu 34 :Do hệ thống mạng bị nghẽn và hệ thống xử lý chưa tốt phần điều khiển đa người dùng nên một số tài khoản bị invalid. 
--Hãy liệt kê những tài khoản đó. Gợi ý: tài khoản bị invalid là những tài khoản có số tiền âm. 
--Nếu có thể hãy liệt kê giao dịch gây ra sự cố tài khoản âm.
--Giao dịch đó được thực hiện ở chi nhánh nào? (mục đích để quy kết trách nhiệm J)
select account.Ac_no as stk,
account.ac_balance as so_du_tai_khoan,
transactions.t_id as id_giao_dich,
Branch.BR_name as Ten_Chi_Nhanh,
customer.Cust_name as Nguoi_thuc_hien_giao_dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where account.ac_balance <0

--câu 35 :(Giả sử) Gần đây, một số khách hàng ở chi nhánh Đà Nẵng kiện rằng: 
--tổng tiền trong tài khoản không khớp với số tiền họ thực hiện giao dịch. 
--Hãy điều tra sự việc này bằng cách hiển thị danh sách khách hàng ở Đà Nẵng bao gồm các thông tin sau:
--mã khách hàng, họ tên khách hàng, tổng tiền đang có trong tài khoản, tổng tiền đã gửi, tổng tiền đã rút, kết luận (nếu tổng tiền gửi – tổng tiền rút = số tiền trong tài khoản à OK, trường hợp còn lại à có sai)
SELECT
    customer.Cust_id AS Ma_KH,
    customer.Cust_name AS Ho_Ten_KH,
    account.ac_balance AS Tong_Tien_Trong_Tai_Khoan,
    COALESCE(SUM(CASE WHEN transactions.t_type = 1 THEN transactions.t_amount ELSE 0 END), 0) AS Tong_Tien_Gui,
    COALESCE(SUM(CASE WHEN transactions.t_type = 0 THEN transactions.t_amount ELSE 0 END), 0) AS Tong_Tien_Rut,
    CASE
        WHEN account.ac_balance = COALESCE(SUM(CASE WHEN transactions.t_type = 1 THEN transactions.t_amount ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN transactions.t_type = 0 THEN transactions.t_amount ELSE 0 END), 0) THEN 'OK'
        ELSE 'Sai'
    END AS Ket_Luan
FROM customer
LEFT JOIN account ON customer.Cust_id = account.cust_id
LEFT JOIN transactions ON account.Ac_no = transactions.ac_no
LEFT JOIN Branch ON customer.Br_id = Branch.BR_id
WHERE Branch.BR_name = N'%Đà Nẵng'
GROUP BY customer.Cust_id, customer.Cust_name, account.ac_balance
HAVING
    SUM(CASE WHEN t_type = 1 THEN t_amount ELSE -t_amount END) <> account.ac_balance;


-- câu 35
select distinct(customer.Cust_name) as Ten_Khach_Hang,
account.Ac_no as TaiKhoan,
account.ac_balance as So_du,
sum(case when transactions.t_type=1 then transactions.t_amount else 0 end) as Tien_gui,
sum(case when transactions.t_type=0 then transactions.t_amount else 0 end) as Tien_rut,
sum(case when transactions.t_type=1 then transactions.t_amount else -transactions.t_amount end) as Tien_con_lai,
case
	when sum(case when transactions.t_type =1 then transactions.t_amount else -transactions.t_amount end)=account.ac_balance then 'OK'
	else 'Sai'
end as ket_luan
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where Branch.BR_name like N'%Đà Nẵng'
group by Cust_name,account.Ac_no,account.ac_balance	

--35: cách 2 
SELECT
    customer.Cust_id,
    customer.Cust_name,
    ac_balance,
    SUM(CASE WHEN transactions.t_type = 1 THEN transactions.t_amount ELSE 0 END) AS 'Tổng tiền gửi',
    SUM(CASE WHEN transactions.t_type = 0 THEN transactions.t_amount ELSE 0 END) AS 'Tổng tiền rút',
    IIF(SUM(CASE WHEN transactions.t_type = 1 THEN transactions.t_amount ELSE -transactions.t_amount END) = ac_balance, 'OK', 'Có sai') AS 'Kết luận'
FROM Branch
JOIN customer ON Branch.Br_id = customer.br_id 
JOIN account ON customer.Cust_id = account.cust_id
 JOIN transactions ON account.ac_no = transactions.ac_no
WHERE BR_name LIKE N'%Đà Nẵng'
GROUP BY customer.Cust_id, customer.Cust_name, ac_balance;

-- câu 36 : Ngân hàng cần biết những chi nhánh nào có nhiều giao dịch rút tiền vào buổi chiều để chuẩn bị chuyển tiền tới. 
--Hãy liệt kê danh sách các chi nhánh và lượng tiền rút trung bình theo ngày (chỉ xét những giao dịch diễn ra trong buổi chiều), 
--sắp xếp giảm giần theo lượng tiền giao dịch

-- cách 1 : Sài thẳng t_time
select BR_name as Chi_Nhanh_Giao_Dich,
AVG(t_amount) as TB_rut ,
transactions.t_time as Gio_rut_tien
from transactions
inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id 
where t_type = 0 and t_time between '13:30:00' and '17:00:00'
group by BR_name,t_time
order by AVG(t_amount) desc
-- cách 2 : sài datepart(hour,t_time)
select BR_name as Chi_Nhanh_Giao_Dich,
AVG(t_amount) as TB_rut ,
transactions.t_time as Gio_rut_tien
from transactions
inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id 
where t_type = 0 and datepart(HOUR,t_time) between 12 and 17
group by BR_name,t_time
order by AVG(t_amount) desc












SELECT Cust_name, Cust_phone,Cust_id
FROM customer
JOIN Branch ON customer.Br_id = Branch.BR_id
WHERE BR_name = N'Vietcombank Sài Gòn' 
AND Cust_name NOT IN (
    SELECT Cust_name 
    FROM customer
    JOIN account ON customer.Cust_id = account.cust_id
    JOIN transactions ON account.ac_no = transactions.ac_no
    WHERE YEAR(t_date) >= YEAR(DATEADD(year, -3, GETDATE()))
)
UNION ALL
SELECT count(Cust_id) as tong, NULL,NULL
FROM customer
JOIN Branch ON customer.Br_id = Branch.BR_id
WHERE BR_name = N'Vietcombank Sài Gòn' 
AND Cust_name NOT IN (
    SELECT Cust_name 
    FROM customer
    JOIN account ON customer.Cust_id = account.cust_id
    JOIN transactions ON account.ac_no = transactions.ac_no
    WHERE YEAR(t_date) >= YEAR(DATEADD(year, -3, GETDATE()))
)

SELECT  Cust_name as ten_khach_hang, 
        Cust_phone as So_dien_thoai,
        COUNT(Cust_name) as So_luong_khach_hang
FROM customer
JOIN Branch ON customer.Br_id = Branch.BR_id
WHERE BR_name = N'Vietcombank Sài Gòn' 
AND Cust_name NOT IN (
    SELECT Cust_name 
    FROM customer
    JOIN account ON customer.Cust_id = account.cust_id
    JOIN transactions ON account.ac_no = transactions.ac_no
    WHERE YEAR(t_date) >= YEAR(DATEADD(year, -3, GETDATE()))
)
GROUP BY Cust_name, Cust_phone WITH ROLLUP