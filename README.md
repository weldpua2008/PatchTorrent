PatchTorrent
============
������� � �������� �������������� �� �����, ������� �� ���� ���������� ���������� �������� �������� ����� ������
��� ��� ��� ������� �� ������������ ��� 2+ ����, �� ��� ������������ ��� =(

Linux:
 iptables -t nat -N TRACKERS 
 # ����� ������, ������ �� ������� iptables -t mangle -A PREROUTING -m string --string "Content-Type: application/x-bittorrent" --algo kmp --to 1500 -j LOG 
 # �������� ������ ������, ������ �� ������ iptables -t nat -A TRACKERS -s 176.16.8.0/22 -j ACCEPT iptables -t nat -A TRACKERS -p tcp --dport 80 -j REDIRECT --to-ports 3128 iptables -t nat -A TRACKERS -j ACCEPT 

crontable
#0       3       *       *       *       root /root/script/FreeBSD.fill_proxy_table.sh

PatchTorrent
