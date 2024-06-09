/*joins*/
/*creating table of sales from year 2015*/
create table sales_2015 as select * from sales where ship_date between '2015-02-01' and '2015-12-31';
select count(*) from sales_2015; --2131
select count(distinct customer_id) from sales_2015; --578

/* customers with age between 20 and 60 */
create table customer_20_60 as select * from customer where age between 20 and 60;
select count(*) from customer_20_60; --597
select * from customer_20_60;
select * from sales_2015;
create table inner_join1 as (
		select 
			a.order_line,
			a.product_id,
			a.customer_id,
			a.sales,
			b.customer_name,
			b.age
		from sales_2015 as a
		inner join customer_20_60 as b
		on a.customer_id = b.customer_id
		order by customer_id)
select * from inner_join1;

select 
			a.order_line,
			a.product_id,
			a.customer_id,
			a.sales,
			b.customer_name,
			b.age
from sales_2015 as a
left join customer_20_60 as b
on a.customer_id = b.customer_id
order by customer_id;
-- right join
select 
			a.order_line,
			a.product_id,
			a.customer_id,
			a.sales,
			b.customer_name,
			b.age
from sales_2015 as a
right join customer_20_60 as b
on a.customer_id = b.customer_id
order by customer_id;
-- full join
select 
			a.order_line,
			a.product_id,
			a.customer_id,
			a.sales,
			b.customer_name,
			b.age
from sales_2015 as a
full join customer_20_60 as b
on a.customer_id = b.customer_id
order by customer_id;
-- cross join
create table month_values (MM integer);
create table year_values (YYYY integer);

insert into month_values values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);
insert into year_values values (2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018),(2019);
select a.YYYY, b.MM
from year_values as a, month_values as b
order by a.YYYY , b.MM ;
-- or
select year_values.YYYY, month_values.MM
from year_values
cross join month_values;
-- combining queries
-- intersect
select customer_id from sales_2015
intersect
select customer_id from customer_20_60;
-- subquery
WITH CustomerIDs AS (
    SELECT CustomerID
    FROM Orders
    WHERE Product = 'Widget A'
)
SELECT CustomerName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM CustomerIDs);
-- view/ create or replace view
create view logistics 
	as (
	select a.order_id,
	b.customer_name,
	b.city,
	b.state,
	b.country
	from sales as a
	left join customer as b
	on a.customer_id = b.customer_id
	order by a.order_line)
	select * from logistics;
