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
            KCP_FLAG=$OPTARG;;
        p)
            POLIPO_CONFIG=$OPTARG;;
        z)
            SQUID_FLAG=$OPTARG;;
    esac
done

export SS_CONFIG=${SS_CONFIG}
export SS_MODULE=${SS_MODULE}
export KCP_CONFIG=${KCP_CONFIG}
export KCP_MODULE=${KCP_MODULE}
export KCP_FLAG=${KCP_FLAG}
export POLIPO_CONFIG=${POLIPO_CONFIG}
export SQUID_FLAG=${SQUID_FLAG}

echo ${SS_CONFIG} >> a.txt
echo ${SS_MODULE} >> a.txt
echo ${KCP_CONFIG} >> a.txt
echo ${KCP_MODULE} >> a.txt
echo ${KCP_FLAG} >> a.txt
echo ${POLIPO_CONFIG} >> a.txt
echo ${SQUID_FLAG} >> a.txt

if [ "${SS_MODULE}" == "ss-local" ]; then
    echo "starting polipo..."
    if [ -n "${POLIPO_CONFIG}" ]; then
        chpst -u polipo polipo ${POLIPO_CONFIG}
    else
        chpst -u polipo polipo -c /etc/polipo.conf
    fi
	echo "polipo started!"
else
    echo "INFO: SS_MODULE is ${SS_MODULE}, not run polipo!"
fi

if [ "${SQUID_FLAG}" == "true" ]; then
    if [ "${SS_MODULE}" == "ss-local" ]; then
        echo "starting squid..."
        chpst -u root squid
		echo "squid started!"
    else
        echo "INFO: SS_MODULE is ${SS_MODULE}, not run squid!"
    fi
fi

exec runsvdir -P /etc/service
