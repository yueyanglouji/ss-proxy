#!/bin/bash

SS_CONFIG=${SS_CONFIG:-""}
SS_MODULE=${SS_MODULE:-"ss-server"}
KCP_CONFIG=${KCP_CONFIG:-""}
KCP_MODULE=${KCP_MODULE:-"kcpserver"}
KCP_FLAG=${KCP_FLAG:-"false"}
P_PAC_FLAG=${P_PAC_FLAG:-""}
P_SS_FLAG=${P_SS_FLAG:-""}
P_LOCAL_FLAG=${P_LOCAL_FLAG:-""}
P_SOCKS_PROXY=${P_SOCKS_PROXY:-""}

while getopts "s:m:k:e:x:p:q:r:t:u:v" OPT; do
    case $OPT in
        s)
            SS_CONFIG=$OPTARG;;
        m)
            SS_MODULE=$OPTARG;;
        k)
            KCP_CONFIG=$OPTARG;;
        e)
            KCP_MODULE=$OPTARG;;
        x)
            KCP_FLAG=$OPTARG;;
        p)
            P_PAC_FLAG=$OPTARG;;
        r)
            P_SS_FLAG=$OPTARG;;
        u)
            P_LOCAL_FLAG=$OPTARG;;
        v)
            P_SOCKS_PROXY=$OPTARG;;
    esac
done

export SS_CONFIG=${SS_CONFIG}
export SS_MODULE=${SS_MODULE}
export KCP_CONFIG=${KCP_CONFIG}
export KCP_MODULE=${KCP_MODULE}
export KCP_FLAG=${KCP_FLAG}
export P_PAC_FLAG=${P_PAC_FLAG}
export P_SS_FLAG=${P_SS_FLAG}
export P_LOCAL_FLAG=${P_LOCAL_FLAG}
export P_SOCKS_PROXY=${P_SOCKS_PROXY}

echo ${SS_CONFIG} >> a.txt
echo ${SS_MODULE} >> a.txt
echo ${KCP_CONFIG} >> a.txt
echo ${KCP_MODULE} >> a.txt
echo ${KCP_FLAG} >> a.txt
echo ${P_PAC_FLAG} >> a.txt
echo ${P_SS_FLAG} >> a.txt
echo ${P_LOCAL_FLAG} >> a.txt
echo ${P_SOCKS_PROXY} >> a.txt

exec runsvdir -P /etc/service
