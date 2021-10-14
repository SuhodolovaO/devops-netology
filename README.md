### 1. Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume
Файл для docker-compose
```
version: '3.1'

volumes:
  data:
  backup:

services:
  db:
    image: postgres
    container_name: postgres_db
    environment:
      POSTGRES_PASSWORD: postgres
    restart: "no"
    volumes:
      - data:/var/lib/postgresql/data
      - backup:/var/lib/postgresql/backup
```

### 2. Создание БД, пользователей и таблиц
**Итоговый список БД**
```
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)
```
**Описание таблиц**
```
postgres=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)
```
**SQL-запрос для выдачи списка пользователей с правами над таблицами test_db**  
SELECT * FROM information_schema.role_table_grants WHERE grantee IN ('test-admin-user','test-simple-user');

**Список пользователей с правами над таблицами test_db**
```
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user  | postgres      | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user  | postgres      | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | TRIGGER        | NO           | NO
 postgres | test-simple-user | postgres      | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | postgres      | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | postgres      | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | postgres      | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user  | postgres      | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | TRIGGER        | NO           | NO
 postgres | test-simple-user | postgres      | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | postgres      | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | postgres      | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | postgres      | public       | clients    | DELETE         | NO           | NO
(22 rows)
```

### 3. Используя SQL синтаксис - наполните таблицы тестовыми данными

**Таблица orders**
```
postgres=# INSERT INTO orders (name, price) VALUES ('Шоколад',10),('Принтер',3000),('Книга',500),('Монитор',7000),('Гитара',4000);
INSERT 0 5
postgres=# SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)
```

**Таблица clients**
```
postgres=# INSERT INTO clients (second_name, country) VALUES ('Иванов Иван Иванович','USA'),('Петров Петр Петрович','Canada'),('Иоганн Себастьян Бах','Japan'),('Ронни Джеймс Дио','Russia'),('Ritchie Blackmore','Russia');
INSERT 0 5
postgres=# SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)
```

### 4. Используя foreign keys свяжите записи из таблиц
```
postgres=# UPDATE clients SET order_id=3 WHERE id=1;
UPDATE 1
postgres=# UPDATE clients SET order_id=4 WHERE id=2;
UPDATE 1
postgres=# UPDATE clients SET order_id=5 WHERE id=3;
UPDATE 1
postgres=# SELECT c.* FROM clients c INNER JOIN orders o ON c.order_id=o.id;
 id | order_id |     second_name      | country
----+----------+----------------------+---------
  1 |        3 | Иванов Иван Иванович | USA
  2 |        4 | Петров Петр Петрович | Canada
  3 |        5 | Иоганн Себастьян Бах | Japan
(3 rows)
```

### 5. Получите  информацию по выполнению запроса выдачи всех пользователей.
```
postgres=# EXPLAIN SELECT c.* FROM clients c INNER JOIN orders o ON c.order_id=o.id;
                              QUERY PLAN
-----------------------------------------------------------------------
 Hash Join  (cost=17.20..29.36 rows=170 width=444)
   Hash Cond: (c.order_id = o.id)
   ->  Seq Scan on clients c  (cost=0.00..11.70 rows=170 width=444)
   ->  Hash  (cost=13.20..13.20 rows=320 width=4)
         ->  Seq Scan on orders o  (cost=0.00..13.20 rows=320 width=4)
(5 rows)
```
Здесь видно, что запрос сначала сканирует (Seq Scan) таблицу orders и записывает результат в хэш-таблицу (Hash). Затем то же самое проделывается по таблице clients с ограничением по order_id (Hash Cond). Затем значения хэш-таблиц сводятся вместе (Hash Join).

### 6. Backup/restore

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов.  
**# docker exec -ti postgres_db bash**  
**# pg_dumpall -U postgres > /var/lib/postgresql/backup/backup_14.10.21.sql**  
**# exit**

Остановите контейнер с PostgreSQL  
**# docker stop postgres_db**  

Поднимите новый пустой контейнер с PostgreSQL  
**# docker run -v /var/lib/docker/volumes/vagrant_backup/_data/:/var/lib/postgresql/backup -e POSTGRES_PASSWORD=postgres --name postgres_db_2 -d postgres**  

Восстановите БД test_db в новом контейнере  
**# docker exec -ti postgres_db_2 bash**  
**# psql -f /var/lib/postgresql/backup/backup_14.10.21.sql postgres -U postgres**