PatchTorrent
============
������� � �������� �������������� �� �����, ������� �� ���� ���������� ���������� �������� �������� ����� ������
��� ��� ��� ������� �� ������������ ��� 2+ ����, �� ��� ������������ ��� =(

Linux:
 iptables -t nat -N TRACKERS 
 # ����� ������, ������ �� ������� iptables -t mangle -A PREROUTING -m string --string "Content-Type: application/x-bittorrent" --algo kmp --to 1500 -j LOG 
 # �������� ������ ������, ������ �� ������ iptables -t nat -A TRACKERS -s 176.16.8.0/22 -j ACCEPT iptables -t nat -A TRACKERS -p tcp --dport 80 -j REDIRECT --to-ports 3128 iptables -t nat -A TRACKERS -j ACCEPT 

��������� ������� ����������� �������� get_tracker_list

#!/bin/bash
# �������� ����� ��� ����, ���� ��������� ���� tracker_list � ������ ��������������� ������� � iptables
FILE=/home/torrents/tracker_list
while read LINE
  do
    IP=$LINE
    if [ "`iptables -t nat -nvL | grep $IP`" == "" ]; then
      iptables -t nat -A PREROUTING -d $IP -j TRACKERS
    fi
  done < $FILE

���� /home/torrents/tracker_list ����������� �������� mk_tracker_list

#!/bin/bash
# ���� �������� ��������� ����, � ������� ��������� ��������� ������ ����� ��������. 
# �������� ������ ����� �� ����� /var/log/kern.log
# ���� � ���� �������� �������� ������ � iptables ������ ������ �������
# iptables -t mangle -A PREROUTING -m string --string "Content-Type: application/x-bittorrent" --algo kmp --to 1500 -j LOG
# ���������� ��������� ����� /home/torrents/tcpdump/tracker_list ������������ �������� get_tracker_list
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

������-������ middleman:  mman.xml. 
#ipfw add fwd 127.0.0.1,3128 tcp from 10.54.0.0/16 to table(15) dst-port 80 in via vlan3050


Squid:
� ��������� ������ ��������� ������ ������������� ����������� ������ ��� squid � ������ TPROXY ��� Linux
��� FreeBSD ����������� ��������� ����������� ������ � ���� ����� Squid - Cacheboy. �� � ���� ����������� ����������� ��������� ������������ �������� � �������, ��������� ecap/icap � �� ����������� � �������� �� �����.


PatchTorrent
