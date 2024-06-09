SELECT customer_id, 
       MIN(sales) AS "minimum sales", 
       MAX(sales) AS "maximum sales", 
       AVG(sales) AS "average of sales", 
       total_profit
FROM (
    SELECT customer_id, 
           sales, 
           quantity, 
           (sales * quantity) AS total_profit
    FROM sales
) AS subquery
GROUP BY customer_id, total_profit
ORDER BY total_profit DESC
LIMIT 200;
select MAX(customer_count) as max_customer_count,
	region
from (
	select region, 
			count(customer_id) as "customer_count"
	from customer
		group by region
) AS subquery
group by region 
order by max_customer_count DESC
	limit 1;
SELECT 
       MAX(customer_count) AS max_customer_count,
	region
FROM (
    SELECT region, 
           COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY region
) AS subquery
GROUP BY region
ORDER BY max_customer_count DESC
-- LIMIT 1;
select age,
	age_of_the_customers,
	region
from (
	select age, region,
	count(age) as age_of_the_customers
	from customer where region = 'East'
	group by age,region
	order by age DESC
	)
order by region ; 
select product_id,
	sum(quantity) as "product_quantity"
from sales
group by product_id
order by product_quantity DESC;

select region,
    count(customer_id) as customer_count
from customer
group by region
having count(customer_id)>200;

select *, case
        when age < 30 then 'young'
        when age > 60 then 'senior'
        else 'middleaged'
		end as "Age_category"
from customer;