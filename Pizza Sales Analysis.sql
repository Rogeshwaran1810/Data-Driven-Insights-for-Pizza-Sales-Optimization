Create database Pizzashop;
use Pizzashop;

Create Table pizzas (
pizza_id varchar(50),
pizza_type_id Varchar(50),
size varchar(10),
price Decimal(50)
);

Create Table pizza_types (
pizza_type_id Varchar(50),
name varchar(50),
category varchar(50),
ingredients Text(500)
);

CREATE TABLE orders (
    order_id INT(50),
    order_date DATE,
    order_time TIME
);

CREATE table Order_details (
order_details_id int(50),
 order_id INT(50),
 pizza_id varchar(50),
 Quantity Int(10)
 );

Select * from Pizzas;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizzas.csv'
INTO TABLE pizzas
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(pizza_id,
pizza_type_id,
size, price);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizza_types.csv'
INTO TABLE pizza_types
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(pizza_type_id,
name,
category,
ingredients);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Order_id, Order_date, order_time);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Order_details.csv'
INTO TABLE Order_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_details_id,
 order_id,
 pizza_id,
 Quantity);

ALter table Pizza_types modify ingredients varchar(50);
DESC orders;

# Task 1: Retrieve the total number of orders placed.
select count(*) as total_count_of_orders from orders; 

# Task 2: Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.Quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

# Task 3: Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price AS highest_priced_prizza
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY highest_priced_prizza DESC
LIMIT 1;
    
# Task 4: Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.pizza_id) AS most_common_size
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size 
order by most_common_size desc;
# limit 1; 

# Task 5: List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.Quantity) AS tatol_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY tatol_orders DESC
LIMIT 5;

# Task 6: Join the necessary tables to find the total quantity 
# of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.Quantity) AS tatol_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
    group by pizza_types.category;

# Intermediate Level
# Task 7: Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count 
from orders
group by hour; 

# Task 8: Join relevant tables to find the category-wise
# distribution of pizzas.
select pizza_types.category, count(pizza_type_id) from pizza_types
group by category

# Task 9:Group the orders by date and calculate 
# the average number of pizzas ordered per day.
SELECT 
    AVG(orders_per_day.quantity)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.Quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date
    ORDER BY order_date) AS orders_per_day;

# Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, SUM(order_details.Quantity * pizzas.price) as total_revenue
from pizzas join pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by total_revenue desc
limit 3;


# Task 10: Calculate the percentage contribution of
# each pizza type to total revenue.

SELECT 
    pizza_types.name,
    (SUM(order_details.Quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.Quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC;

# Task 11: Analyze the cumulative revenue generated over time.

SELECT order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from
(SELECT orders.order_date,
      sum(order_details.quantity * pizzas.price) as revenue
FROM order_details JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales;

# Determine the top 3 most ordered pizza types based on revenue
# for each pizza category. 
select name, revenue from 
(SELECT category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(SELECT pizza_types.category,pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
FROM order_details JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category,pizza_types.name) as a) as b
where rn <=3










