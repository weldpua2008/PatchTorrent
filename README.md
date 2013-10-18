PatchTorrent
============
Запросы к тракерам заворачиваются на Сквид, который на лету пропускает отдаваемые клиентам торренты через патчер
Так как это решение не используется уже 2+ года, то это неработающий код =(

Вот ветка: http://forum.nag.ru/forum/index.php?showtopic=47615&view=findpost&p=449831

Linux:
 iptables -t nat -N TRACKERS 
 # ловим пакеты, идущие на трекеры iptables -t mangle -A PREROUTING -m string --string "Content-Type: application/x-bittorrent" --algo kmp --to 1500 -j LOG 
 # передаем проксе пакеты, идущие на трекер iptables -t nat -A TRACKERS -s 176.16.8.0/22 -j ACCEPT iptables -t nat -A TRACKERS -p tcp --dport 80 -j REDIRECT --to-ports 3128 iptables -t nat -A TRACKERS -j ACCEPT 

остальные правила добавляются скриптом get_tracker_list

#!/bin/bash
# Скриптик нужен для того, чтоб прочитать файл tracker_list и внести соответствующие правила в iptables
FILE=/home/torrents/tracker_list
while read LINE
  do
    IP=$LINE
    if [ "`iptables -t nat -nvL | grep $IP`" == "" ]; then
      iptables -t nat -A PREROUTING -d $IP -j TRACKERS
    fi
  done < $FILE

файл /home/torrents/tracker_list формируется скриптом mk_tracker_list

#!/bin/bash
# Этот скриптик формирует файл, в который постоянно добавляет адреса новых трекеров. 
# Исходные данные берет из логов /var/log/kern.log
# Чтоб в логи попадали исходные данные в iptables должно висеть правило
# iptables -t mangle -A PREROUTING -m string --string "Content-Type: application/x-bittorrent" --algo kmp --to 1500 -j LOG
# Дальнейшая обработка файла /home/torrents/tcpdump/tracker_list производится скриптом get_tracker_list
FILE_OUT=/home/torrents/tracker_list
FILE_IN=/var/log/kern.log
while read LINE
  do
    IP=`echo $LINE | grep SRC= | awk -F= {'print $5'} | awk {'print $1'}`
    if [ "$IP" != "" ]; then
      if [ "`cat $FILE_OUT | grep $IP`" == "" ]; then
        echo $IP >> $FILE_OUT
      fi
    fi
done < $FILE_IN




crontable
#0       3       *       *       *       root /root/script/FreeBSD.fill_proxy_table.sh

прокси-сервер middleman:  mman.xml. 
#ipfw add fwd 127.0.0.1,3128 tcp from 10.54.0.0/16 to table(15) dst-port 80 in via vlan3050

конфига monit, следящего за доступностью прокси-сервера (по хорошему, нуждается в доработке условий и action'a):
CODE
check process middleman with pidfile /var/run/mman.pid
    start program = "/usr/local/etc/rc.d/mman.sh start"
    stop program  = "/usr/local/etc/rc.d/mman.sh stop"
    if cpu > 60% for 2 cycles then alert
    if totalmem > 200.0 MB for 5 cycles then alert
    if loadavg(5min) greater than 3 for 8 cycles then alert
    if failed host 10.78.77.35 port 3128 with timeout 5 seconds then restart
    if 3 restarts within 5 cycles then timeout


Squid:
В настоящий момент поддержка такого проксирования реализована только для squid с патчем TPROXY под Linux
Под FreeBSD аналогичное поведение реализовано только в бете форка Squid - Cacheboy. Но у него отсутствуют возможности выполнять произвольные операции с файлами, поскольку ecap/icap в нём отсутствует и добавлен не будет.


PatchTorrent
