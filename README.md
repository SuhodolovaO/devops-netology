### 2. Запустить Vault-сервер в dev-режиме

**$ vault server -dev -dev-listen-address="0.0.0.0:8200"**  

Стартуем новое окно терминала и выполняем следующие команды для передачи valut клиенту параметров vault сервера:  
**$ export VAULT_ADDR='http://0.0.0.0:8200'**  
**$ export VAULT_TOKEN="s.ylVfdbyr9ARr9XTBqevOAvb7"**

### 3. Используя PKI Secrets Engine, создайте Root CA и Intermediate CA.

Сначала создаем Root CA согласно инструкции  

Активация PKI Secrets Engine в неймспейсе pki  
**$ vault secrets enable pki**  
**Success! Enabled the pki secrets engine at: pki/**  

Установка максимального времени жизни сертификатов в 10 лет  
**$ vault secrets tune -max-lease-ttl=87600h pki**  
**Success! Tuned the secrets engine at: pki/**  

Аналогично создаем Intermediate CA с неймспейсом pki_int и максимальным временем жизни сертификатов 5 лет  
**$ vault secrets enable -path=pki_int pki**  
**$ vault secrets tune -max-lease-ttl=43800h pki_int**  

Генерация файла сертификата для Root CA  
**$vault write -field=certificate pki/root/generate/internal common_name="netology.example.com" ttl=87600h > CA_cert.crt**  
**$ ls**  
**CA_cert.crt**  

Генерация csr для Intermediate CA  
**$ vault write -format=json pki_int/intermediate/generate/internal common_name="netology.example.com Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr**  
**$ls**  
**CA_cert.crt  pki_intermediate.csr** 

На основе полученного csr генерируем сертификат, подписанный ключом Root CA  
**vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem**  
**$ ls**  
**CA_cert.crt  pki_intermediate.csr  intermediate.cert.pem** 

Импортируем получившийся сертификат в Intermediate CA  
**$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem**  
**Success! Data written to: pki_int/intermediate/set-signed**  

### 4. Подпишите Intermediate CA csr на сертификат для тестового домена

Создаем роль для тестового домена  
**$ vault write pki_int/roles/netology-example-dot-com allowed_domains="netology.example.com" allow_subdomains=true max_ttl="720h"**  
**Success! Data written to: pki_int/roles/netology-example-dot-com**  

Генерируем сертификат для тестового домена  
**$ vault write pki_int/issue/netology-example-dot-com common_name="netology.example.com" ttl="24h"**  
Выведенные в консоль ключи сохраняем в файлы netology.example.com.key (приватный ключ) и netology.example.com.pem (подписанный Intermediate CA сертификат с публичным ключом)

### 5. Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена.

В файл конфигурации дефолтного хоста добавляем следующие строки
```
listen 443 ssl;
listen [::]:443 ssl;

ssl_certificate /usr/share/nginx/html/netology.example.com.pem;
ssl_certificate_key /usr/share/nginx/html/netology.example.com.key;
```

### 6. Добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен

Модифицируем /ets/hosts для доступа к хосту по имени  
**$ echo 127.0.0.1 netology.example.com >> /etc/hosts** 

Добавляем сертификат Intermediate CA в доверенные (предварительно изменим расширение pem файла на crt, чтобы команда update-ca-certificates обработала сертификат)  
**$ cp intermediate.cert.pem intermediate.cert.crt**  
**$ ln intermediate.cert.crt /usr/local/share/ca-certificates/intermediate.cert.crt**  
**$ update-ca-certificates**

Проверяем работоспособность хоста  
**$ curl -I -s https://netology.example.com | head -n1**  
**HTTP/1.1 200 OK**