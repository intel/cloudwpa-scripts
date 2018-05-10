##############################################################################
#   BSD LICENSE
# 
#   Copyright(c) 2007-2017 Intel Corporation. All rights reserved.
#   All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without 
#   modification, are permitted provided that the following conditions 
#   are met:
# 
#     * Redistributions of source code must retain the above copyright 
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in 
#       the documentation and/or other materials provided with the 
#       distribution.
#     * Neither the name of Intel Corporation nor the names of its 
#       contributors may be used to endorse or promote products derived 
#       from this software without specific prior written permission.
# 
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
#   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
#   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
#   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#  version: RWPA_VNF.L.18.02.0-42
##############################################################################

#!/bin/bash

GR='\033[0;32m'
NC='\033[0m'

export SCRIPT_DIR=$PWD

[[ -z "${DPDK_DIR}" ]] && DPDK='/root/dpdk' || DPDK="${DPDK_DIR}"

. ports_delay.sh

ifconfig $iface0 down
ifconfig $iface1 down
ifconfig $iface2 down
ifconfig $iface3 down

# Remove VF's from devices before altering device bindings
max_vfs=$(find /sys/ -name max_vfs | grep "$phy3")
echo 0 > $max_vfs
max_vfs=$(find /sys/ -name max_vfs | grep "$phy2")
echo 0 > $max_vfs

# Insert DPDK igb_uio module
cd $DPDK
modprobe uio
insmod x86_64-native-linuxapp-gcc/kmod/igb_uio.ko

# Bind devices to correct drivers
./usertools/dpdk-devbind.py -b i40e $phy0
./usertools/dpdk-devbind.py -b i40e $phy1
./usertools/dpdk-devbind.py -b igb_uio $phy2
./usertools/dpdk-devbind.py -b igb_uio $phy3

# Create 2 VF's for delay, 1 for VNFC TLS, 1 for VNFD uplink, 1 for VNFC CPE
max_vfs=$(find /sys/ -name max_vfs | grep "$phy3")
echo 0 > $max_vfs
echo 5 > $max_vfs

# Create 1 VF for Delay, 1 for VNFD TLS
max_vfs=$(find /sys/ -name max_vfs | grep "$phy2")
echo 0 > $max_vfs
echo 2 > $max_vfs

# Remove VF kernel driver.
rmmod i40evf

# Run PF of phy2 + phy3 to allow use of VF's
cd $SCRIPT_DIR
cd ../../../pf_init/build
./pf_init -l 2,3 -w $phy2 -w $phy3 --socket-mem 256,256 -- -p 0x3 -m 00:00:00:00:00:05 &
sleep 30

# Interfaces are prepared - You may now start VM's
virsh start VNFC-DELAY
virsh start VNFD-DELAY
virsh start DELAY-VM

echo -e "${GR}VM's are now booting up...${NC}"
sleep 60
cd $SCRIPT_DIR

echo ""
echo ""
echo -e "${GR}Starting DELAY-VNF application...${NC}"
echo ""
echo ""
./update_delays.sh
echo ""
echo ""
echo -e "${GR}Starting VNFC application...${NC}"
echo ""
echo ""
./run_vnfc.sh
echo ""
echo ""
echo -e "${GR}Starting VNFD application...${NC}"
echo ""
echo ""
./run_vnfd.sh
echo ""
echo ""
echo -e "${GR}VNF is started with delay simulatoin , You may now start CPE!${NC}"
echo -e "${GR}See below for VNFC monitor for CPE and station connections${NC}"
echo -e "${GR}To change the simulated delays eidt and execute 'update_delays.sh' script!${NC}"
echo ""
echo ""
./monitor_vnfc.sh
