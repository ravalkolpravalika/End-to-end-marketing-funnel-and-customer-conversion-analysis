--Funnel Analysis
select * from events
limit 5;

--1. How many events are recorded? (ie. views, add-to-cart events, and purchase etc)
select event_type, count(*) as no_of_events
from events
group by event_type;

--2. What is the conversion rate from view to add-to-cart?
select round(sum(case when event_type='add_to_cart' then 1 else 0 end)*100.0 / 
	sum(case when event_type='view' then 1 else 0 end),2) as conversion_rate
from events;

--3. What is the conversion rate from add-to-cart to purchase?
select round(sum(case when event_type='purchase' then 1 else 0 end)*100.0 / 
	sum(case when event_type='add_to_cart' then 1 else 0 end),2) as conversion_rate
from events;

--4. What is the overall conversion rate from view to purchase?
select round(sum(case when event_type='purchase' then 1 else 0 end)*100.0 / 
	sum(case when event_type='view' then 1 else 0 end),2) as conversion_rate
from events;

--5. What is the bounce rate
select round(
    sum(case when event_type = 'bounce' then 1 else 0 end)* 100.0 /
    sum(case when event_type = 'view' then 1 else 0 end), 2) as bounce_rate
from events;

--6. At which funnel stage do most customers drop off?
with funnel as(
select
	sum(case when event_type = 'view' then 1 else 0 end) as views,
	sum(case when event_type = 'click' then 1 else 0 end) as clicks,
	sum(case when event_type = 'add_to_cart' then 1 else 0 end) as add_to_carts,
	sum(case when event_type = 'purchase' then 1 else 0 end) as purchases
from events
),
dropoffs as (
	select 'views to clicks' as stage,
	round((views - clicks)*100.0/views,2) as dropoff_percent
	from funnel
union all
	select 'clicks to add_to_cart' as stage,
	round((clicks - add_to_carts)*100.0/clicks,2) as dropoff_percent
	from funnel
union all 
	select 'add_to_cart to purchase' as stage,
	round((add_to_carts - purchases)*100.0/add_to_carts,2) as dropoff_percent
	from funnel
)
select * from dropoffs
order by dropoff_percent desc;
--limit 1;

--7. Which device type has the highest conversion rate?
select device_type,
       round(sum(case when event_type = 'purchase' then 1 else 0 end) * 100.0 /
           sum(case when event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from events
group by device_type
order by conversion_rate desc
limit 1;

--8. Which traffic source has the highest conversion rate?
select traffic_source,
       round(sum(case when event_type = 'purchase' then 1 else 0 end) * 100.0 /
           sum(case when event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from events
group by traffic_source
order by conversion_rate desc
limit 1;

--9. Which page category has the highest conversion rate?
select page_category,
       round(sum(case when event_type = 'purchase' then 1 else 0 end) * 100.0 /
           sum(case when event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from events
group by page_category
order by conversion_rate desc
limit 1;

--10. Which page category has the highest bounce rate?
select page_category,
       round(sum(case when event_type = 'bounce' then 1 else 0 end) * 100.0 /
           sum(case when event_type = 'view' then 1 else 0 end),2 ) as bounce_rate 
from events
group by page_category
order by bounce_rate  desc
limit 1;

--11. Which device type has the highest cart abandonment rate?
select device_type,
       round(
           (sum(case when event_type = 'add_to_cart' then 1 else 0 end) -
            sum(case when event_type = 'purchase' then 1 else 0 end)
           ) * 100.0
           /
           sum(case when event_type = 'add_to_cart' then 1 else 0 end),2
       ) as abandonment_rate
from events
group by device_type
order by abandonment_rate desc
limit 1;

--12. Which countries has the highest conversion rate?
select c.country,
       round(sum(case when e.event_type = 'purchase' then 1 else 0 end) * 100.0 /
           sum(case when e.event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from customers c
join events e
on c.customer_id = e.customer_id
group by country
order by conversion_rate desc;

--13. Which loyalty tiers has the highest conversion rate?
select c.loyalty_tier,
       round(sum(case when e.event_type = 'purchase' then 1 else 0 end) * 100.0 /
           sum(case when e.event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from customers c
join events e
on c.customer_id = e.customer_id
group by loyalty_tier
order by conversion_rate desc;

--14. Which experiment groups has the highest conversion rate?
select experiment_group,
       round(sum(case when event_type = 'purchase' then 1 else 0 end) * 100.0 /
           sum(case when event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from events 
group by experiment_group
order by conversion_rate desc;

--15. What is the cart abandonment rate?
select round(
           (sum(case when event_type = 'add_to_cart' then 1 else 0 end) -
            sum(case when event_type = 'purchase' then 1 else 0 end)
           ) * 100.0
           /
           sum(case when event_type = 'add_to_cart' then 1 else 0 end),2
       ) as abandonment_rate
from events;

--16. How much time does it take customers to move from their first product view to purchase?
with cust_journey as(
	select customer_id,
	       min(case when event_type = 'view' then timestamp end) as first_view,
		   min(case when event_type = 'purchase' then timestamp end) as first_purchase
	from events
	group  by customer_id
)
select avg(first_purchase - first_view) as avg_time_to_purchase
from cust_journey
where first_view is not null and first_purchase is not null;

--17. Do customers associated with marketing campaigns convert better than customers without campaign attribution?
select
    case when campaign_id <> 0 then 'Campaign' else 'No Campaign' end as campaign_status,
    round(
        sum(case when event_type = 'purchase' then 1 else 0 end)* 100.0 /
        sum(case when event_type = 'view' then 1 else 0 end),2 ) as conversion_rate
from events
group by campaign_status;

--18. session-level funnel
select
  count(distinct case when event_type = 'view' then session_id end) as view_sessions,
  count(distinct case when event_type = 'add_to_cart' then session_id end) as cart_sessions,
  count(distinct case when event_type = 'purchase' then session_id end) as purchase_sessions
from events;

--19. Funnel by product category
select p.category,
  round(sum(case when e.event_type = 'purchase' then 1 else 0 end) * 100.0 /
        sum(case when e.event_type = 'view' then 1 else 0 end), 2) as conversion_rate
from events e
join products p on e.product_id = p.product_id
group by p.category
order by conversion_rate desc;

--20. funnel
with s as (
  select
    count(distinct case when event_type = 'view' then session_id end) as view_sessions,
    count(distinct case when event_type = 'add_to_cart' then session_id end) as cart_sessions,
    count(distinct case when event_type = 'purchase' then session_id end) as purchase_sessions
  from events
)
select *,
  round(cart_sessions * 100.0 / view_sessions, 2) as view_to_cart_pct,
  round(purchase_sessions * 100.0 / cart_sessions, 2) as cart_to_purchase_pct
from s;