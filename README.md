PatchTorrent
============
«апросы к тракерам заворачиваютс€ на —квид, который на лету пропускает отдаваемые клиентам торренты через патчер
“ак как это решение не используетс€ уже 2+ года, то это неработающий код =(

Linux:
 iptables -t nat -N TRACKERS 
 # ловим пакеты, идущие на трекеры iptables -t mangle -A PREROUTING -m string --string "Content-Type: application/x-bittorrent" --algo kmp --to 1500 -j LOG 
 # передаем проксе пакеты, идущие на трекер iptables -t nat -A TRACKERS -s 176.16.8.0/22 -j ACCEPT iptables -t nat -A TRACKERS -p tcp --dport 80 -j REDIRECT --to-ports 3128 iptables -t nat -A TRACKERS -j ACCEPT 

crontable
#0       3       *       *       *       root /root/script/FreeBSD.fill_proxy_table.sh

PatchTorrent
