#!/bin/sh
# 2010.05
# this file fill proxy table, but I don't save tru version 
ipfw table 2 flush
# ${ipfw} add fwd ${proxy_ip}, ${proxy_port} tcp from $lan_customers to 'table(2)' dst-port 80 in via ${int_if}

cat /tmp/tcpdump/stat.out|awk '{print $2}'|sort |uniq -u|awk  '{print "1262099350      "$1"  91.203.140.34"}'>/tmp/tcpdump/stat.out.tmp
cat /tmp/tcpdump/stat.out.tmp>/tmp/tcpdump/stat.out
echo "">/tmp/tcpdump/table.sh
cat /tmp/tcpdump/stat.out|awk '{print "ipfw table 2 add "$2" >/dev/null"}'>>/tmp/tcpdump/table.sh
/bin/sh /tmp/tcpdump/table.sh > /dev/null 2>&1

