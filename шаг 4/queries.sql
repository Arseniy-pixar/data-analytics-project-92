запрос 2
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
