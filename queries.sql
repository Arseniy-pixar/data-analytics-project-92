 -- customers_by_month

select to_char(s.sale_date, 'YYYY-MM') as selling_month, -- преобразует дату продажи в формат 'ГОД-МЕСЯЦ' и задает алиас 'selling_month'
COUNT(DISTINCT c.customer_id) as total_customers, -- подсчитывает уникальных покупателей за месяц
floor(sum(p.price * s.quantity)) as income -- суммирует выручку за месяц (цена товара умноженная на количество) и округляет в меньшую сторону
from customers as c -- таблица клиентов с псевдонимом c
inner join sales as s on c.customer_id = s.customer_id -- соединяет клиентов с продажами по ID клиента
join products as p on s.product_id = p.product_id -- соединяет продажи с товарами по ID товара
group by 1 -- группирует данные по первому выбранному полю (сюда входит 'YYYY-MM')
order by 1 -- сортирует результат по тому же полю, по месяцу

 -- top_10_total_income

select concat(c.first_name,' ', c.last_name) as seller, -- создаёт столбец 'seller' с именем и фамилией продавца, объединёнными через пробел
count(p.price * s.quantity) as operation, -- считает количество операций (продаж), в данном случае — количество строк, умноженных на цену, что некорректно — лучше считать строки или сумму продаж
floor(sum(p.price * s.quantity)) as income -- сумма выручки продавца, округлённая в меньшую сторону
from customers as c -- таблица клиентов с алиасом c
inner join sales as s on c.customer_id = s.customer_id -- соединяет таблицы клиентов и продаж по идентификатору клиента
join products as p on s.product_id = p.product_id -- соединяет таблицы продаж и продуктов по идентификатору товара
join employees as e on e.employee_id = s.sales_person_id
group by c.first_name, c.last_name -- группирует по имени и фамилии продавца
order by income desc -- сортирует по выручке в порядке убывания
limit 10 -- выводит только первые 10 записей

 -- lowest_average_income

with overall_average as ( -- объявляем временную таблицу (CTE) с именем overall_average
select avg(p.price * s.quantity) as avg_income -- считаем среднюю выручку по всем продажам, округляем до целого, присваиваем alias avg_income
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
having avg(p.price * s.quantity) < o.avg_income -- фильтрация: выбираем только тех продавцов, у которых средняя выручка за сделку меньше общей
order by average_income asc -- сортируем по средней выручке по возрастанию

 -- day_of_the_income
  
select
  concat(e.first_name,' ', e.last_name) as seller, -- формирует столбец 'seller' с именем и фамилией продавца
  trim(to_char(s.sale_date, 'Day')) as day_of_week, -- название дня недели (на английском), с удалением лишних пробелов
  round(sum(p.price * s.quantity), 0) as income -- вычисляет общую сумму выручки за все сделки продавца за выбранный день
from customers as c -- таблица клиентов с псевдонимом c
inner join sales as s on c.customer_id = s.customer_id -- соединение клиентов с продажами по id клиента
join products as p on s.product_id = p.product_id -- соединение продаж с товарами по id товара
join employees as e on e.employee_id = s.sales_person_id
group by 1, 2, extract(isodow from s.sale_date) -- группировка по именю, названию дня и числовому дню недели
order by extract(isodow from s.sale_date), seller; -- сортировка сначала по продавцу, затем по порядковому номеру дня недели

 -- top_10_profitable_products

select 
  p.product_id as ProductID,
  floor(sum(p.price * s.quantity)) as Amount -- правильно округляем сумму в меньшую сторону
from products p
inner join sales s on p.product_id = s.product_id -- соединяем товары и продажи
group by p.product_id -- группируем по ID товара
order by Amount desc -- сортируем по сумме, чтобы самые большие были в начале
limit 10;

 -- top_10_popular_products

SELECT 
  p.product_id AS ProductID,
  SUM(s.quantity) AS TotalQuantity
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id
ORDER BY TotalQuantity DESC
LIMIT 10;

 -- age_category

select
  case when age >= 16 and age <= 25 then '16-25' -- определяет категорию '16-25' для возрастов от 16 до 25 включительно
  when age >= 26 and age <= 40 then '26-40' -- категория '26-40' для возрастов от 26 до 40
  when age > 40 then '40+' -- категория '40+' для возрастов больше 40
end as age_category, -- присваивает результат выражения алиасу 'age_category'
count(*) as age_count -- подсчитывает количество клиентов в каждой возрастной категории
from customers c -- таблица клиентов с псевдонимом c
group by age_category -- группирует по возрастной категории
order by age_category -- сортирует результаты по возрастной категории в алфавитном порядке

 -- special_offer

WITH first_acquisition AS ( -- объявляем временную таблицу (CTE), где будем хранить первую акционную покупку каждого клиента
  SELECT
    c.customer_id, -- идентификатор клиента
    c.first_name as customer_first_name, -- имя клиента
    c.last_name as customer_last_name, -- фамилия клиента
    s.sale_date, -- дата покупки
    e.first_name AS seller_first_name, -- имя продавца, связанного с продажей
    e.last_name AS seller_last_name, -- фамилия продавца
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY s.sale_date) AS rn -- нумерация покупок каждого клиента по дате, чтобы выделить первую
  FROM customers c -- таблица клиентов с псевдонимом c
  JOIN sales s ON c.customer_id = s.customer_id -- соединение клиентов с продажами по ID клиента
  JOIN employees e ON e.employee_id = s.sales_person_id -- соединение продаж с продавцами по ID продавца
  JOIN products p ON s.product_id = p.product_id -- соединение продаж с товарами по ID товара
  WHERE p.price = 0 -- фильтр — только товары по акции (стоимость = 0)
)
select 
  concat(customer_first_name,' ', customer_last_name) as customer, -- объединение имени и фамилии клиента в полном виде
  sale_date, -- дата первой акции
  concat(seller_first_name,' ', seller_last_name) as seller -- объединение имени и фамилии продавца
from first_acquisition -- из временной таблицы
where rn = 1 -- выбираем только первую покупку каждого клиента (самое раннее событие)
order by customer; -- сортируем по имени клиента
