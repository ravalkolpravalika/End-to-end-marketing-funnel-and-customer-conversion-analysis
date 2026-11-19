CREATE TABLE campaigns (
  campaign_id INT PRIMARY KEY, channel VARCHAR(30), objective VARCHAR(30),
  start_date DATE, end_date DATE, target_segment VARCHAR(30), expected_uplift NUMERIC(5,3));

CREATE TABLE customers (
  customer_id INT PRIMARY KEY, signup_date DATE, country VARCHAR(5), age INT,
  gender VARCHAR(10), loyalty_tier VARCHAR(15), acquisition_channel VARCHAR(30));

CREATE TABLE products (
  product_id INT PRIMARY KEY, category VARCHAR(30), brand VARCHAR(30),
  base_price NUMERIC(10,2), launch_date DATE, is_premium SMALLINT);

CREATE TABLE events (
  event_id INT PRIMARY KEY, timestamp TIMESTAMP, customer_id INT, session_id INT,
  event_type VARCHAR(20), product_id INT, device_type VARCHAR(15),
  traffic_source VARCHAR(30), campaign_id INT, page_category VARCHAR(20),
  session_duration_sec NUMERIC(8,1), experiment_group VARCHAR(20));

CREATE TABLE transactions (
  transaction_id INT PRIMARY KEY, timestamp TIMESTAMP, customer_id INT, product_id INT,
  quantity INT, discount_applied NUMERIC(4,2), gross_revenue NUMERIC(10,2),
  campaign_id INT, refund_flag SMALLINT, is_missing_product VARCHAR(5));


SELECT COUNT(*) FROM campaigns;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM transactions;

select * from campaigns
limit 5;

select * from customers
limit 5;

select * from events
limit 5;

select * from products
limit 5;

select * from transactions
limit 5;
  