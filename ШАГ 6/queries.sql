ЗАПРОС 1

select
case when age >= 16 and age <= 25 then '16-25'
when age >= 26 and age <= 40 then '26-40'
when age > 40 then '40+'
end as age_category,
count(*) as age_count
from customers c
group by age_category 
order by age_category 

ЗАПРОС 2

select to_char(s.sale_date, 'YYYY-MM') as selling_month,
COUNT(DISTINCT c.customer_id) as total_customers,
sum(p.price * s.quantity) as income
from customers as c
inner join sales as s on c.customer_id = s.customer_id 
join products as p on s.product_id = p.product_id
group by 1
order by 1 
