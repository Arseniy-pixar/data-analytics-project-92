select count(customer_id) as customers_count

from customers

Данный запрос использует таблицу customers и благодаря команде COUNT(customer_id) считает количество ID клиентов и как следствие количество самих клиентов(потому что информация об ID есть всегда) и выводит ответ на запрос.
