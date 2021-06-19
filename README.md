### 1. Узнайте о sparse (разряженных) файлах.

Согласно определению, разреженный файл - файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях. Данный способ работы с файлами используется для экономии дискового пространства и ускорения записи файлов на диск.

### 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Не могут, т.к. все они ссылаются на один Inode, который и содержит информацию о владельце и правах доступа.

### 4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

Узнаем имена неразмеченных областей:  
**# fdisk -l**  
Согласно выводу данной команды это /dev/sdb и /dev/sdc	

Далее переходим в интерактивный режим программы fdisk для разметки диска /dev/sdb:  
**# fdisk /dev/sdb**  
В интерактивном режиме создаем 2 раздела используя команду **n**  
Проверяем получившуюся таблицу разделов через команду **p**:
```
Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux
```
Далее выполняем запись настроенных разделов через команду **w**. После этого fdisk завершает интерактивный режим.  

### 5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.

Записываем в файл разметку диска /dev/sdb  
**# sfdisk --dump /dev/sdb > sdb.dump**  

Применяем сохраненную разметку к диску /dev/sdc  
**# sfdisk /dev/sdc < sdb.dump**  

### 6. Соберите mdadm RAID1 на паре разделов 2 Гб.

**# mdadm --create /dev/md0 -l 1 -n 2 /dev/sd{b,c}1**

### 7. Соберите mdadm RAID0 на второй паре маленьких разделов.

**# mdadm --create /dev/md1 -l 0 -n 2 /dev/sd{b,c}2**

### 8. Создайте 2 независимых PV на получившихся md-устройствах.

**# pvcreate /dev/md0**  
**# pvcreate /dev/md1**  

### 9. Создайте общую volume-group на этих двух PV.

**# vgcreate vg /dev/md{0,1}**

### 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

**# lvcreate -L100M vg /dev/md1**

### 11. Создайте mkfs.ext4 ФС на получившемся LV.

**# mkfs.ext4 /dev/vg/lvol0**

### 12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.

**# mount /dev/vg/lvol0 /tmp/new**

### 14. Прикрепите вывод lsblk.
```
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─vg-lvol0       253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─vg-lvol0       253:2    0  100M  0 lvm   /tmp/new
```	
### 16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

**# pvmove /dev/md1 /dev/md0**

### 17. Сделайте --fail на устройство в вашем RAID1 md.

**# mdadm /dev/md0 --fail /dev/sdc1**

18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.

**# dmesg | grep raid1**  
[17896.279383] md/raid1:md0: not clean -- starting background reconstruction  
[17896.279386] md/raid1:md0: active with 2 out of 2 mirrors  
[18332.924874] md/raid1:md0: not clean -- starting background reconstruction  
[18332.924878] md/raid1:md0: active with 2 out of 2 mirrors  
[24039.241496] md/raid1:md0: Disk failure on sdc1, disabling device.  
               md/raid1:md0: Operation continuing on 1 devices.  
