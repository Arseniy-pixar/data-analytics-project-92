select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct c.customer_id) as total_customers,
    floor(sum(p.price * s.quantity)) as income
from customers as c
inner join sales as s on c.customer_id = s.customer_id
inner join products as p on s.product_id = p.product_id
group by 1
order by 1;


select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(p.price * s.quantity) as operations,
    floor(sum(p.price * s.quantity)) as income
from customers as c
inner join sales as s on c.customer_id = s.customer_id
inner join products as p on s.product_id = p.product_id
inner join employees as e on s.sales_person_id = e.employee_id
group by e.first_name, e.last_name
order by income desc
limit 10;


with overall_average as (
    select avg(p.price * s.quantity) as avg_income
    from customers as c
    inner join sales as s on c.customer_id = s.customer_id
    inner join products as p on s.product_id = p.product_id
)

select
    concat(e.first_name, ' ', e.last_name) as seller,
    floor(avg(p.price * s.quantity)) as average_income
from customers as c
inner join sales as s on c.customer_id = s.customer_id
inner join products as p on s.product_id = p.product_id
inner join employees as e on s.sales_person_id = e.employee_id
cross join overall_average as o
group by e.first_name, e.last_name, o.avg_income
having avg(p.price * s.quantity) < o.avg_income
order by average_income asc;
 
select
    concat(e.first_name, ' ', e.last_name) as seller,
    trim(to_char(s.sale_date, 'day')) as day_of_week,
    floor(sum(p.price * s.quantity)) as income
from customers as c
inner join sales as s on c.customer_id = s.customer_id
inner join products as p on s.product_id = p.product_id
inner join employees as e on s.sales_person_id = e.employee_id
group by seller, day_of_week, extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;

select
    case
        when age >= 16 and age <= 25 then '16-25'
        when age >= 26 and age <= 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    count(*) as age_count
from customers
group by age_category
order by age_category;


WITH first_acquisition AS (
    SELECT
        c.customer_id,
        c.first_name AS customer_first_name,
        c.last_name AS customer_last_name,
        s.sale_date,
        e.first_name AS seller_first_name,
        e.last_name AS seller_last_name,
        ROW_NUMBER()
            OVER (PARTITION BY c.customer_id ORDER BY s.sale_date)
            AS rn
    FROM customers AS c
    INNER JOIN sales AS s ON c.customer_id = s.customer_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    WHERE p.price = 0
)

SELECT
    sale_date,
    CONCAT(customer_first_name, ' ', customer_last_name) AS customer,
    CONCAT(seller_first_name, ' ', seller_last_name) AS seller;
FROM first_acquisition
WHERE rn = 1
ORDER BY customer;

