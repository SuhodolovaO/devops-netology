### 1. 
После выполнения скрипта будет выдана ошибка выполнения при попытке сложить операнды разных типов.  
Чтобы получить в переменной **с** значение '12' нужно привести переменную **a** к строковому типу  
```
c = str(a) + b
```
Чтобы получить в переменной **с** значение 3 нужно привести переменную **b** к целочисленному типу  
```
c = a + int(b)
```

### 2. 

Доработанный вариант скрипта  
```
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
path = os.getcwd()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print('/'.join([path, prepare_result]))
```

### 3.
```
#!/usr/bin/env python3

import os
import sys

repo_path = sys.argv[1]
bash_command = ["cd " + repo_path, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
path = os.getcwd()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print('/'.join([path, prepare_result]))
```

### 4.
```
#!/usr/bin/env python3

import socket
import time

urls_ip = {'drive.google.com':'', 'mail.google.com':'', 'google.com':''}

while(True):
  for url in urls_ip.keys():
    ip = socket.gethostbyname(url)
    if(ip == urls_ip[url]):
      print(f'{url} - {ip}')
    else:
      if(urls_ip[url] != ''):
        print(f'[ERROR] {url} IP mismatch: {urls_ip[url]} {ip}')
      urls_ip[url] = ip

  time.sleep(60)
```
Бесконечный цикл добавлен для наглядности. В реальности можно запускать скрипт через cron, тогда можно будет убрать инструкции while(True) и time.sleep