drop view logistics;
-- index
create index mon_idex
on month_values(MM);
--string function
-- length(string)
select customer_name, length(customer_name) as characters_num
from customer
where age> 30;
-- upper(string)lower(string)
-- used when matching strings to maintane uniformity
select upper('Start-Tech-Achademy');
select lower('Start-Rech-Academy');
-- replace
select customer_name, country,
replace(country,'United States','US') as country_new
from customer;
-- trim([leading|trailing|both)-rtrim-ltrim
select trim( leading'  ' from '  Start-Tech-Academy');
-- concatanation- joining a few strings
select customer_name, city||','||state||','||country 
	as address from customer;
-- substrring function
select customer_id , customer_name,
substring(customer_id for 2) as cust_group
from customer
where substring(customer_id for 2) = 'JB';

select customer_id, customer_name,
substring(customer_id from 4 for 5) as customer_num
from customer
where substring(customer_id for 2) = 'AB';
-- string aggregater
select * from sales order by order_id;
select order_id, string_agg(product_id,', ')
from sales
group by order_id
order by order_id;
-- Mathmatical functions, CEIL-Floor, Random
select order_line,
	sales, 
	CEIL(sales),
	FLOOR(sales) from sales
where discount>0;

/* random 
	a= 10,
	b= 50 */
select random(), random() * 40 + 10,
floor(random() * 40 + 10);
-- SETSEED
select setseed(0.5);
select random();
select random();

-- round
select order_line,
	sales, 
	round(sales)
from sales order by sales DESC;
-- Power
select power(age,2), age from customer;

-- DATE AND TIME FUNCTIONS
select current_date, current_time, current_time(1), 
	current_time(3), current_timestamp;
select order_line,
	ship_date,
	order_date,
	age(ship_date,order_date) as time_taken
from sales
order by time_taken DESC;

select extract(day from current_date);
select order_date, ship_date,
	(extract(epoch from ship_date) - extract(epoch from order_date)) as sec_taken
from sales;
-- Pattern matching

select Name from Students where Name like 'Ja%';
select * from customer 
where customer_name ~* '^(a|b|c|d)+[a-z\s]+$'

-- WINDOW FUNCTIONS
-- SELECT <CULOMN1>, <CULOMN2>,
-- <WINDOW FUNCTION>() OVER (
-- 	PARTITON BY<.....>
-- 	FROM <TABLE_NAME>;
create table customer_order as (select a.*,b.order_num, b.sales_tot, b.quantity_tot,
	b.profit_tot
from customer as a
left join (select customer_id,count(distinct order_id) as
	order_num,sum(sales) as sales_tot, sum(quantity) as
	quantity_tot, sum(profit) as profit_tot from sales
	group by customer_id) as b
	on a.customer_id = b.customer_id);
select * from customer_order;

select customer_id, customer_name, state, order_num, 
	row_number() over (partition by state order by 
	order_num DESC) as row_n from customer_order
	where row_n<=3; 

select customer_id, customer_name,state, order_num,
row_number() over (partition by state order by order_num desc)
as row_n, rank() over (partition by state order by order_num desc)
as rank_n, dense_rank() over (partition by state order by order_num desc)
as drank_n
from customer_order;

WITH RankedEmployees AS (
    SELECT FirstName, LastName, Salary,
           RANK() OVER (ORDER BY Salary DESC) AS Rank,
           DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank
    FROM Employees
)
SELECT FirstName, LastName, Salary, Rank, DenseRank
FROM RankedEmployees
WHERE Rank <= 3;

-- NTILE fro percentages of the customers
select * from (select customer_id, customer_name,state, order_num,
row_number() over (partition by state order by order_num desc)
as row_n, rank() over (partition by state order by order_num desc)
as rank_n, dense_rank() over (partition by state order by order_num desc)
as drank_n,ntile(5) over (partition by state order by order_num desc)
as tile_n	
from customer_order ) as a where a.tile_n=1;
-- the practice
with RankedEmployees AS (
select FirstName, LastName, Salary,
rank() over (order by salary) as rank,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank,
ntile(4) over (order by salary) as Quartile
from Employees)
select FirstName, LastName, Salary, Quartile
from RankedEmployees;
-- average function
select customer_id,customer_name,state, sales_tot 
	as revenue, avg(sales_tot) over (partition by state)
    as avg_revenue
from customer_order;

with RankedEmployees AS (
select FirstName, LastName, Salary,
rank() over (order by salary) as rank,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank,
AVG(Salary) OVER (ORDER BY Salary DESC)
from Employees)
select AVG(Salary)
from RankedEmployees;
-- count
select customer_id, customer_name, state,
count(customer_id) over (partition by state) as
count_cust 
from customer_order;
-- practice
with RankedEmployees AS (
select FirstName, LastName, Salary,EmployeeID,
rank() over (order by salary) as rank,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank,
AVG(Salary) OVER (ORDER BY Salary DESC),
COUNT(*) OVER ( order by FirstName)
from Employees)
select COUNT(*)
from RankedEmployees;

-- sum_total
create table order_rollup as
	select 
	order_id,
	max(order_date) as order_date,
	max(customer_id) as customer_id, 
	sum(sales) as sales
	from sales
	group by order_id;

Drop table order_rollup_state;
create table order_rollup_state as select a.*, b.state
from order_rollup as a
left join customer as b
on a.customer_id = b.customer_id;
select * from order_rollup_state;

select *, 
sum(sales) over (partition by state) as sales_state_total
from order_rollup_state;

select *,
sum(sales) over (partition by state) as sales_state_total,
	sum(sales) over (partition by state
	order by order_date) as running_total 
	from order_rollup_state;
-- LAG,LEAD
select customer_id, order_date, order_id, sales,
lag(sales,1) over (partition by customer_id 
	order by order_date) as previous_sales,
lag(order_id,1) over (partition by customer_id 
	order by order_date) as previous_order_id
from order_rollup_state;
-- practice
select OrderDate,
lag(OrderDate,1) over (order by OrderDate ASC)  as PreviousOrderDate,
lead(OrderDate,1) over (order by OrderDate ASC) as NextOrderDate
from Orders;

-- COALESCE
-- return the first non-ull value in a listof values

select *,
	coalesce(first_name, middle_ame, last_name as 
	name_corr from emp_name;
concat(first_name, middle_ame, last_name from emp_name;

-- practice
select FirstName,LastName,
	COALESCE(PhoneNumber, 'N/A') from Employees;

-- conversion functions
select sales, 'Total sales value for this order is ' ||
to_char(sales,'9999.99') as message from sales;

select order_date, 'the date is  ' ||  
	to_char(order_date,'Month DD YY') from sales;

select to_date('2045/01/01','YYYY/MM/DD')
select to_number('222222','66446545.4664')
-- practice
SELECT CustomerName, date(Birthdate) AS Birthdate
FROM Customers;
-- access control
create user starttech
with password 'academy';
grant select, update,insert,delete on product to starttech;
revoke delete on product from strttech;
alter user starttech rename to academy;

select usename from pg_user;
select * from pg_user;
-- talespace is just a location in your computer
-- create tablespace "" location ""

select distinct usename
	from pg_stat_activity;

drop user starttech;

create tablespace Newspace location E:\....
create table customer_test (i int) tablespace Newspace;
select * from pg_tablespace;
-- primary key, foregn key
-- ACID- an acronym for Atomicity, Consistancy, Isolation, and Durability
-- Truncate statement will delete all the parts of the table
truncate "table_name".
	cascade|restrict
explain select * from customer;
-- vaccum for soft deletion like update command to release the memory;
-- schemas is used to devide the data base into several sections

create schema test;
create table test.customer as select * from customer;
select * from test.customer;
-- now if I want to just test sth without damaging the original database i can do it tis way.