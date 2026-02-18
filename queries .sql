ЗАПРОС 4
select concat(c.first_name,' ', c.last_name) as seller, -- создаёт столбец 'seller' с именем и фамилией продавца, объединёнными через пробел
count(p.price * s.quantity) as operation, -- считает количество операций (продаж), в данном случае — количество строк, умноженных на цену, что некорректно — лучше считать строки или сумму продаж
sum(p.price * s.quantity) as income -- сумму выручки продавца
from customers as c -- таблица клиентов с алиасом c
inner join sales as s on c.customer_id = s.customer_id -- соединяет таблицы клиентов и продаж по идентификатору клиента
join products as p on s.product_id = p.product_id -- соединяет таблицы продаж и продуктов по идентификатору товара
join employees as e on e.employee_id = s.sales_person_id
group by c.first_name, c.last_name -- группирует по имени и фамилии продавца
order by income desc -- сортирует по выручке в порядке убывания
limit 10 -- выводит только первые 10 записей
  
ЗАПРОС 5
with overall_average as ( -- объявляем временную таблицу (CTE) с именем overall_average
select round(avg(p.price * s.quantity), 0) as avg_income -- считаем среднюю выручку по всем продажам, округляем до целого, присваиваем alias avg_income
from customers c -- из таблицы клиентов
join sales s on c.customer_id = s.customer_id -- присоединяем продажи по идентификатору клиента
join products p on s.product_id = p.product_id -- присоединяем товары по идентификатору товара
)
select concat(e.first_name, ' ', e.last_name) as seller, -- формируем название продавца (имя + фамилия)
       round(avg(p.price * s.quantity), 0) as average_income -- считаем среднюю выручку продавца за сделки, округляем
from customers c -- таблица клиентов
join sales s on c.customer_id = s.customer_id -- присоединение продаж
join products p on s.product_id = p.product_id -- присоединение товаров
join employees as e on e.employee_id = s.sales_person_id
cross join overall_average o -- кросс-присоединение с общей средней, чтобы получить это значение в каждой строке
group by e.first_name, e.last_name, o.avg_income -- группируем по продавцам и по общей средней выручке
having round(avg(p.price * s.quantity), 0) < o.avg_income -- фильтрация: выбираем только тех продавцов, у которых средняя выручка за сделку меньше общей
order by average_income asc -- сортируем по средней выручке по возрастанию
  
ЗАПРОС 6
select concat(e.first_name,' ', e.last_name) as seller, -- формирует столбец 'seller' с именем и фамилией продавца
trim(to_char(s.sale_date, 'Day')) as day_of_week, -- название дня недели (на английском), с удалением лишних пробелов
sum(p.price * s.quantity) as income -- вычисляет общую сумму выручки за все сделки продавца за выбранный день
from customers as c -- таблица клиентов с псевдонимом c
inner join sales as s on c.customer_id = s.customer_id -- соединение клиентов с продажами по id клиента
join products as p on s.product_id = p.product_id -- соединение продаж с товарами по id товара
join employees as e on e.employee_id = s.sales_person_id
group by 1, 2, extract(isodow from s.sale_date) -- группировка по именю, названию дня и числовому дню недели
order by seller, extract(isodow from s.sale_date); -- сортировка сначала по продавцу, затем по порядковому номеру дня недели
