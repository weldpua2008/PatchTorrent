#!/bin/sh
# 2010.05
# this file fill proxy table, but I don't save tru version 
#ipfw table 2 flush


cat /tmp/tcpdump/stat.out|awk '{print $2}'|sort |uniq -u|awk  '{print "1262099350      "$1"  91.203.140.34"}'>/tmp/tcpdump/stat.out.tmp
cat /tmp/tcpdump/stat.out.tmp>/tmp/tcpdump/stat.out
echo "">/tmp/tcpdump/table.sh
cat /tmp/tcpdump/stat.out|awk '{print "ipfw table 2 add "$2" >/dev/null"}'>>/tmp/tcpdump/table.sh
/bin/sh /tmp/tcpdump/table.sh > /dev/null 2>&1

