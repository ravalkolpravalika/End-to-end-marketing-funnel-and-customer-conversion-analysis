--Combined - joins

--1. Loyalty tier vs average discount used and revenue
select c.loyalty_tier, 
		round(avg(t.discount_applied),3)  as avg_discount,
		sum(t.gross_revenue) as total_rev
from customers c
join transactions t
on c.customer_id = t.customer_id
group by c.loyalty_tier
order by total_rev desc;

--2. Country vs revenue, and country vs refund rate
select c.country, sum(t.gross_revenue) as total_rev,
	   round(sum(case when refund_flag = 1 then 1 else 0 end) *100.0 /
				count(*),2) as refund_rate
from customers c
join transactions t
on c.customer_id = t.customer_id
group by c.country;

--3. Category vs gross revenue and  Category vs refund rate
select p.category, sum(t.gross_revenue) as total_rev, 
	round(sum(case when refund_flag = 1 then 1 else 0 end) *100.0 /
				count(*),2) as refund_rate
from products p
join transactions t
on p.product_id = t.product_id
group by p.category
order by total_rev desc;

--4. Brand vs revenue, and top brands by units sold
select p.brand, sum(t.gross_revenue) as total_rev
from products p
join transactions t
on p.product_id = t.product_id
group by p.brand
order by total_rev desc 
limit 5;

select p.brand, sum(t.quantity) as units_sold
from products p
join transactions t
on p.product_id = t.product_id
group by p.brand
order by units_sold desc 
limit 5;

--5. Base price vs quantity and discount (do cheaper products sell more?)
select case when p.base_price < 50 then 'Low Price'  
            when p.base_price < 100 then 'Medium Price'
            else 'High Price'
       end as price_range, 
	   sum(t.quantity) as units_sold, round(avg(discount_applied),2) as avg_dis
from products p
join transactions t
on p.product_id = t.product_id
group by price_range
order by units_sold desc;

--6. Premium vs non-premium: revenue, discount and refund rate
select case when p.is_premium = 1 then 'Premium'
            else 'Non-premium' end as Flag,
		sum(t.gross_revenue) as revenue,
		round(avg(t.discount_applied),2) as discount,
		round((sum(case when t.refund_flag = 1 then 1 else 0 end)*100.0/count(*)),2) as refund_rate
from products p
join transactions t
on p.product_id = t.product_id
group by p.is_premium;
	
--7. Campaign channel vs revenue 
select case when c.campaign_id = 0 then 'No Campaign' else c.channel end as channel,
       sum(t.gross_revenue) as revenue
from campaigns c
join transactions t 
on c.campaign_id = t.campaign_id
group by 1;

--8. Expected uplift vs actual revenue (does high expected uplift deliver?)
select min(expected_uplift),
       max(expected_uplift)
from campaigns;

select case
        when c.expected_uplift < 0.05 then 'Low Uplift'
        when c.expected_uplift < 0.10 then 'Medium Uplift'
        else 'High Uplift'
    end as uplift_group, 
	sum(t.gross_revenue) as revenue
from campaigns c
join transactions t
on c.campaign_id = t.campaign_id
where c.campaign_id <> 0
group by uplift_group
order by revenue desc;

--9. Campaign objective vs conversion rate
select case when c.campaign_id = 0 then 'No Campaign' else c.objective end as objective,
       round(sum(case when e.event_type = 'purchase' then 1 else 0 end) * 100.0 /
             sum(case when e.event_type = 'view' then 1 else 0 end), 2) as conversion_rate
from campaigns c
join events e on c.campaign_id = e.campaign_id
group by 1
order by conversion_rate desc;

--10. Acquisition channel vs customer lifetime revenue
select c.acquisition_channel,
       count(*) as customers,
       round(avg(clr.lifetime_revenue),2) as avg_clv
from customers c
join (
    select customer_id, sum(gross_revenue) as lifetime_revenue
    from transactions
    group by customer_id
) clr
on c.customer_id = clr.customer_id
group by c.acquisition_channel
order by avg_clv desc;

--11. Customer segments: repeat buyers vs one-time buyers, top 10% customers by revenue
with buyers as (
	select customer_id,
		count(transaction_id) as orders
	from transactions
	group by customer_id
)
select case when orders = 1 then 'One-time Buyers'
            else 'Repeated Buyers' end as Segment,
			count(*) as customers
from buyers
group by Segment;


with cust_rev as (
    select customer_id, sum(gross_revenue) as revenue
    from transactions
    where gross_revenue is not null
    group by customer_id
), g as (
    select *, ntile(10) over(order by revenue desc) as grp from cust_rev
)
select round(sum(case when grp = 1 then revenue end) * 100.0 / sum(revenue), 2) as top10_revenue_share
from g;

--12. Traffic source vs revenue, and device vs revenue
select e.traffic_source, sum(t.gross_revenue) as revenue
from events e
join transactions t
  on e.customer_id = t.customer_id and e.timestamp = t.timestamp
where e.event_type = 'purchase'
group by e.traffic_source
order by revenue desc;

select e.device_type, sum(t.gross_revenue) as revenue
from events e
join transactions t
  on e.customer_id = t.customer_id and e.timestamp = t.timestamp
where e.event_type = 'purchase'
group by e.device_type
order by revenue desc;
