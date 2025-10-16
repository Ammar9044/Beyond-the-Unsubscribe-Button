
-- This query calculates the total number of unsubscribes, total emails sent, 
-- and the overall unsubscribe rate (as a percentage) across all campaigns 
-- from the 'campaign_performance' table.

SELECT
    SUM(total_unsubscribes) AS total_unsubscribes,
    SUM(total_sent) AS total_emails_sent,
    ROUND((SUM(total_unsubscribes) * 1.0 / SUM(total_sent)) * 100, 2) AS unsubscribe_rate_percent
FROM
    campaign_performance;

-- This query analyzes email campaign performance to identify which campaigns 
-- have the highest unsubscribe rates. It first creates a temporary result (CTE) 
-- that combines campaign details with unsubscribe and send data, calculating 
-- total unsubscribes per campaign. Then, it computes the unsubscribe rate (%) 
-- for each campaign, ranks them in descending order by this rate, and shows 
-- key details like campaign name, category, send hour, and day of the week.

WITH campaign_unsubs AS (
    SELECT 
        c.campaign_id,
        c.campaign_name,
        c.category,
        c.send_hour,
        DAYOFWEEK(c.send_date) AS day_of_week,
        COUNT(DISTINCT u.user_id) AS total_unsubscribes,
        cp.total_sent
    FROM campaigns AS c
    LEFT JOIN unsubscribes AS u 
        ON c.campaign_id = u.campaign_id
    JOIN campaign_performance AS cp 
        ON c.campaign_id = cp.campaign_id
    GROUP BY 
        c.campaign_id, c.campaign_name, c.category, c.send_hour, DAYOFWEEK(c.send_date), cp.total_sent
)
SELECT 
    campaign_name,
    category,
    send_hour,
    day_of_week,
    total_unsubscribes,
    total_sent,
    ROUND((total_unsubscribes * 100.0 / total_sent), 2) AS unsubscribe_rate,
    RANK() OVER (ORDER BY (total_unsubscribes * 1.0 / total_sent) DESC) AS `rank`
FROM campaign_unsubs
ORDER BY unsubscribe_rate DESC;

-- This query calculates key email performance metrics for each campaign, 
-- including open rate, click rate, and unsubscribe rate (all as percentages). 
-- It helps identify which campaigns have the highest unsubscribe rates by 
-- ordering the results in descending order of unsubscribe rate.
SELECT
    campaign_id,
    ROUND((total_opens * 100.0 / total_sent), 2) AS open_rate,
    ROUND((total_clicks * 100.0 / total_sent), 2) AS click_rate,
    ROUND((total_unsubscribes * 100.0 / total_sent), 2) AS unsubscribe_rate
FROM
    campaign_performance
ORDER BY
    unsubscribe_rate DESC;
    
-- This query analyzes unsubscribe behavior by device type and region. 
-- It first summarizes how many users unsubscribed versus total users in each 
-- device–region combination, then calculates the unsubscribe rate (%) to identify 
-- which segments have the highest unsubscribe rates.

WITH unsubscribe_summary AS (
    SELECT 
        u.device_type, u.region,
        COUNT(DISTINCT unsub.user_id) AS unsubscribed_users,
        COUNT(DISTINCT u.user_id) AS total_users
    FROM users AS u
    LEFT JOIN unsubscribes AS unsub ON u.user_id = unsub.user_id
    GROUP BY u.device_type, u.region)
SELECT 
    device_type, region, unsubscribed_users, total_users,
    ROUND((unsubscribed_users * 100.0 / total_users), 2) AS unsubscribe_rate
FROM unsubscribe_summary
ORDER BY unsubscribe_rate DESC;

-- This query measures how long, on average, users take to unsubscribe after signing up, 
-- grouped by their signup year and month. It calculates the average number of days 
-- between signup and unsubscribe dates, helping identify trends in user retention 
-- over different signup periods.

SELECT
    YEAR(u.signup_date) AS signup_year,
    MONTH(u.signup_date) AS signup_month,
    ABS(AVG(DATEDIFF(un.unsubscribe_date, u.signup_date))) AS avg_days_to_unsubscribe
FROM users u
INNER JOIN unsubscribes un ON u.user_id = un.user_id
GROUP BY signup_year, signup_month
ORDER BY signup_year, signup_month;

-- This query analyzes how the time of day (send hour) affects email campaign performance.  
-- It calculates the average open rate, click rate, and unsubscribe rate (%) for campaigns  
-- sent at each hour, helping identify which send times perform better or lead to more unsubscribes.

SELECT 
    c.send_hour,
    ROUND(AVG(cp.total_opens * 100.0 / cp.total_sent), 2) AS avg_open_rate,
    ROUND(AVG(cp.total_clicks * 100.0 / cp.total_sent), 2) AS avg_click_rate,
    ROUND(AVG(cp.total_unsubscribes * 100.0 / cp.total_sent), 2) AS avg_unsubscribe_rate
FROM campaigns AS c
JOIN campaign_performance AS cp 
    ON c.campaign_id = cp.campaign_id
GROUP BY c.send_hour
ORDER BY avg_unsubscribe_rate desc;






