ЗАПРОС 1
select concat(c.first_name,' ', c.last_name) as seller,
count (p.price * s.quantity) as operation,
sum (p.price * s.quantity) as income
from customers as c 
inner join sales as s on c.customer_id = s.customer_id 
join products as p on s.product_id = p.product_id 
group by c.first_name, c.last_name
order by income desc
limit 10

  
ЗАПРОС 2
with overall_average as (
  select round(avg(p.price * s.quantity), 0) as avg_income
  from customers c
  join sales s on c.customer_id = s.customer_id
  join products p on s.product_id = p.product_id
)
select concat(c.first_name, ' ', c.last_name) as seller,
       round(avg(p.price * s.quantity), 0) as average_income
from customers c
join sales s on c.customer_id = s.customer_id
join products p on s.product_id = p.product_id
cross join overall_average o
group by c.first_name, c.last_name, o.avg_income 
having round(avg(p.price * s.quantity), 0) < o.avg_income
order by average_income asc

ЗАПРОС 3
