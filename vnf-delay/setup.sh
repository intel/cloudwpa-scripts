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

ifconfig ens8 down
ifconfig ens9 down
ifconfig ens10 down
ifconfig ens11 down
cd /root/dpdk
modprobe uio
insmod x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
./usertools/dpdk-devbind.py -b igb_uio 00:08.0 00:09.0 00:0a.0 00:0b.0

cd /root/rwpa_vnf/sim/build/
delay_vnfc_vnfd=$( expr $1 - $2 )
delay_vnfc_cpe=$1
delay_vnfd_cpe=$2
vnfd_ip=$3
radius_ip=$4
./rwpa_test_sim -c 0x3 -w 00:08.0 -w 00:09.0 --socket-mem 1024 --file-prefix delayA -- -p 0x3 --mode delay --delay-a $delay_vnfc_vnfd &
./rwpa_test_sim -c 0xc -w 00:0a.0 -w 00:0b.0 --socket-mem 1024 --file-prefix delayAB -- -p 0x3 --mode delay --delay-a $delay_vnfc_cpe --delay-b $delay_vnfd_cpe --ip-b $vnfd_ip --delay-noneip $4 &
