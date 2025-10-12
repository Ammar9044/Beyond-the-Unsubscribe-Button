-- Calculated how many users unsubscribed at least once,
-- and what percentage of total sent emails that represents.

WITH unsubscribed_users AS (
    SELECT COUNT(DISTINCT user_id) AS total_unsubscribes
    FROM unsubscribes),
total_sent AS (
    SELECT SUM(total_sent) AS total_sent_emails
    FROM campaign_performance)
SELECT
    u.total_unsubscribes AS users_unsubscribed_once,
    t.total_sent_emails AS total_emails_sent,
    ROUND((u.total_unsubscribes * 1.0 / t.total_sent_emails) * 100, 2) AS unsubscribe_rate_percent
FROM unsubscribed_users u, total_sent t;

-- This query ranks email campaigns by their unsubscribe rates to identify which campaigns perform poorly.

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

-- Relationship between open rate, click rate, and unsubscribe rate
SELECT
    campaign_id,
    ROUND((total_opens * 100.0 / total_sent), 2) AS open_rate,
    ROUND((total_clicks * 100.0 / total_sent), 2) AS click_rate,
    ROUND((total_unsubscribes * 100.0 / total_sent), 2) AS unsubscribe_rate
FROM
    campaign_performance
ORDER BY
    unsubscribe_rate DESC;
    
-- Analyzing unsubscribe patterns by device type and region

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

 -- Calculating the average time to unsubscribe for users grouped by their signup month and year.
SELECT
    YEAR(u.signup_date) AS signup_year,
    MONTH(u.signup_date) AS signup_month,
    ABS(AVG(DATEDIFF(un.unsubscribe_date, u.signup_date))) AS avg_days_to_unsubscribe
FROM users u
INNER JOIN unsubscribes un ON u.user_id = un.user_id
GROUP BY signup_year, signup_month
ORDER BY signup_year, signup_month;

SELECT 
    c.send_hour,
    ROUND(AVG(cp.total_opens * 100.0 / cp.total_sent), 2) AS avg_open_rate,
    ROUND(AVG(cp.total_clicks * 100.0 / cp.total_sent), 2) AS avg_click_rate,
    ROUND(AVG(cp.total_unsubscribes * 100.0 / cp.total_sent), 2) AS avg_unsubscribe_rate
FROM campaigns AS c
JOIN campaign_performance AS cp 
    ON c.campaign_id = cp.campaign_id
GROUP BY c.send_hour
ORDER BY c.send_hour;






    





