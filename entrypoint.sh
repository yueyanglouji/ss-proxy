#!/bin/bash

SS_CONFIG=${SS_CONFIG:-""}
SS_MODULE=${SS_MODULE:-"ss-server"}
KCP_CONFIG=${KCP_CONFIG:-""}
KCP_MODULE=${KCP_MODULE:-"kcpserver"}
KCP_FLAG=${KCP_FLAG:-"false"}
POLIPO_CONFIG=${POLIPO_CONFIG:-""}
SQUID_FLAG=${SQUID_FLAG:-"false"}

while getopts "s:m:k:e:x:p:z:" OPT; do
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
            KCP_FLAG="true";;
		p)
		    POLIPO_CONFIG=$OPTARG;;
		z)
            SQUID_FLAG="true";;
    esac
done

export SS_CONFIG=${SS_CONFIG}
export SS_MODULE=${SS_MODULE}
export KCP_CONFIG=${KCP_CONFIG}
export KCP_MODULE=${KCP_MODULE}
export KCP_FLAG=${KCP_FLAG}
export POLIPO_CONFIG=${POLIPO_CONFIG}
export SQUID_FLAG=${SQUID_FLAG}

exec runsvdir -P /etc/service
