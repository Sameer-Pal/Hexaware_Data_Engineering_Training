-- Database 
use BURGER_BASH;


CREATE TABLE customer_orders (
    order_id    INT NOT NULL,
    customer_id INT NOT NULL,
    burger_id   INT NOT NULL,
    exclusions  VARCHAR(4),
    extras      VARCHAR(4),
    order_time  DATETIME NOT NULL
);


INSERT INTO customer_orders (order_id, customer_id, burger_id, exclusions, extras, order_time) VALUES 
(1, 101, 1, NULL, NULL, '2021-01-01 18:05:02'),
(2, 101, 1, NULL, NULL, '2021-01-01 19:00:52'),
(3, 102, 1, NULL, NULL, '2021-01-02 23:51:23'),
(3, 102, 2, NULL, NULL, '2021-01-02 23:51:23'),
(4, 103, 1, '4', NULL, '2021-01-04 13:23:46'),
(4, 103, 1, '4', NULL, '2021-01-04 13:23:46'),
(4, 103, 2, '4', NULL, '2021-01-04 13:23:46'),
(5, 104, 1, NULL, '1', '2021-01-08 21:00:29'),
(6, 101, 2, NULL, NULL, '2021-01-08 21:03:13'),
(7, 105, 2, NULL, '1', '2021-01-08 21:20:29'),
(8, 102, 1, NULL, NULL, '2021-01-09 23:54:33'),
(9, 103, 1, '4', '1, 5', '2021-01-10 11:22:59'),
(10, 104, 1, NULL, NULL, '2021-01-11 18:34:49'),
(10, 104, 1, '2, 6', '1, 4', '2021-01-11 18:34:49');


customer_orders

CREATE TABLE burger_runner(
   runner_id   INTEGER  NOT NULL PRIMARY KEY 
  ,registration_date date NOT NULL
);
INSERT INTO burger_runner VALUES (1,'2021-01-01');
INSERT INTO burger_runner VALUES (2,'2021-01-03');
INSERT INTO burger_runner VALUES (3,'2021-01-08');
INSERT INTO burger_runner VALUES (4,'2021-01-15');


CREATE TABLE runner_orders (
   order_id      INTEGER NOT NULL PRIMARY KEY,
   runner_id     INTEGER NOT NULL,
   pickup_time   DATETIME,  -- Corrected data type
   distance      VARCHAR(7),
   duration      VARCHAR(10),
   cancellation  VARCHAR(23)
);


INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
(1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', NULL),
(2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', NULL),
(3, 1, '2021-01-03 00:12:37', '13.4km', '20 mins', NULL),
(4, 2, '2021-01-04 13:53:03', '23.4', '40', NULL),
(5, 3, '2021-01-08 21:10:57', '10', '15', NULL),
(6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
(7, 2, '2021-01-08 21:30:45', '25km', '25mins', NULL),
(8, 2, '2021-01-10 00:15:02', '23.4 km', '15 minute', NULL),
(9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
(10, 1, '2021-01-11 18:50:20', '10km', '10minutes', NULL);



CREATE TABLE burger_names(
   burger_id   INTEGER  NOT NULL PRIMARY KEY 
  ,burger_name VARCHAR(10) NOT NULL
);

INSERT INTO burger_names(burger_id,burger_name) VALUES (1,'Meatlovers');
INSERT INTO burger_names(burger_id,burger_name) VALUES (2,'Vegetarian');

select * from burger_names
select * from burger_runner
select * from runner_orders
select * from customer_orders

-- coding challenge Questions part -1 
-- 1.Querying Data by Using Joins and Subqueries & subtotal


--  INNER JOIN to combine runner_orders and burger_runner tables, and a subquery to find the runner with the maximum number of successful orders.

SELECT ro.runner_id, COUNT(*) AS successful_orders
FROM runner_orders ro
JOIN burger_runner br ON ro.runner_id = br.runner_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id
HAVING COUNT(*) = (
    SELECT MAX(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM runner_orders
        WHERE cancellation IS NULL
        GROUP BY runner_id
    ) AS subquery
);


---LEFT JOIN is used to combine customer_orders with burger_names, and aggregates burger orders for each customer

SELECT c.customer_id, b.burger_name, COUNT(*) AS burger_count
FROM customer_orders c
LEFT JOIN burger_names b ON c.burger_id = b.burger_id
GROUP BY c.customer_id, b.burger_name
ORDER BY c.customer_id;



--Uses a RIGHT JOIN between burger_names and customer_orders, and an INNER JOIN with runner_orders to combine burger and order data.

SELECT b.burger_name, ro.order_id, ro.runner_id, ro.pickup_time, ro.cancellation
FROM burger_names b
RIGHT JOIN customer_orders c ON b.burger_id = c.burger_id
JOIN runner_orders ro ON c.order_id = ro.order_id;


--A self-join on customer_orders is used to find customers who have ordered more than one distinct burger in a single order.

SELECT a.order_id, a.customer_id, COUNT(*) AS burger_count
FROM customer_orders a
JOIN customer_orders b ON a.order_id = b.order_id
WHERE a.customer_id = b.customer_id
GROUP BY a.order_id, a.customer_id
HAVING COUNT(DISTINCT a.burger_id) > 1;


--Uses a JOIN with a subquery that counts burgers per order, then finds the maximum burger count for each customer.

SELECT co.customer_id, MAX(order_counts.burger_count) AS max_burgers
FROM customer_orders co
JOIN (
    SELECT order_id, COUNT(*) AS burger_count
    FROM customer_orders
    GROUP BY order_id
) AS order_counts ON co.order_id = order_counts.order_id
GROUP BY co.customer_id;

-- subquery


--Uses a subquery inside the WHERE clause to filter customers with more than two orders using GROUP BY and HAVING


SELECT customer_id
FROM customer_orders
WHERE customer_id IN (
    SELECT customer_id
    FROM customer_orders
    GROUP BY customer_id
    HAVING COUNT(*) > 2
);


-- Uses GROUP BY and HAVING to filter customers who have modified their orders (with exclusions or extras) more than twice.

SELECT customer_id,
       COUNT(*) AS modified_orders
FROM customer_orders
WHERE exclusions IS NOT NULL OR extras IS NOT NULL
GROUP BY customer_id
HAVING COUNT(*) > 2;





--Uses GROUP BY to calculate the average delivery distance per customer, ordering by the highest value and returning the top (TOP-1)result.
SELECT TOP 1 co.customer_id,
             AVG(CAST(REPLACE(ro.distance, 'km', '') AS NUMERIC)) AS avg_distance
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id
ORDER BY avg_distance DESC;



--Uses GROUP BY to count the total number of orders for each customer.

SELECT customer_id, COUNT(*) AS total_orders
FROM customer_orders
GROUP BY customer_id

-- Uses GROUP BY and HAVING to find burger types ordered more than three times.

SELECT b.burger_name, COUNT(*) AS burger_orders
FROM customer_orders c
JOIN burger_names b ON c.burger_id = b.burger_id
GROUP BY b.burger_name
HAVING COUNT(*) > 3;

