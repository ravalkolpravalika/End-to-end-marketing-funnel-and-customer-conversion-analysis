-- Business questions - Customers Dataset
select * from customers
limit 5; 

--1. Which country has the highest number of customers?
select country,count(customer_id) as number_of_customers
from customers
group by country
order by number_of_customers desc;

--2. Which country has the most customers in each loyalty tier?
with most_customers as(
	select loyalty_tier,country, count(customer_id) as number_of_customers
    from customers
	group by loyalty_tier,country
),
rank_country as(
	select *, rank() over(partition by loyalty_tier order by number_of_customers desc) as rank
	from most_customers
)
select * from rank_country
where rank = 1;

--3. Which acquisition channel brings the most Gold and Platinum customers?
with acq as(
	select acquisition_channel,loyalty_tier,count(*) as number_of_customers
	from customers
	where loyalty_tier = 'Gold' or loyalty_tier = 'Platinum'
	group by acquisition_channel,loyalty_tier
),
rnk as(
	select *, rank() over(partition by loyalty_tier order by  number_of_customers desc) as rank
	from acq
)
select * from rnk
where rank = 1;

--4. Which acquisition channel brings in the most customers?
select acquisition_channel,count(*) as number_of_customers
from customers
group by acquisition_channel
order by number_of_customers desc
limit 1;

--5. What is the distribution of customers across different loyalty tiers?
select loyalty_tier, concat(round(count(*) * 100.0 / (select count(*) from customers),2),'%') as percentage
from customers
group by loyalty_tier;

--6. How many customers signed up each month and year?
select extract(year from signup_date) as year,
	   extract(month from signup_date) as month,
	   count(*) as number_of_customers
from customers
group by year,month
order by year,month;

--7. Which months have the highest number of new signups?
select extract(month from signup_date) as month,
	   count(*) as number_of_customers
from customers
group by month
order by number_of_customers desc
limit 3;

--8. What is the loyalty tier distribution among customers who signed up in the last 6 or 12 months?
select loyalty_tier,
       count(*) AS customers,
       round(count(*) * 100.0 / sum(count(*)) over (), 2) as percent
from customers
where signup_date >= (select max(signup_date) from customers) - interval '12 months'
group by loyalty_tier
order by customers desc;

--9. Average age by loyalty tier, and customers by age group
select loyalty_tier,round(avg(age)) as avg_age
from customers
group by loyalty_tier;

select 
	case when age between 18 and 25 then 'Young'
	     when age between 26 and 40 then 'Adult'
		 when age between 41 and 55 then 'Middle Aged'
		 else 'Senior Citizen'
		 end as age_group,
	count(*) as no_of_customers
from customers
group by age_group
order by no_of_customers desc;

--10. What is the gender distribution across different countries and loyalty tiers?
select gender,country,loyalty_tier,
	   count(*) as no_of_customers,
	   round(count(*)*100/sum(count(*)) over(partition by country,loyalty_tier),2) as percent
from customers
group by gender,country,loyalty_tier
order by country,loyalty_tier;
	 
