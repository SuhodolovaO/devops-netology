# devops-netology

В папке terraform и вложенных в неё будут проигнорированы следующие файлы:
- лежащие в папке .terraform
- с расширением .tfstate или содержащие в названии часть '.tfstate'
- с именем crash.log
- с расширением .tfvars
- с именами override.tf, override.tf.json или заканчивающиеся на '_override.tf', '_override.tf.json'
- с именами .terraformrc, terraform.rc

One more line