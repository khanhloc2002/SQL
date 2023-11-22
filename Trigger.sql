/* câu 1 : Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
i.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii.	Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
*/
--
go 
create or alter trigger fcau1
on transactions
after insert
as
begin
	declare @ac_type int, @kq nvarchar(100), @ac_no int, @t_amount money, @ac_bl money
	select @t_amount=t_amount, @ac_no=ac_no  from inserted 
	select @ac_type=ac_type from account  where Ac_no=@ac_no
	if @ac_type=9
		begin
			set @kq=N'‘tài khoản đã bị xóa’'
			rollback
		end
	else if @ac_type=1	
		begin
			update account 
			set ac_balance=ac_balance-@t_amount where Ac_no=@ac_no
		end
	else if @ac_type=0 
		begin
			update account set ac_balance=ac_balance+@t_amount where Ac_no=@ac_no
			select @ac_bl= ac_balance from account where Ac_no=@ac_no
			if @ac_bl<50000
				begin
					print N'khong du tien'
					rollback
				end
		end
end
insert into transactions values ('9976979',0,5000,'2023-03-29','08:00:00','406')
select*from transactions
select*from account
/*2.Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:
a.	Nếu là giao dịch rút
Số dư = số dư cũ + t_amount
b.	Nếu là giao dịch gửi
Số dư = số dư cũ – t_amount
*/
go
create or alter trigger fCau2
on transactions
after update
as
begin
	declare @t_type int, @t_amount money, @ac_no varchar(10)
	select @t_amount=t_amount, @t_type=t_type, @ac_no=ac_no from deleted
	if @t_type=1
		begin
			update account set ac_balance=ac_balance-@t_amount where Ac_no=@ac_no
		end
	else if @t_type=0
		begin
			update account set ac_balance=ac_balance+@t_amount where Ac_no=@ac_no
		end
end
--
delete transactions where t_id='0000000201'
/*3.Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự. */
go 
create or  alter  trigger fCau3
on customer
after insert, update
as 
begin
	declare @ten nvarchar(50), @id varchar
	select @ten=Cust_name, @id=Cust_id from inserted
	if len(@ten)<5
		begin
			print 'Ten khong hop le'
			rollback
		end
	else
		begin
			update customer 
			set Cust_name=@ten where Cust_id=@id
		end
end

select *from customer

insert into customer values('000036', N'Công Lực','01283388178','EAHLEO - ĐĂKLĂK', 'VT009')
update customer set Cust_name=N'Công Lực' where Cust_id='000001'
/* 4.Khi xóa dữ liệu trong bảng account, hãy thực hiện thao tác cập nhật trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.*/
go
go
create trigger fCau4
on account
instead of delete
as
begin
	declare @Ac_no varchar(10)
	select @Ac_no=Ac_no from deleted
	update account
	set ac_type=9 where Ac_no=@Ac_no
end
--
delete account where Ac_no='1000000056'
select*from account
/*5.Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
i.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii.	Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
*/
-- y  câu 1 
/*6 :Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư:
Số dư = số dư cũ + (số dữ mới – số dư cũ)
*/
go
create or alter trigger fcau6
on transactions
after update
as
begin
	declare @t_amount money, @ac_no varchar(10)
	select  @ac_no=ac_no from inserted
	begin
		update account set ac_balance=ac_balance+((select t_amount from inserted) -(select t_amount from deleted)) where Ac_no=@ac_no
	end

end
--
update transactions 
set t_amount=4000 where t_id='0000000224'
select*from transactions
select * from account where Ac_no=1000000041
--0000000224
--227373993
select transactions.t_amount ,account.ac_balance , transactions.t_id, account.Ac_no from transactions
INNER JOIN account ON account.Ac_no = transactions.ac_no
INNER JOIN customer ON account.cust_id = customer.Cust_id
INNER JOIN Branch ON customer.Br_id = Branch.BR_id
where account.Ac_no=1000000041
/*7.Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:
a.	Nếu là giao dịch rút
Số dư = số dư cũ + t_amount
b.	Nếu là giao dịch gửi
Số dư = số dư cũ – t_amount
*/


/* câu 9 : Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản. 
Nếu ac_type = 9 (đã bị xóa) thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện.*/
--
go
create or alter trigger fCau9
on account
after insert,update,delete
as
begin
	declare @ac_type int
	select @ac_type=ac_type from inserted
	if @ac_type=9
		begin
			print N'Tài khoản đã bị xoá'
		end
end
--
insert into account values('1000000058','50000',1,'000019')
update account set ac_type=9 where Ac_no='1000000001'
delete account where Ac_no='1000000001'
select*from account
--- Lỗi : The transaction ended in the trigger. The batch has been aborted. khi mà chưa hoàn thiện cái cú pháp trên
/*10.Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng thì đưa ra thông báo ‘đã tồn tại khách hàng’ 
và hủy toàn bộ thao tác.*/
go
create or alter trigger fCau10
on customer
after insert
as
begin
	declare @hoTen nvarchar(100), @sdt int, @kq int
	select @kq=COUNT(*) from(select *from customer where Cust_name=(select Cust_name from inserted) and Cust_phone=(select Cust_name from inserted)) as A
	if @kq>=1
		begin
			print N'Đã tồn tại'
			rollback
		end
end
--
insert into customer values('001101',N'Híu','0138788103','hihghig','VT009')
select * from customer
/*-11.Khi thêm mới dữ liệu vào bảng account, hãy kiển tra mã khách hàng. 
Nếu mã khách hàng chưa tồn tại trong bảng customer thì đưa ra thông báo ‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác. */
go
go
create or alter trigger fCau11
on customer
after insert
as
begin 
	declare @maKH varchar(10)
	if  not exists (select Cust_id=@maKH from inserted)
		begin
			print N'Khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
			rollback
		end
end
--
insert into account values('1000001101','500',1,'000119')