### Задача 1
Запуск контейнера postgres_db с расшаренной директорией для volume и директорией, содержащий дамп БД  
**# docker run --name postgres_db -v /var/lib/docker/volumes/vagrant_postgres_data/_data:/var/lib/postgres -v /home/vagrant:/home -e POSTGRES_PASSWORD=postgres -d postgres**  

Подключение к postgres в командной строке запущенного контейнера  
**psql -U postgres**  

Управляющие команды:  
вывод списка БД -      \l[+]   [PATTERN]  
подключение к БД -     \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}  
вывода списка таблиц - \dt[S+] [PATTERN]  
выхода из psql         \q  
вывода описания содержимого таблиц - \d[S+]  NAME  

### Задача 2
Создание БД  
**postgres=# CREATE DATABASE test_database;**  

Восстановление из бекапа  
**# psql -U postgres test_database < /home/test_dump.sql**  

Запуск сбора статистики  
**test_database=# ANALYZE orders;**  
**INFO:  analyzing "public.orders"**  
**INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows**  

Поиск столбца с наибольшим средним значением размера элементов в байтах  
**test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename='orders' ORDER BY avg_width DESC LIMIT 1;**  
Результат
```
 attname | avg_width
---------+-----------
 title   |        16
```

### Задача 3
Шардинг таблицы orders на orders_1, orders_2  
```
BEGIN;

CREATE TABLE orders_1(CHECK(price>499)) INHERITS(orders);
CREATE TABLE orders_2(CHECK(price<=499)) INHERITS(orders);

CREATE RULE orders_to_1 AS 
ON INSERT TO orders WHERE price>499 
DO INSTEAD 
INSERT INTO orders_1 VALUES (NEW.*);

CREATE RULE orders_to_2 AS 
ON INSERT TO orders WHERE price<=499 
DO INSTEAD 
INSERT INTO orders_2 VALUES (NEW.*);

CREATE TEMP TABLE orders_temp ON COMMIT DROP
AS SELECT * FROM orders;

DELETE FROM orders;

INSERT INTO orders_1 SELECT * FROM orders_temp WHERE price>499;
INSERT INTO orders_2 SELECT * FROM orders_temp WHERE price<=499;

COMMIT;
```

Для избежания ручного переноса данных можно было при создании таблицы orders применить декларативное партиционирование.
```
CREATE TABLE orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
)
PARTITION BY RANGE (price);

CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (500) to (MAXVALUE);
CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (0) to (500);
```

### Задача 4
Создание дампа  
**# pg_dump test_database > /home/test_database_backup.sql -U postgres**  

Добавление уникальности для поля title  
**postgres=# ALTER TABLE orders ADD CONSTRAINT title_unique UNIQUE (title);**