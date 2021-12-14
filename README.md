### Задача 1

Доступные resource и data_source перечислены в файле provider.go  
ResourcesMap - https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L722  
DataSourcesMap - https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L341  

Параметр name ресурса aws_sqs_queue конфликтует с параметром "name_prefix" (строки 104, 112)  
https://github.com/hashicorp/terraform-provider-aws/blob/514f96ca5aca7646c7e245b9eb08f8efd9e15744/internal/service/sqs/queue.go#L104  

Не удалось найти код валидации имени по длине и регулярному выражению, возможно, этот код был удален в текущей версии провайдера.  
Но я думаю, веротянее всего валидация имени очереди сообщений располагалась бы в начале метода resourceQueueCreate  
https://github.com/hashicorp/terraform-provider-aws/blob/514f96ca5aca7646c7e245b9eb08f8efd9e15744/internal/service/sqs/queue.go#L195  

Или в методе Name в файле naming.go, если данная валидация должна быть глобальной для имен различных сущностей, не только очередей  
https://github.com/hashicorp/terraform-provider-aws/blob/514f96ca5aca7646c7e245b9eb08f8efd9e15744/internal/create/naming.go#L12