### Задача 1

Dockerfile
```
FROM centos:7

ARG VERSION

RUN yum install wget -y \
 && yum install perl-Digest-SHA -y \
 && wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.2-linux-x86_64.tar.gz \
 && wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.2-linux-x86_64.tar.gz.sha512 \
 && shasum -a 512 -c elasticsearch-7.15.2-linux-x86_64.tar.gz.sha512 \
 && tar -xzf elasticsearch-7.15.2-linux-x86_64.tar.gz \
 && rm elasticsearch-7.15.2-linux-x86_64.tar.gz

COPY elasticsearch.yml /elasticsearch-7.15.2/config

RUN mkdir /var/lib/logs \
 && mkdir /var/lib/data

RUN groupadd elasticsearch \
 && useradd elasticsearch -g elasticsearch \
 && chown -R elasticsearch:elasticsearch /elasticsearch-7.15.2 \
 && chown -R elasticsearch:elasticsearch /var/lib/logs \
 && chown -R elasticsearch:elasticsearch /var/lib/data

USER elasticsearch
EXPOSE 9200

ENTRYPOINT ["/elasticsearch-7.15.2/bin/elasticsearch"]
```

На хостовой машине предварительно создаем файл elasticsearch.yml со следующим содержимым
```
node.name: netology_test

path.data: /var/lib/data
path.logs: /var/lib/logs
```

Билд и запуск  
**# docker build -t elasticsearch -f elasticsearch_dockerfile .**  
**# docker run -d -p 9200:9200 --rm --name elasticsearch elasticsearch**  

Вывод на запрос пути /
```
# curl localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "LDSPNXq8SR-zB-HPUiNxVg",
  "version" : {
    "number" : "7.15.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "93d5a7f6192e8a1a12e154a2b81bf6fa7309da0c",
    "build_date" : "2021-11-04T14:04:42.515624022Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Ссылка на репозиторий  
https://hub.docker.com/layers/suhodolovao/netology/dz-6.5-elasticsearch/images/sha256-b4c20b5e92694fb1c1edb5018aab529505aa8f231b22a6256b5efc302525a93f

### Задача 2

Создание индексов  
**# curl -X PUT "localhost:9200/ind-1" -H 'Content-Type: application/json' -d  '{"settings": {"index": {"number_of_replicas": 0,"number_of_shards": 1}}}'**  
**# curl -X PUT "localhost:9200/ind-2" -H 'Content-Type: application/json' -d  '{"settings": {"index": {"number_of_replicas": 1,"number_of_shards": 2}}}'**  
**# curl -X PUT "localhost:9200/ind-3" -H 'Content-Type: application/json' -d  '{"settings": {"index": {"number_of_replicas": 2,"number_of_shards": 4}}}'**  

Получение списка индексов  
```
# curl localhost:9200/_cat/indices
green  open .geoip_databases A_bC5a6MSr-q3Izj5N0Apg 1 0 42 0 40.6mb 40.6mb
green  open ind-1            FyTdO6OHSvCfID6QbuhTOQ 1 0  0 0   208b   208b
yellow open ind-3            Phjay7ICTV6YvgO4sQN3Og 4 2  0 0   832b   832b
yellow open ind-2            TEFSbhirSNubN3HyGOIL4g 2 1  0 0   416b   416b
```

Получение состояния индексов
```
# curl localhost:9200/_cluster/health/ind-1?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

# curl localhost:9200/_cluster/health/ind-2?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

# curl localhost:9200/_cluster/health/ind-3?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Получение состояние кластера  
```
# curl localhost:9200/_cluster/health?pretty
{
   "cluster_name":"elasticsearch",
   "status":"yellow",
   "timed_out":false,
   "number_of_nodes":1,
   "number_of_data_nodes":1,
   "active_primary_shards":8,
   "active_shards":8,
   "relocating_shards":0,
   "initializing_shards":0,
   "unassigned_shards":10,
   "delayed_unassigned_shards":0,
   "number_of_pending_tasks":0,
   "number_of_in_flight_fetch":0,
   "task_max_waiting_in_queue_millis":0,
   "active_shards_percent_as_number":44.44444444444444
}
```

Два индекса и кластер находятся в состоянии yellow, потому что у них указано число реплик 2 и 4, хотя в кластере всего одна нода, и реплики создавать негде.

