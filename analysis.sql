-- create database
create database support_analysis;
use support_analysis;

CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(50),
    team VARCHAR(50)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    created_at VARCHAR(30),
    closed_at VARCHAR(30),
    priority VARCHAR(10),
    category VARCHAR(30)
);

CREATE TABLE ticket_assignments (
    ticket_id INT,
    agent_id INT,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

SELECT COUNT(*) FROM agents;
SELECT COUNT(*) FROM tickets;
SELECT COUNT(*) FROM ticket_assignments;

ALTER TABLE tickets
add column created_at_dt DATETIME,
add column closed_at_dt DATETIME;

UPDATE tickets
SET
  created_at_dt = STR_TO_DATE(created_at, '%d-%m-%Y %H:%i'),
  closed_at_dt  = STR_TO_DATE(closed_at,  '%d-%m-%Y %H:%i');

SELECT created_at, created_at_dt
FROM tickets
LIMIT 5;

ALTER TABLE tickets
DROP COLUMN created_at,
DROP COLUMN closed_at;

ALTER TABLE tickets
RENAME COLUMN created_at_dt TO created_at,
RENAME COLUMN closed_at_dt TO closed_at;

-- analysis
select * from tickets;
select * from agents;
select * from ticket_assignments;

-- Core Operational Metrics
-- ticket distribution by priority level
select priority, count(*) as total_tickets from tickets
group by priority;

-- average resolution time overall and by priority
select coalesce(priority,'Overall') as priority, round(avg(timestampdiff(minute, created_at, closed_at)/60.0),2)
as avg_resolution_hours
from tickets
group by priority with rollup;

-- monthly ticket volume trend
select date_format(created_at , '%Y-%m') as month,
count(*) as tickets_created from tickets
group by month
order by month;

-- SLA Compliance and Breach Analysis
-- sla breach identification
select ticket_id, priority,
case
	when priority='High' and timestampdiff(hour,created_at,closed_at) > 4 then 1
    when priority='Medium' and timestampdiff(hour,created_at,closed_at) > 12 then 1
    when priority='Low' and timestampdiff(hour,created_at,closed_at) > 24 then 1
    else 0 
end as sla_breach
from tickets;

-- sla breach rates by priority category  
select priority,
round(avg(
case
	when priority='High' and timestampdiff(hour,created_at,closed_at) > 4 then 1
    when priority='Medium' and timestampdiff(hour,created_at,closed_at) > 12 then 1
    when priority='Low' and timestampdiff(hour,created_at,closed_at) > 24 then 1
    else 0 
end )*100,2)
as sla_breach_pct
from tickets
group by priority;

-- sla breach trend over time
select
    date_format(created_at, '%Y-%m') as month,
    count(*) as total_tickets,
    sum(
        case
            when priority = 'High' 
                     and timestampdiff(hour, created_at, closed_at) > 4 then 1
            when priority = 'Medium' 
                     and timestampdiff(hour, created_at, closed_at) > 12 then 1
			when priority = 'Low' 
                     and timestampdiff(hour, created_at, closed_at) > 24 then 1
            else 0
        end
    ) as breached_tickets,
    round(
        sum(
             case
            when priority = 'High' 
                     and timestampdiff(hour, created_at, closed_at) > 4 then 1
            when priority = 'Medium' 
                     and timestampdiff(hour, created_at, closed_at) > 12 then 1
			when priority = 'Low' 
                     and timestampdiff(hour, created_at, closed_at) > 24 then 1
            else 0
        end
        ) * 100.0 / count(*),
        2
    ) as breach_percentage
from tickets
group by month
order by month;

-- Agent and Productivity Insights
-- tickets handled per agent
select a.agent_name, count(t.ticket_id) as tickets_handled
from agents a
join ticket_assignments ta on a.agent_id = ta.agent_id
join tickets t on ta.ticket_id = t.ticket_id
group by a.agent_name
order by tickets_handled desc;

-- average resolution time by agent
select a.agent_name, round(avg(timestampdiff(minute, t.created_at, t.closed_at)/60.0),2) as avg_resolution_hours
from agents a
join ticket_assignments ta on a.agent_id = ta.agent_id
join tickets t on ta.ticket_id = t.ticket_id
group by a.agent_name
order by avg_resolution_hours desc;

-- sla breach counts and rates
select a.agent_name,
round(
        avg(
             case
            when priority = 'High' 
                     and timestampdiff(hour, created_at, closed_at) > 4 then 1
            when priority = 'Medium' 
                     and timestampdiff(hour, created_at, closed_at) > 12 then 1
			when priority = 'Low' 
                     and timestampdiff(hour, created_at, closed_at) > 24 then 1
            else 0
        end
        ) * 100.0,2
    ) as sla_breach_pct
from agents a
join ticket_assignments ta on a.agent_id = ta.agent_id
join tickets t on ta.ticket_id = t.ticket_id
group by a.agent_name
order by sla_breach_pct desc;


-- Category & Issue Analysis
-- average resolution time by issue category
select category, round(avg(timestampdiff(minute, created_at, closed_at)/60.0),2)
as avg_resolution_hours
from tickets
group by category
order by avg_resolution_hours desc;

-- distribution of priorities within each category
select category,
round(sum(case when priority='High'then 1 else 0 end)*100.0/count(*),2) as pct_within_category
from tickets
group by category
order by pct_within_category desc;

-- Trend and Seasonality Patterns
-- hourly ticket arrival patterns
select hour(created_at) as hour_of_day,
count(*) as tickets_created from tickets
group by hour_of_day
order by hour_of_day;

-- weekends vs weekdays
SELECT
    day_type,
    SUM(daily_tickets) AS tickets_created,
    ROUND(AVG(daily_tickets), 2) AS avg_tickets_per_day
FROM (
    SELECT
        DATE(created_at) AS ticket_date,
        CASE
            WHEN DAYOFWEEK(created_at) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,
        COUNT(*) AS daily_tickets
    FROM tickets
    GROUP BY ticket_date, day_type
) t
GROUP BY day_type;

-- Advanced Query
-- longest average resolution time by agent/team + category
SELECT
    a.team,
    a.agent_name,
    t.category,
    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.closed_at) / 60.0),
        2
    ) AS avg_resolution_hours,
    COUNT(*) AS ticket_count
FROM tickets t
JOIN ticket_assignments ta ON t.ticket_id = ta.ticket_id
JOIN agents a ON ta.agent_id = a.agent_id
GROUP BY a.team, a.agent_name, t.category
HAVING ticket_count >= 20   
ORDER BY avg_resolution_hours DESC
LIMIT 10;

select count(*) as invalid_rows
from tickets 
where closed_at <= created_at;

select sum(created_at is null) as created_nulls, sum(closed_at is null) as closed_nulls, 
sum(priority is null) as priority_nulls, sum(category is null) as category_nulls
from tickets;

select count(*) as records
from ticket_assignments ta 
left join tickets t on ta.ticket_id = t.ticket_id
where t.ticket_id is null;

CREATE INDEX idx_tickets_created_at ON tickets(created_at);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_ticket_assignments_agent ON ticket_assignments(agent_id);
