ЗАПРОС 1

select
  case when age >= 16 and age <= 25 then '16-25' -- определяет категорию '16-25' для возрастов от 16 до 25 включительно
  when age >= 26 and age <= 40 then '26-40' -- категория '26-40' для возрастов от 26 до 40
  when age > 40 then '40+' -- категория '40+' для возрастов больше 40
end as age_category, -- присваивает результат выражения алиасу 'age_category'
count(*) as age_count -- подсчитывает количество клиентов в каждой возрастной категории
from customers c -- таблица клиентов с псевдонимом c
group by age_category -- группирует по возрастной категории
order by age_category -- сортирует результаты по возрастной категории в алфавитном порядке

ЗАПРОС 2

select to_char(s.sale_date, 'YYYY-MM') as selling_month, -- преобразует дату продажи в формат 'ГОД-МЕСЯЦ' и задает алиас 'selling_month'
COUNT(DISTINCT c.customer_id) as total_customers, -- подсчитывает уникальных покупателей за месяц
sum(p.price * s.quantity) as income -- суммирует выручку за месяц (цена товара умноженная на количество)
from customers as c -- таблица клиентов с псевдонимом c
inner join sales as s on c.customer_id = s.customer_id -- соединяет клиентов с продажами по ID клиента
join products as p on s.product_id = p.product_id -- соединяет продажи с товарами по ID товара
group by 1 -- группирует данные по первому выбранному полю (сюда входит 'YYYY-MM')
order by 1 -- сортирует результат по тому же полю, по месяцу

ЗАПРОС 3

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
