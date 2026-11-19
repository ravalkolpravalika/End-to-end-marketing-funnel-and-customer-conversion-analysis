-- Business questions - Transactions Dataset
select * from transactions
limit 5;  
  
--1. What is the total gross revenue generated?
select sum(gross_revenue) as total_gross_revenue 
from transactions

--2. What is the average revenue per transaction?
select round(avg(gross_revenue),2) as avg_revenue_per_transaction
from transactions;

--3. What are the top 10 products by gross revenue?
select product_id, sum(gross_revenue) as gross
from transactions
where product_id is not null
group by product_id 
order by gross desc 
limit 10;


--4. Which products have the highest number of units sold?
select product_id, sum(quantity) as units_sold
from transactions
where product_id is not null
group by product_id
order by units_sold desc
limit 5;

--5. Which discount level generates the highest revenue?
select discount_applied, sum(gross_revenue) as highest_revenue
from transactions
group by discount_applied
order by highest_revenue desc;

--6. Which discount level generates the highest number of units sold?
select discount_applied, sum(quantity) as units_sold
from transactions
group by discount_applied
order by units_sold desc;

--7. What is the monthly and yearly gross revenue trend?
select  extract(year from timestamp) as year, extract(month from timestamp) as month, 
	sum(gross_revenue) as total_rev
from transactions
group by year, month
order by year, month;

--8. What is the gross revenue generated in the last 30 and 90 days?
select 'Last 30 Days' as period, sum(gross_revenue) as revenue
from transactions
where timestamp >= (select max(timestamp) from transactions) - interval ' 1 month'
union all 
select 'Last 90 Days' as period, sum(gross_revenue) as revenue
from transactions
where timestamp >= (select max(timestamp) from transactions) - interval '3 months'
 
--9. What is the overall refund rate?
select 
	round(sum(case when refund_flag=1 then 1 else 0 end)*100.0/ count(*),2)
	as refund_rate
from transactions

--10. What is the total refund value?
select sum(gross_revenue) as refund_val
from transactions
where refund_flag=1

--11. Which products have the highest number of refunds?
select product_id, sum(case when refund_flag=1 then 1 else 0 end) as refunds
from transactions
where product_id is not null
group by product_id
order by refunds desc
limit 5;

--12. Which campaigns have the highest number of refunded transactions?
select campaign_id, count(*) as refunds
from transactions
where refund_flag=1 and campaign_id <> 0 
group by campaign_id
order by refunds desc
limit 5;

--13. What is the average order quantity?
select round(avg(quantity),2) as avg_quan
from transactions

--14. How are transaction quantities distributed?
select quantity,
       count(*) as no_of_transactions
from transactions
group by quantity
order by quantity;

--15. Which transactions have the highest and lowest revenue?
select transaction_id, gross_revenue, 'Highest' as measure
from transactions
where gross_revenue = (select max(gross_revenue) from transactions)
union all
select transaction_id, gross_revenue,'Lowest' as measure
from transactions
where gross_revenue = (select min(gross_revenue) from transactions);