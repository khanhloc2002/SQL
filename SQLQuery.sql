-- btap câu lớp
use Bank

select * from account
select * from customer
select * from transactions
select * from Branch


select Cust_name as Ten_Khach_Hang,
Cust_ad as Dia_chi
from customer
where Cust_ad like N'%ĐÀ NẴNG' or Cust_ad like N'%ĐÀNẴNG' or Cust_ad like N'%ĐÀ NẴNG %'

-- 1
select transactions.t_id as ID_GIAO_DICH,
customer.Cust_id as ID_KHACH_HANG_GIAO_DICH,
Branch.BR_id as ID_NGAN_HANG 
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
Where datepart(quarter,t_date)=4 and year (t_date)=2016
--2 
select transactions.t_id as ID_GIAO_DICH,
customer.Cust_id as ID_KHACH_HANG_GIAO_DICH,
Branch.BR_id as ID_NGAN_HANG 
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
Where datepart(quarter,t_date)=3 and year (t_date)=2016
--3 :
select BR_name as Ten_Ngan_Hang,
BR_ad as Dia_chi
from Branch
where BR_ad is null or BR_ad =' '
--4 
SELECT Cust_name as Ten_Khach_Hang
FROM customer
WHERE Cust_name like N'%[a,á,à,ạ,ã,u,ũ,ụ,ù,ú,i,í,ì,ị,ĩ]__'
--5
select Cust_name as Ten_Khach_Hang,
Cust_phone as So_Dien_Thoai
from customer
where Cust_phone not like '090%'
or Cust_phone not like '093%'
or Cust_phone not like '089%'
--6 
SELECT Cust_name as Ten_Khach_Hang,
SUBSTRING(Cust_ad , (LEN(Cust_ad) - CHARINDEX(' ', REVERSE(Cust_ad), 8) + 2), 15) as Thanh_Pho
FROM customer

--btclass 5/9
--câu 1 : 
select customer.Cust_name as Ten_Khach_Hang,
customer.Br_id as Ma_Chi_Nhanh
from customer
where Br_id=(select customer.Br_id from customer where Cust_name like N'Nguyễn Tiến Trung')
and Cust_name <> N'Nguyễn Tiến Trung'

--câu 2 : Hiển thị danh sách chi nhánh và tổng tiền giao dịch theo từng năm 
select Branch.BR_name as Ten_Chi_Nhanh,
sum(transactions.t_amount) as Tong_Tien_Giao_Dich,
year(transactions.t_date) as Nam_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
group by Branch.Br_name, year(transactions.t_date)
order by Br_name

-- câu 3 : Hiển thị dánh dách khách hàng của mỗi chi nhánh và tổng tiền họ có 
select customer.Cust_name as Ten_Khach_Hang,
Branch.Br_name as Ten_Chi_Nhanh,
sum(account.ac_balance) as Tong_Tien
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where ac_balance >0
group by Branch.Br_name, customer.Cust_name
order by sum(account.ac_balance)

-- câu 4 : Thống kê số lượng giao dịch của chi nhánh Đà Nẵng năm 2016 -2018 theo từng loại giao dịch 
select count (t_id) as So_Luong_Giao_Dich,
year(t_date) as Nam_Giao_Dich,
Branch.Br_name as  Ten_Chi_Nhanh,
transactions.t_type as Loai_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id
inner join Branch on customer.Br_id = Branch.BR_id
where BR_name like N'%Đà Nẵng%' and year(t_date) between 2016 and 2018
group by  year(t_date),Branch.Br_name,transactions.t_type
order by t_type

-- câu 5 : Ai là người thược hiện giao dịch gửi nhiều tiền nhất vào chi nhánh huế , số lượng gửi là bao nhiêu 
select customer.Cust_name as Ten_Khach_Hang ,
Branch.Br_name as Ten_Chi_Nhanh,
transactions.t_amount as Tong_Tien_Giao_Dich
from transactions inner join account on account.Ac_no= transactions.ac_no
inner join customer on account.cust_id=customer.Cust_id												
inner join Branch on customer.Br_id = Branch.BR_id
WHERE transactions.t_type = 1
    AND transactions.t_amount = (
        SELECT MAX(transactions.t_amount)
        FROM transactions
        INNER JOIN account ON account.Ac_no = transactions.ac_no
        INNER JOIN customer ON account.cust_id = customer.Cust_id
        INNER JOIN Branch ON customer.Br_id = Branch.BR_id
        WHERE Branch.BR_name LIKE N'%Huế%'
    )
    AND Branch.BR_name LIKE N'%Huế%'

--btktra về nhà : Thống kê số lượng khách hàng chwua thực hiện GD nào của mỗi chi nhánh 

select count(customer.Cust_id) as khách_hàng,
BR_name as Ten_Chi_Nhanh
from branch join customer on Branch.Br_id = customer.br_id 
            join account on customer.Cust_id = account.cust_id
where Ac_no not in (select ac_no from transactions)
group by BR_name

 





