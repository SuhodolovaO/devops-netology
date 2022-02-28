### 1. Опишите основные плюсы и минусы pull и push систем мониторинга.

**Pull системы**  
Плюсы: единая точка настройки списка агентов и получаемых метрик, исключение получения данных от неподтвержденных агентов  
Минусы: дополнительная нагрузка по генерации/обработке двусторонних запросов  

**Push системы**  
Плюсы: меньшая нагрузка на систему обрабоки за счет односторонней связи агентов с системой мониторинга    
Минусы: необходимость настраивать список метрик и частоту отправки для каждого агента (но это может быть и плюсом)  

### 2. Какие из ниже перечисленных систем относятся к push модели, а какие к pull?

Prometheus - push/pull  
TICK - push/pull  
Zabbix  - push/pull  
VictoriaMetrics - push/pull  
Nagios - pull

### 3. Запустите TICK-стэк, используя технологии docker и docker-compose.

После запуска TICK через docker-compose influxdb и kapacitor возвращают ответ 204. Chronograf возвращает 200 ответ с html кодом  
https://github.com/SuhodolovaO/devops-netology/blob/main/Screenshots/TICK_curl.png

Интерфейс Chronograf  
https://github.com/SuhodolovaO/devops-netology/blob/main/Screenshots/Chronograf_main.png

### 4. Веб-интерфейс Chronograf

Метрики утилизации места на диске  
https://github.com/SuhodolovaO/devops-netology/blob/main/Screenshots/Chronograf_metrics.png

### 5. Добавление docker-метрик

После выполнения указанных в задании действий метрики в интерфейсе не появились. Эксперименты с настройками, перезапуск сервисов и вопросы в общем чате не помогли. Поэтому отправляю задание как есть.