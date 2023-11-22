use Bank
-- câu 1 :Liệt kê những khách hàng không thuộc các chi nhánh miền bắc
select * from customer
select * from Branch
-- cách 1 : 
select distinct(customer.Cust_name) as Ten_Khach_Hang,
customer.Cust_ad as Dia_Chi
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where Branch.BR_id not like 'VB%'
--cách 2 
select distinct(customer.Cust_name) as Ten_Khach_Hang,
customer.Cust_ad as Dia_Chi
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where Branch.BR_id  like 'VN%' 
or Branch.BR_id like 'VT%'
--câu 2 : Liệt kê những tài khoản nhiều hơn 100 triệu trong tài khoản
select account.Ac_no as id_tai_khoan,
customer.Cust_name as Ten_Khach_Hang,
account.ac_balance as So_Du
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where ac_balance >100000000
--câu 3 : Liệt kê những giao dịch gửi tiền diễn ra ngoài giờ hành chính
select transactions.t_id as Id_Giao_Dich_Gui_Tien
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where t_type =1 and datepart(HOUR,t_time) between 8 and 17
-- câu 4 : Liệt kê những giao dịch rút tiền diễn ra vào khoảng từ 0-3h sáng
select transactions.t_id as Id_Giao_Dich_Rut_Tien
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where t_type =0 and datepart(HOUR,t_time) between 0 and 3
-- câu 5 : Tìm những khách hàng có địa chỉ ở Ngũ Hành Sơn – Đà nẵng
select Cust_name as Ten_Khach_Hang,
Cust_ad as Dia_Chi
from customer
where Cust_ad like N'%Đà Nẵng%'
and Cust_ad like N'%Ngũ Hành Sơn%'
--câu 6 :Liệt kê những chi nhánh chưa có địa chỉ
select * from Branch
where BR_ad is null or BR_ad =' '
--câu 7 : Liệt kê những giao dịch rút tiền bất thường (nhỏ hơn 50.000)
select transactions.t_id as Id_Giao_Dich_Rut_Tien
from transactions
where t_amount <50000 and t_type =0
--câu 8 : Liệt kê các giao dịch gửi tiền diễn ra trong năm 2017.
select transactions.t_id as Id_Giao_Dich_Chuyen_Tien,
Branch.Br_name as Ngan_Hang_Thuc_Hien_Giao_Dich,
customer.Cust_name as Ten_Khach_Hang
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where datepart(year,t_date) =2017 and t_type=1
-- câu 9 : Liệt kê những giao dịch bất thường (tiền trong tài khoản âm)
select transactions.t_id as Id_Giao_Dich,
account.Ac_no as Tai_Khoan_Thuc_Hien_Giao_Dich,
customer.Cust_name as Ten_Khach_Hang
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where ac_balance <0
-- câu 10 :Hiển thị tên khách hàng và tên tỉnh/thành phố mà họ sống
SELECT Cust_name,
SUBSTRING(Cust_ad , (LEN(Cust_ad) - CHARINDEX(' ', REVERSE(Cust_ad), 8) + 2), 15) as TP
FROM customer


--câu 11 : Hiển thị danh sách khách hàng có họ tên không bắt đầu bằng chữ N, T
SELECT Cust_name as Ten_Khach_Hang
FROM customer
except
(select Cust_name
from customer
where Cust_name like N'N%'
union
select Cust_name
from customer
where Cust_name like N'T%'
union
select Cust_name
from customer
where Cust_name = N'Lê Minh Trí'
)

--(SELECT * (SELECT 
--    Cust_name,
--    RIGHT(Cust_name, CHARINDEX(' ', REVERSE(Cust_name)) - 1) AS Tên,
--    LEFT(Cust_name, LEN(Cust_name) - CHARINDEX(' ', REVERSE(Cust_name))) AS Họ
--FROM customer) as tenmoinguoi
--from tenmoinguoi
--where tenmoinguoi.Tên Like 'N%' and tenmoinguoi.Họ like 'N%'
--union
--SELECT * (SELECT 
--    Cust_name,
--    RIGHT(Cust_name, CHARINDEX(' ', REVERSE(Cust_name)) - 1) AS Tên,
--    LEFT(Cust_name, LEN(Cust_name) - CHARINDEX(' ', REVERSE(Cust_name))) AS Họ
--FROM customer) as tenmoinguoi
--from tenmoinguoi
--where tenmoinguoi.Tên Like 'T%' and tenmoinguoi.Họ like 'T%') 

--câu 12 : Hiển thị danh sách khách hàng có kí tự thứ 3 từ cuối lên là chữ a, u, i
SELECT Cust_name as Ten_Khach_Hang
FROM customer
WHERE Cust_name like N'%[a,u,i]__'


-- câu 13 :  Hiển thị khách hàng có tên đệm là Thị hoặc Văn
select Cust_name as Ten_Khach_Hang
from customer
where Cust_name like N'% Thị %' or Cust_name like N'% Văn %' 
select customer.Cust_name from customer
-- câu 14 : . Hiển thị khách hàng có địa chỉ sống ở vùng nông thôn. 
--Với quy ước: nông thôn là vùng mà địa chỉ chứa: thôn, xã, xóm
SELECT Cust_name as Tên_Khach_Hang, 
Cust_ad as Dia_Chi
From customer
WHERE Cust_ad like N'%thôn%'
or (Cust_ad like N'%xã%' and Cust_ad not like N'%thị xã%')
or Cust_ad like N'%xóm%'
-- câu 15 : Hiển thị danh sách khách hàng có kí tự thứ hai của TÊN là chữ u hoặc ũ hoặc a. 
--Chú ý: TÊN là từ cuối cùng của cột cust_name

SELECT
    cust_name AS Ten_khach_hang,
    CASE
        WHEN SUBSTRING(REVERSE(SUBSTRING(REVERSE(cust_name), 1, CHARINDEX(' ', REVERSE(cust_name))-1)), 2, 1) IN (N'u', N'ũ', N'a')
            THEN SUBSTRING(REVERSE(SUBSTRING(REVERSE(cust_name), 1, CHARINDEX(' ', REVERSE(cust_name))-1)), 2, 1)
    END AS second_character
FROM
    customer
WHERE
    SUBSTRING(REVERSE(SUBSTRING(REVERSE(cust_name), 1, CHARINDEX(' ', REVERSE(cust_name))-1)), 2, 1) IN (N'u', N'ũ', N'a');












