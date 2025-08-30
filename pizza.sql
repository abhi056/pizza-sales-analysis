
create table orders (
order_id int not null,
order_date date not null,	
order_time time not null ,
primary key (order_id) );

create table order_details (
order_details_id int not null,
order_id int not null,	
pizza_id text not null ,
quantity int not null,
primary key (order_details_id) );

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details.order_id)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size;




-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.name
order by quantity desc
limit 5;







-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;




-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);




-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_pizzas_sold
FROM order_details
JOIN pizzas 
    ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types 
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY total_pizzas_sold DESC;



-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS average_no_pizzas
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select  pizza_types.category, 
round(sum(order_details.quantity*pizzas.price)/ (select ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN 
    pizzas ON pizzas.pizza_id = order_details.pizza_id)*100,1) as revenue
from pizza_types  join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc ;


-- Analyze the cumulative revenue generated over time.
SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS daily_revenue,
    SUM(SUM(order_details.quantity * pizzas.price)) 
        OVER (ORDER BY orders.order_date) AS cumulative_revenue
FROM order_details
JOIN pizzas  
    ON order_details.pizza_id = pizzas.pizza_id
JOIN orders  
    ON order_details.order_id = orders.order_id   
GROUP BY orders.order_date
ORDER BY orders.order_date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

 SELECT 
    category,
    name AS pizza_type,
    revenue
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY pizza_types.category
            ORDER BY SUM(order_details.quantity * pizzas.price) DESC
        ) AS rn
    FROM order_details 
    JOIN pizzas  
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types  
        ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    GROUP BY pizza_types.category, pizza_types.name
) ranked
WHERE rn <= 3
ORDER BY category, revenue DESC;



