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
