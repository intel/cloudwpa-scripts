#!/bin/expect

# Monitor
# This allows for monitoring of VNFC CPE/station connections
spawn ssh root@192.168.122.232
expect "root@192.168.122.232's password: "
send "tester\r"
sleep 2
send "tail -f logfile.txt\r"
interact
