-- Business questions - Events Dataset
select * from events
limit 5;
  
--1. What is the total number of events for each event type?
select event_type, count(*) as total_events
from events
group by event_type;

--2. Which event type has the highest average session duration?
select event_type, round(avg(session_duration_sec),2) as avg_duration
from events
group by event_type
order by avg_duration desc;

--3. Which page category receives the highest number of views?
select page_category, count(*) as no_of_views 
from events
where event_type = 'view'
group by page_category
order by no_of_views desc;

--4. How are different event types distributed across page categories?
select event_type,page_category, 
round(count(*) * 100/sum(count(*)) over(partition by event_type),2) as percent
from events
group by event_type, page_category;

--5. Which traffic source generates the highest number of events?
select traffic_source, count(*) as total_events
from events
group by traffic_source
order by total_events desc;

--6. Which device type generates the most customer activity?
select device_type, count(*) as total_events
from events
group by device_type
order by total_events desc
limit 1;

--7. What is the conversion rate for each experiment group (Control, Variant_A, Variant_B)?
select experiment_group,
       round(sum(
	    		case when event_type = 'purchase' then 1 else 0 end)* 100.0 / count(*),2)
				as conversion_rate
from events
group by experiment_group;

--8. Which experiment group has the lowest bounce rate?
select experiment_group, 
	round(
		sum(
			case when event_type = 'bounce' then 1 else 0 end 
		)*100.0 / count(*)
	,2 )as bounce_rate
from events
group by experiment_group
order by bounce_rate asc;

--9. How does website activity change month by month?
with e as(
	select date_trunc('month', timestamp) as month, count(*) as total_events 
	from events
	group by month
), change as(
	select *, lag(total_events) over(order by month) as previous_month_events,
	total_events - lag(total_events) over(order by month) as event_change,
	 round( (total_events - lag(total_events) over(order by month))* 100.0 / lag(total_events) over(order by month),2
       ) as growth_percent
	from e
)
select * from change

--10. What is the average number of sessions per customer?
with ss as (
    select customer_id, count(*) as sessions
    from events
    group by customer_id
)
select round(avg(sessions),2) as avg_sessions
from ss;

--11. Which customers have the highest number of sessions?
with ss as(
	select customer_id, count(*) as sessions
	from events
	group by customer_id

),
rnk as (
	select *, rank() over(order by sessions desc ) as rank
	from ss
)
select * from rnk
where rank < 3

--12. What is the average session duration by device type?
select device_type, round(avg(session_duration_sec),2) as avg_duration
from events
group by device_type

--13. At what hour of the day and on which day of the week is website activity highest?
select extract(hour from timestamp) as hour,
	   count(*) as total_events
from events
group by hour
order by total_events desc
limit 1;

select extract(dow from timestamp) as day_of_week,
	   count(*) as total_events
from events
group by day_of_week
order by total_events desc
limit 1;

--14. Which traffic source generates the most purchase events?
select traffic_source, 
	   sum(case when event_type = 'purchase' then 1 else 0 end ) as purchase_events
from events
group by traffic_source	
order by purchase_events desc;

