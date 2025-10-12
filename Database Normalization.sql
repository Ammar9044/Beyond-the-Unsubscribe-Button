
Create database email_marketing;
Use email_marketing;

CREATE TABLE campaign_performance (
    campaign_id INT PRIMARY KEY,
    total_sent INT,
    total_opens INT,
    total_clicks INT,
    total_unsubscribes INT
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_date DATETIME NOT NULL,
    device_type VARCHAR(50),
    region VARCHAR(100),
    is_active BOOLEAN 
);



CREATE TABLE email_engagement (
    engagement_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    campaign_id INT NOT NULL,
    opened BOOLEAN,
    clicked BOOLEAN,
    unsubscribe BOOLEAN,
    open_time Text,
    FOREIGN KEY (campaign_id) REFERENCES campaign_performance(campaign_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(50),
    send_date DATE,
    email_subject VARCHAR(100),
    send_hour INT,
    category VARCHAR(50)
);

CREATE TABLE unsubscribes (
    unsubscribe_id INT PRIMARY KEY,
    user_id INT,
    campaign_id INT,
    unsubscribe_date DATE,
    reason VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);


ALTER TABLE unsubscribes
ADD CONSTRAINT fk_campaign_performance
FOREIGN KEY (campaign_id) REFERENCES campaign_performance(campaign_id);

ALTER TABLE email_engagement
ADD CONSTRAINT fk_users
FOREIGN KEY (user_id) REFERENCES users(user_id);


UPDATE email_engagement
SET open_time = NULL
WHERE open_time = '' OR open_time IS NULL;

UPDATE email_engagement
SET open_time = STR_TO_DATE(open_time, '%Y-%m-%d %H:%i:%s');

ALTER TABLE email_engagement
MODIFY COLUMN open_time DATETIME;








