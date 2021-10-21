### Задача 1
Версия сервера БД: 8.0.27 MySQL Community Server - GPL  
Список таблиц БД  
```
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
```
Количество записей с price > 300 : 1 запись

### Задача 2
Создание пользователя  
**CREATE USER test  
IDENTIFIED BY 'test-pass'  
IDENTIFIED WITH mysql_native_password   
WITH MAX_QUERIES_PER_HOUR 100  
PASSWORD EXPIRE INTERVAL 180 DAY  
FAILED_LOGIN_ATTEMPTS 3  
ATTRIBUTE '{"Last name": "Pretty", "First name": "James"}';**  

Данные по пользователю test
```
+------+------+------------------------------------------------+
| USER | HOST | ATTRIBUTE                                      |
+------+------+------------------------------------------------+
| test | %    | {"Last name": "Pretty", "First name": "James"} |
+------+------+------------------------------------------------+
```

### Задача 3
С помощью команды **SHOW TABLE STATUS WHERE Name = 'orders';** получаем исходный движок таблицы orders - InnoDB.  

Меняем движок на MyISAM  
**ALTER TABLE orders ENGINE = MyISAM;**  

Выполняем запросы и смотрим вывод профайлера  
```
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------+
| Query_ID | Duration   | Query                                           |
+----------+------------+-------------------------------------------------+
|        1 | 0.00095900 | SELECT * FROM orders                            |
|        2 | 0.00100525 | SELECT * FROM orders WHERE title LIKE '%mysql%' |
|        3 | 0.00109150 | SELECT * FROM orders WHERE price>100            |
+----------+------------+-------------------------------------------------+
```

Меняем движок обратно на InnoDB и смотрим вывод профайлера  
```
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------+
| Query_ID | Duration   | Query                                           |
+----------+------------+-------------------------------------------------+
|        1 | 0.00092400 | SELECT * FROM orders                            |
|        2 | 0.00139350 | SELECT * FROM orders WHERE title LIKE '%mysql%' |
|        3 | 0.00149400 | SELECT * FROM orders WHERE price>100            |
+----------+------------+-------------------------------------------------+
```

### Задача 4

Измененный файл my.cnf
```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

innodb_flush_log_at_trx_commit = 2
innodb_file_per_table=ON
innodb_log_buffer_size=1M
innodb_buffer_pool_size=138M
innodb_log_file_size=100M

# Custom config should go here
!includedir /etc/mysql/conf.d/
```

Размер буфера кеширования в 138 Мб был выбран исходя из наличия 460 Мб свободной памяти на хосте.