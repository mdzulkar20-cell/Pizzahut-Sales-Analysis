USE pizza_hut
SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT * FROM Orders;
SELECT * FROM order_details;

--Basic:
--1. Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_number_of_orders_placed FROM Orders;


--2. Calculate the total revenue generated from pizza sales.
SELECT CAST(SUM(order_details.quantity * pizzas.price) AS DECIMAL(10,2)) AS total_revenue FROM order_details JOIN pizzas ON order_details.pizza_id=pizzas.pizza_id;


--3. Identify the highest-priced pizza.
SELECT TOP 1 pizza_types.name, CAST(pizzas.price AS DECIMAL(10,2)) AS price FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id ORDER BY price DESC;


--4. Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(order_details.quantity) AS quantity FROM pizzas JOIN order_details ON pizzas.pizza_id=order_details.pizza_id GROUP BY size ORDER BY quantity DESC;


--5. List the top 5 most ordered pizza types along with their quantities.
SELECT TOP 5 pizza_types.name, SUM(order_details.quantity) AS quantity FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id JOIN order_details ON pizzas.pizza_id=order_details.pizza_id GROUP BY name ORDER BY quantity DESC;


--Intermediate:
--6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) AS quantity FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id JOIN order_details ON pizzas.pizza_id=order_details.pizza_id GROUP BY category ORDER BY quantity DESC;


--7. Determine the distribution of orders by hour of the day.
SELECT DATEPART(HOUR, time) AS Hours, COUNT(order_id) AS orders FROM orders GROUP BY DATEPART(HOUR, time) ORDER BY DATEPART(HOUR, time);


--8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT (name) AS name FROM pizza_types GROUP BY category ORDER BY name DESC;


--9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(Quantity) AS average_number_of_pizzas_ordered_per_day FROM (SELECT orders.date AS Date, SUM(order_details.quantity) AS quantity FROM orders JOIN order_details ON orders.order_id=order_details.order_id GROUP BY date) AS daily_order;


--10. Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP 3 pizza_types.name, CAST(SUM(pizzas.price*order_details.quantity) AS DECIMAL(10,2)) AS total_revenue FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id JOIN order_details ON pizzas.pizza_id=order_details.pizza_id GROUP BY name ORDER BY total_revenue DESC;


--Advanced:
--11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category, CAST(SUM(pizzas.price*order_details.quantity) AS DECIMAL(10,2)) AS total_revenue, CAST((CAST(SUM(pizzas.price*order_details.quantity) AS DECIMAL(10,2))*100)/(SELECT CAST(SUM(order_details.quantity * pizzas.price) AS DECIMAL(10,2)) AS total_revenue FROM order_details JOIN pizzas ON order_details.pizza_id=pizzas.pizza_id) AS DECIMAL(10,2)) AS pct_revenue FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id JOIN order_details ON pizzas.pizza_id=order_details.pizza_id GROUP BY category ORDER BY total_revenue DESC;


--12. Analyze the cumulative revenue generated over time.
WITH daily_revenue AS (SELECT Orders.date, CAST(SUM(order_details.quantity*pizzas.price) AS DECIMAL(10,2)) AS revenue FROM Orders JOIN order_details ON Orders.order_id=order_details.order_id JOIN pizzas ON order_details.pizza_id=pizzas.pizza_id GROUP BY date) SELECT date, SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue FROM daily_revenue ORDER BY date ASC;


--13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH revenue_by_type AS (SELECT pt.category, pt.name AS pizza_type, SUM(od.quantity * p.price) AS revenue FROM order_details AS od JOIN pizzas AS p ON od.pizza_id = p.pizza_id JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id GROUP BY pt.category, pt.name), ranked AS (SELECT category, pizza_type, revenue, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC, pizza_type ASC) AS rn FROM revenue_by_type) SELECT category, pizza_type, CAST(revenue AS DECIMAL(10,2)) AS revenue FROM ranked WHERE rn <= 3 ORDER BY category, revenue DESC;
