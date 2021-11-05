### Задача 1

Измененный Dockerfile
```
FROM archlinux

RUN pacman -Syu --noconfirm
RUN pacman -S ponysay --noconfirm

CMD ["/usr/bin/ponysay", "Hey, netology"]
```

Запуск билда образа  
**# docker build -t pony_arch -f dockerfile .**  

Запуск контейнера в интерактивном режиме, который удалится после завершения работы  
**# docker run -ti --rm --name pony pony_arch**  

Вывод программы  
https://github.com/SuhodolovaO/devops-netology/blob/main/pony.png

Создание образа с тегом и отправка в репозиторий  
**# docker image tag pony_arch suhodolovao/netology:dz-5.4-pony**  
**# docker image push suhodolovao/netology:dz-5.4-pony**  

Ссылка на образ  
https://hub.docker.com/layers/suhodolovao/netology/dz-5.4-pony/images/sha256-8b15c3c6900d9782eb6668980e5c469983abd20c0e5c94e79dc0fc0ffe7e5642

### Задача 2

**Jenkins на amazoncorreto**  

Dockerfile
```
FROM amazoncorretto

ARG JENKINS_VERSION
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

RUN mkdir -p /usr/share/jenkins \
 && curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war

EXPOSE 8080

CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
```

Команда для билда  
**# docker build --build-arg JENKINS_VERSION=2.303.2 -t jenkins:ver1 -f dockerfile_jenkins_amazon .**  

Команда запуска  
**# docker run -ti -p 8080:8080 --name ja jenkins:ver1**  

Вывод в логах  
https://github.com/SuhodolovaO/devops-netology/blob/main/jenkins_logs_ver1.png  

Вывод в браузере  
https://github.com/SuhodolovaO/devops-netology/blob/main/jenkins_screen_ver1.png  

Ссылка на образ  
https://hub.docker.com/layers/suhodolovao/netology/dz-5.4-ver1/images/sha256-d484c74177099beb580214221c986dcc2bd6588b1eebfe75b4f880d22e2fba0b



**Jenkins на ubuntu**  

Dockerfile
```
FROM ubuntu:latest

ARG JENKINS_VERSION
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

RUN apt-get update \
 && apt-get install -y openjdk-11-jdk \
 && apt-get install -y curl \
 && mkdir -p /usr/share/jenkins \
 && curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war

EXPOSE 8080

CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
```

Команда для билда  
**# docker build --build-arg JENKINS_VERSION=2.303.2 -t jenkins:ver2 -f dockerfile_jenkins_ubuntu .**  

Команда запуска  
**# docker run -ti -p 5432:8080 --name jenkins2 jenkins:ver2**  

Вывод в логах  
https://github.com/SuhodolovaO/devops-netology/blob/main/jenkins_logs_ver2.png  

Вывод в браузере  
https://github.com/SuhodolovaO/devops-netology/blob/main/jenkins_screen_ver2.png  

Ссылка на образ  
https://hub.docker.com/layers/suhodolovao/netology/dz-5.4-ver2/images/sha256-23f420a5c133c10b11d4807b34a014fb0d5e48439369157ee3bfbeb18a417e15

### Задача 3
Dockerfile
```
FROM node:latest

WORKDIR /usr/share/simplicitesoftware

RUN curl -fsSL https://codeload.github.com/simplicitesoftware/nodejs-demo/zip/refs/heads/master -o master.zip \
 && unzip master.zip

WORKDIR /usr/share/simplicitesoftware/nodejs-demo-master

RUN npm install

EXPOSE 3000

ENTRYPOINT ["npm"]
CMD ["start"]
```

Билд образа и запуск контейнера simplicite  
**# docker build -t simplicite -f dockerfile_simplicite .**  
**# docker run -d -p 3000:3000 --name simplicite simplicite**  

Запуск ubuntu  
**# docker run -d -ti --name ubuntu ubuntu:latest**  

Создание сети  
**# docker network create test-net**  
**# docker network connect test-net simplicite**  
**# docker network connect test-net ubuntu**  

Получившаяся конфигурация сети test-net  
```
# docker network inspect test-net
[
    {
        "Name": "test-net",
        "Id": "bf9efd4455293b1e388637791c22b3bc8bc44258d32c4efa90de59947b57bfc0",
        "Created": "2021-11-04T18:25:35.948463251Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "47499c885505b6c53e0dcaeabe57051b5a6ceaf3f017a6db95e2f9f1bc8ec849": {
                "Name": "simplicite",
                "EndpointID": "cfffd79accd91fb157352bf007773319262746c19e9cd757cab20218ecfe10a4",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            },
            "6b5691c09c912f7f725fd3cfb3e962a366d0a859fa8f9eadbc0131a84a5597b1": {
                "Name": "ubuntu",
                "EndpointID": "77ec324c5134ba93a50caff9670348d3a08882957b45fe38c4bc006459ca7785",
                "MacAddress": "02:42:ac:12:00:03",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

Обращение к приложению simplicite из контейнера ubuntu  
**# docker exec -ti ubuntu bash**  
**# apt-get update && apt-get install curl**  
**# curl 172.18.0.2:3000 | head -c 500**

Результат
https://github.com/SuhodolovaO/devops-netology/blob/main/networking.png