Удаление индексов
```
# curl -X DELETE "localhost:9200/ind-1"
{"acknowledged":true}
# curl -X DELETE "localhost:9200/ind-2"
{"acknowledged":true}
# curl -X DELETE "localhost:9200/ind-3"
{"acknowledged":true}
```

### Задача 3

Предварительно добавляем настройку **path.repo: /elasticsearch-7.15.2/snapshots** в elasticsearch.yml и пересоздаем образ elasticsearch.  

Создание репозитория  
```
# curl -X PUT "localhost:9200/_snapshot/netology_backup" -H 'Content-Type: application/json' -d'{"type": "fs","settings": {"location": "/elasticsearch-7.15.2/snapshots"}}'
{"acknowledged":true}
```

Создание индекса test
```
# curl -X PUT "localhost:9200/test" -H 'Content-Type: application/json' -d  '{"settings": {"index": {"number_of_replicas": 0,"number_of_shards": 1}}}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
# curl localhost:9200/_cat/indices
green open .geoip_databases 8Qtg1sUaQhaO0szPpxwMIQ 1 0 42 0 40.6mb 40.6mb
green open test             QqE6-oH7QxKrXm3I9W2NrQ 1 0  0 0   208b   208b
```

Создание снапшота
```
# curl -X PUT "localhost:9200/_snapshot/netology_backup/test_snapshot?wait_for_completion=true&pretty"
{
   "snapshot":{
      "snapshot":"test_snapshot",
      "uuid":"TFJ8o08TSmi6h6QD62mX5Q",
      "repository":"netology_backup",
      "version_id":7150299,
      "version":"7.15.2",
      "indices":[
         "test",
         ".geoip_databases"
      ],
      "data_streams":[
         
      ],
      "include_global_state":true,
      "state":"SUCCESS",
      "start_time":"2021-11-13T12:43:02.434Z",
      "start_time_in_millis":1636807382434,
      "end_time":"2021-11-13T12:43:04.240Z",
      "end_time_in_millis":1636807384240,
      "duration_in_millis":1806,
      "failures":[
         
      ],
      "shards":{
         "total":2,
         "failed":0,
         "successful":2
      },
      "feature_states":[
         {
            "feature_name":"geoip",
            "indices":[
               ".geoip_databases"
            ]
         }
      ]
   }
}
```

Список файлов в репозитории
```
# docker exec -ti elasticsearch bash
$ ll /elasticsearch-7.15.2/snapshots
-rw-r--r-- 1 elasticsearch elasticsearch   831 Nov 13 12:43 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Nov 13 12:43 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Nov 13 12:43 indices
-rw-r--r-- 1 elasticsearch elasticsearch 27617 Nov 13 12:43 meta-TFJ8o08TSmi6h6QD62mX5Q.dat
-rw-r--r-- 1 elasticsearch elasticsearch   440 Nov 13 12:43 snap-TFJ8o08TSmi6h6QD62mX5Q.dat
```

Удаление индекса test и создание индекса test-2  
```
# curl -X DELETE "localhost:9200/test"
{"acknowledged":true}
# curl -X PUT "localhost:9200/test-2" -H 'Content-Type: application/json' -d  '{"settings": {"index": {"number_of_replicas": 0,"number_of_shards": 1}}}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}
# curl localhost:9200/_cat/indices
green open test-2           kac6p70CT_Wa2-4an4xceQ 1 0  0 0   208b   208b
green open .geoip_databases vzWujUNdQCKXhlOk21XN6A 1 0 42 0 40.6mb 40.6mb
```

Восстановление состояния кластера
```
# curl -X POST "localhost:9200/_snapshot/netology_backup/test_snapshot/_restore" -H 'Content-Type: application/json' -d'{"include_global_state": "true"}'
{"accepted" : true}
# curl localhost:9200/_cat/indices
green open test-2           wu10ciUCSNuR2ePyQfKQWw 1 0  0 0   208b   208b
green open .geoip_databases 4GretJ-0SNa2ln3uayc6og 1 0 42 0 40.6mb 40.6mb
green open test             BL1Xlt44RPSK3TQntzYAdA 1 0  0 0   208b   208b
```

Параметр **"include_global_state"** в команде восстановления кластера указан для обхода проблемы, описанной здесь https://github.com/elastic/elasticsearch/issues/78320  
Другой вариант восстановления в данном случае - указать имя отдельного индекса для восстановления **-d'{"indices": "test"}'**