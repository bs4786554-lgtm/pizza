create database pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );


/*
*****************************************
*----------------Basic:-----------------*
*****************************************
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.0
*/
#1.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

#2.
SELECT 
    ROUND(SUM(pz.price * od.quantity), 2) AS total_revenue
FROM
    pizzas AS pz
        JOIN
    order_details AS od ON pz.pizza_id = od.pizza_id;
    
#3.
SELECT pzt.name,
    pz.price
FROM
    pizzas as pz join pizza_types as pzt using(pizza_type_id)
Group BY pzt.name, pz.price
ORDER BY pz.price DESC
LIMIT 1;

#4.
SELECT 
    pz.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS pz
        JOIN
    order_details AS od USING (pizza_id)
GROUP BY pz.size
ORDER BY order_count DESC
LIMIT 1;

#5.
SELECT 
    pzt.name, sum(od.quantity) AS most_order_qty
FROM
    pizzas AS pz
        JOIN
    order_details AS od USING (pizza_id) join pizza_types as pzt using(pizza_type_id)
GROUP BY pzt.name
ORDER BY most_order_qty DESC
limit 5;

/*
*****************************************
*------------Intermediate:--------------*
*****************************************
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.
*/

#1.
SELECT 
     pzt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pzt
        JOIN
    pizzas AS pz USING (pizza_type_id)
        JOIN
    order_details AS od USING (pizza_id)
GROUP BY pzt.category
ORDER BY total_quantity DESC;

#2.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS ord_count
FROM
    orders
GROUP BY HOUR(order_time);

#3.
SELECT 
    category, COUNT(name) AS pizza_type
FROM
    pizza_types
GROUP BY category;

#4.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od USING (order_id)
    GROUP BY order_date) AS order_quantity;
    
#5.
SELECT 
    pzt.name, SUM(od.quantity * pz.price) AS revenue
FROM
    order_details AS od
        JOIN
    pizzas AS pz USING (pizza_id)
        JOIN
    pizza_types AS pzt USING (pizza_type_id)
GROUP BY pzt.name
ORDER BY revenue DESC
LIMIT 3;

/*
*****************************************
*--------------Advance:-----------------*
*****************************************
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.
*/

#1.
SELECT 
    pzt.category,
    ROUND(SUM(od.quantity * pz.price) / (SELECT 
                    ROUND(SUM(od.quantity * pz.price), 2) AS total_sales
                FROM
                    order_details AS od
                        JOIN
                    pizzas AS pz USING (pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types AS pzt
        JOIN
    pizzas AS pz USING (pizza_type_id)
        JOIN
    order_details AS od USING (pizza_id)
GROUP BY pzt.category
ORDER BY revenue DESC;

#2.
select 
  order_date, 
  sum(revenue) over(
    order by 
      order_date
  ) as cum_revenue 
from 
  (
    select 
      o.order_date, 
      sum(od.quantity * pz.price) as revenue 
    from 
      order_details as od 
      join pizzas as pz using(pizza_id) 
      join orders as o using(order_id) 
    group by 
      o.order_date
  ) as sales;

#3.
select 
  name, 
  revenue 
from 
  (
    select 
      category, 
      name, 
      revenue, 
      rank() over(
        partition by category 
        order by 
          revenue desc
      ) as rn 
    from 
      (
        select 
          pzt.category, 
          pzt.name, 
          sum(
            (od.quantity) * pz.price
          ) as revenue 
        from 
          pizza_types as pzt 
          join pizzas as pz using(pizza_type_id) 
          join order_details as od using(pizza_id) 
        group by 
          pzt.category, 
          pzt.name
      ) as a
  ) as b 
where 
  rn <= 3;












