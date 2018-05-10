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

ifconfig $iface1 down
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

# Some logic to map VF's to PF's specified in 'ports.sh'
phy2_slot=$(echo $phy2 | awk '{print substr($0,0,2)}')
phy2_func=$(echo $phy2 | awk '{print substr($0,6,2)}')
phy3_slot=$(echo $phy3 | awk '{print substr($0,0,2)}')
phy3_func=$(echo $phy3 | awk '{print substr($0,6,2)}')

if [ "$phy2_func" == ".0" ]; then phy2_func=02
elif [ "$phy2_func" == ".1" ]; then phy2_func=06
elif [ "$phy2_func" == ".2" ]; then phy2_func=0a
else
    phy2_func=0e
fi

if [ "$phy3_func" == ".0" ]; then phy3_func=02
elif [ "$phy3_func" == ".1" ]; then phy3_func=06
elif [ "$phy3_func" == ".2" ]; then phy3_func=0a
else
    phy3_func=0e
fi

# Print VF's to be used by each VM respectively.
echo ""
echo -e "${GR}PCI Devices to use on VNFC VM are:${NC}"
#lspci | grep Eth | grep "Virtual Function" | grep $phy3_slot | grep $phy3_func | head -2 | tail -1 | awk '{print $1}'
#lspci | grep Eth | grep "Virtual Function" | grep $phy2_slot | grep $phy2_func | head -2 | tail -1 | awk '{print $1}'
lspci | grep Eth | grep "Virtual Function" | grep $phy3_slot | grep $phy3_func | head -3 | tail -2 | awk '{print $1}'
echo ""
echo -e "${GR}PCI Devices to use on VNFD VM are:${NC}"
lspci | grep Eth | grep "Virtual Function" | grep $phy2_slot | grep $phy2_func | head -1 | awk '{print $1}'
lspci | grep Eth | grep "Virtual Function" | grep $phy3_slot | grep $phy3_func | head -1 | awk '{print $1}'
echo $phy0
echo ""
echo -e "${GR}PCI Devices to use on Delay VM are:${NC}"
lspci | grep Eth | grep "Virtual Function" | grep $phy2_slot | grep $phy2_func | tail -1 | awk '{print $1}'
lspci | grep Eth | grep "Virtual Function" | grep $phy3_slot | grep $phy3_func | tail -2 | awk '{print $1}'
echo $phy1
