### Задача 1

В Terraform.Cloud создан воркспейс, куда привязана папка из репозитория с ДЗ Нетологии  
https://github.com/SuhodolovaO/devops-netology/tree/main/terraform  

Результат Plan  
https://github.com/SuhodolovaO/devops-netology/blob/main/Screenshots/TC_Plan.png  

Результат Apply  
https://github.com/SuhodolovaO/devops-netology/blob/main/Screenshots/TC_Apply.png  

### Задача 2

Конфигурация сервера Atlantis  
https://raw.githubusercontent.com/SuhodolovaO/devops-netology/main/atlantis/server.yaml  

Конфигурация репозитория для работы с Atlantis  
https://raw.githubusercontent.com/SuhodolovaO/devops-netology/main/atlantis/atlantis.yaml

### Задача 3

Создание aws инстансов из предыдущего ДЗ при помощи модуля AWS EC2 Instance  
```
provider "aws" {
   region = "eu-north-1"
}

data "aws_ami" "amazon_linux" {
	most_recent = true
	owners      = ["amazon"]
	filter {
		name = "name"
		values = ["amzn-ami-hvm-*-x86_64-gp2"]
	}
	filter {
		name = "owner-alias"
		values = ["amazon"] 
	}
}

locals {
	netology_instance_types = {
		stage = "t3.micro"
		prod = "t3.large"
	}
	netology_instance_count = {
		stage = 1
		prod = 2
	}
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["stage", "prod"])

  ami = data.aws_ami.amazon_linux.id
  instance_type = local.netology_instance_types[each.key]
  count	= local.netology_instance_count[each.key]
}
```

Судя по коду модуля, он служит для более удобного указания значений при создании инстанса. Например, позволяет указать настройку **network_interface** в виде списка объектов и преобразует их в настройки **device_index**, **network_interface_id**, **delete_on_termination**.  
Я думаю, такие модули стоит использовать для упрощения работы, если не требуется более тонкая настройка инстансов. Например, в модуле не нашлось способа указать блок **lifecycle**, использованный в предыдущем домашнем задании для указания настройки **create_before_destroy**.
