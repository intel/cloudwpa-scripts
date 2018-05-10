#!/bin/expect

# VNFC
# Static routes to Home GWs must be initialized on VNFC
# These should be configured in file below on host.
# These are required for communication from VNFC to RADIUS/Home GW
spawn scp ../../vnfc/add_static_routes.sh root@192.168.122.232:.
expect "root@192.168.122.232's password: "
send "tester\r"
spawn ssh root@192.168.122.232
expect "root@192.168.122.232's password: "
send "tester\r"
sleep 2
send "systemctl restart network\r"
sleep 5
send "./add_static_routes.sh\r"
send "cd rwpa_vnf/scripts/vnfc\r"
send "rm -rf ~/logfile.txt\r"
send "./setup.sh >> ~/logfile.txt\r"
interact timeout 2 exit
