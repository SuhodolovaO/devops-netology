### 1. 
После выполнения скрипта  
```
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```
переменные получат следующие значения:  
с - значение "a+b", т.к. в нее записывается выражение, интерпретируемое как строка  
d - значение "1+2", т.к. в нее записывается выражение, в которое подставляются значения переменных a и b, и результат интерпретируется как строка  
e - значение 3, т.к. в нее записывается результат функции сложения значений переменных a и b

### 2. 

Исправленный вариант скрипта  
```
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	else
		break
	fi
done
```

### 3.
```
#!/bin/bash
port=80
arr_ip=("192.168.0.1" "173.194.222.113" "87.250.250.242")
for ip in ${arr_ip[@]}
do
	i=1
	while (($i<=5))
	do
		avail=OK
		curl https://$ip:$port		
		if (($? != 0))
		then
			avail=FAIL
		fi
		echo "Address: ${ip}, attempt: ${i}, avaliable: ${avail}" >> curl.log
		let "i += 1"
	done
done
```

### 4.
```
#!/bin/bash
port=80
arr_ip=("192.168.0.1" "173.194.222.113" "87.250.250.242")
while ((1==1))
do
	error=0
	for ip in ${arr_ip[@]}
	do
		curl https://$ip:$port		
		if (($? != 0))
		then
			echo $ip >> error.log
			error=1
			break
		fi
	done
	if(($error==1))
	then
		break
	fi
done
```