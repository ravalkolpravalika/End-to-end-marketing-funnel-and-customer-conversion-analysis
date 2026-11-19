-- Business questions - Campaigns Dataset
select * from campaigns
limit 5;

--1. Which channels has the highest average expected uplift?
select channel, round(avg(expected_uplift),2) as avg_uplift
from campaigns
where campaign_id <> 0
group by channel
order by avg_uplift desc
limit 3;

--2. Which campaign ran the longest?
select *, (end_date - start_date) as duration
from campaigns
where end_date - start_date = (select max(end_date - start_date) from campaigns where campaign_id <> 0)
	and campaign_id <> 0 ;

--3. Which objective has the highest average uplift?
select objective, round(avg(expected_uplift),2) as avg_uplift
from campaigns
where campaign_id <> 0
group by objective
order by avg_uplift desc
limit 3;

--4. Which target segment has the highest uplift?
select target_segment, round(avg(expected_uplift),2) as avg_uplift
from campaigns
where campaign_id <> 0
group by target_segment
order by avg_uplift desc
limit 3;

--5. Average uplift by channel and objective together
select channel,objective, round(avg(expected_uplift),2) as avg_uplift
from campaigns
where campaign_id <> 0
group by channel,objective
order by avg_uplift desc
limit 3;

--6. How many campaigns were launched each year?
select extract(year from start_date) as start_year,count(campaign_id)
from campaigns
where campaign_id <> 0
group by extract(year from start_date);

--7. Which channel has the highest number of campaigns?
select channel,count(campaign_id) as total_campaigns
from campaigns
where campaign_id <> 0
group by channel
order by total_campaigns desc;

--8. Which campaigns have the highest and lowest expected uplift?
select *, 'maximum' as category
from campaigns
where campaign_id <> 0 and expected_uplift = (select max(expected_uplift) from campaigns where campaign_id <> 0)
union all 
select *, 'minimum' as category
from campaigns
where campaign_id <> 0 and expected_uplift = (select min(expected_uplift) from campaigns where campaign_id <> 0);

--9. Do longer-running campaigns have higher expected uplift?
select *, (end_date - start_date) as duration
from campaigns
where campaign_id <> 0
order by duration desc;

select round(corr(end_date - start_date, expected_uplift)::numeric, 3) as correlation
from campaigns
where campaign_id <> 0;

--10. What percentage of campaigns exceed the overall average uplift?
select 
    round(sum(case when expected_uplift > (select avg(expected_uplift) from campaigns where campaign_id <> 0) then 1
	else 0 end) * 100.0 /count(*),2) || '%'  as percentage
from campaigns
where campaign_id <> 0 ;

--11. Which target segments receive the greatest number of campaigns?
select target_segment, count(campaign_id) as total_campaigns
from campaigns
where campaign_id <> 0 
group by target_segment
order by total_campaigns desc;

--12. What is the average campaign duration by channel?
select channel, round(avg((end_date - start_date)),2) as avg_duration
from campaigns
where campaign_id <> 0 
group by channel;

--13. Rank campaigns within each channel by expected uplift.
select campaign_id,channel,objective,target_segment,expected_uplift,
row_number() over(partition by channel order by expected_uplift desc) as campaign_rank
from campaigns
where campaign_id <> 0 ;

--14. Identify the top 3 campaigns for each channel.
select campaign_id,channel, expected_uplift, campaign_rank from(
       select campaign_id,channel,expected_uplift,row_number() over(partition by channel order by expected_uplift desc) as campaign_rank
       from campaigns
) c
where campaign_rank <  4 and campaign_id <> 0 ;

--15. Find the best-performing target segment within each channel.
select channel, target_segment, avg_uplift
from(
       select channel, target_segment, avg_uplift,row_number() over(partition by channel order by avg_uplift desc) as campaign_rank 
       from (
             select channel, target_segment, round(avg(expected_uplift),2) as avg_uplift 
			 from campaigns
			 where campaign_id <> 0
			 group by channel,target_segment
	   )
) c
where campaign_rank =  1 ;

--16. Compare yearly trends in average expected uplift.
select extract(year from start_date) as year,round(avg(expected_uplift),2) as avg_uplift
from campaigns
where campaign_id <> 0
group by year
order by year;

--17. Identify channels whose average uplift is above the overall company average.
with avg_expected_uplift as(
     select channel, round(avg(expected_uplift),2) as avg_uplift
     from campaigns
	 where campaign_id <> 0
	 group by channel
)
select * from avg_expected_uplift
where avg_uplift > (select avg(expected_uplift) from campaigns where campaign_id <> 0);

--18. What share of total expected uplift comes from each channel?
with total_expected_uplift as(
	select channel, sum(expected_uplift) as channel_uplift 
	from campaigns
	where campaign_id <> 0
	group by channel
)
select channel, round(channel_uplift*100/(select sum(expected_uplift) from campaigns where campaign_id <> 0 ),2) as uplift_share_percent
from total_expected_uplift
order by uplift_share_percent;

--19. Which combination of channel, objective, and target segment generates the highest expected uplift?
select  channel, objective, target_segment, sum(expected_uplift) as total_uplift
from campaigns
where campaign_id <> 0
group by channel, objective, target_segment
order by total_uplift desc
limit 3;
