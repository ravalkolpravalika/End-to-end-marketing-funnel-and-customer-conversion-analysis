-- Business questions - Products Dataset
select * from products
limit 5;
  
--1. Which product category has the highest average base price?
select category, round(avg(base_price),2) as avg_base_price
from products
group by category
order by avg_base_price desc
limit 1;

--2. Which category has the highest and lowest-priced products?
select category, base_price, 'highest' as measure
from products
where base_price = (select max(base_price) from products)
union all
select category, base_price , 'lowest' as measure
from products
where base_price = (select min(base_price) from products)

--3. Which are the top 10 most expensive products?
select * from products
order by base_price desc
limit 10;

--4. How many premium and non-premium products are available?
select is_premium, count(*) as total
from products
group by is_premium

--5. What is the average base price of premium versus non-premium products?
select is_premium, round(avg(base_price),2) as avg_price
from products
group by is_premium

--6. Which brands have the highest number of products?
select brand, count(product_id) as total_products
from products
group by brand
order by total_products desc
limit 5;

--7. Which brands have the highest average product price?
select brand, round(avg(base_price),2) as avg_price
from products
group by brand
order by avg_price desc
limit 5;

--8. How many products were launched each year?
select extract(year from launch_date) as year,
	count(product_id) as total_products
from products
group by year
order by year;

--9. Which product categories have the most newly launched products?
select category, count(*) as total
from products
where launch_date >= (select max(launch_date) from products) - interval '3 months'
group by category
order by total desc;

--10. new vs old product price comparison
with new as (
	select category, round(avg(base_price),2) as new_price
	from products
	where launch_date >= (select max(launch_date) from products) - interval '3 months'
	group by category
),
old as(
	select category, round(avg(base_price),2) as old_price
	from products
	where launch_date < (select max(launch_date) from products) - interval '3 months'
	group by category
)
select new.category,  new.new_price, old.old_price,
new.new_price - old.old_price as price_diff
from new 
join old
on new.category = old.category;

