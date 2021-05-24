#!/bin/sh
# MicroCap Functions Library
# Victor Oliveira <victor.oliveira@sada.com.br>

# Changelog
# v1.1 - 24/05/2021 09:29 - Victor Oliveira
# - Corrigido problema de ordem nos modais de
#   bloqueio e desbloqueio


VERSION="1.1"


getStations() {
    iw wlan0 station dump | \
    grep -Eio "([a-f0-9]{2}:){5}[a-f0-9]{2}"
}

getIp() {
    # 1: Mac address
    grep -i "${1}" "/tmp/dhcp.leases" | \
    cut -d" " -f3
}

getId() {
    # 1: Mac address
    grep -i "${1}" "/tmp/dhcp.leases" | \
    cut -d" " -f3 | \
    cut -d"." -f4
}

getHostname() {
    # 1: Mac address
    grep -i "${1}" "/tmp/dhcp.leases" | \
    cut -d" " -f4
}

urlDecode() {
    uhttpd -d "${1}"
}

postProcess() {
    read POST_RAW

    local POST_DATA=$(urlDecode "${POST_RAW}")
    local ACTION=$(echo "${POST_DATA}" | sed "s/.*action=\([^&]*\).*$/\1/")
    
    case "${ACTION}" in
        "blockHost")
            local MAC=$(echo "${POST_DATA}" | sed "s/.*mac=\([^&]*\).*$/\1/")
        
            blockHost "${MAC}" && {
                RESULT="0"
                MSG="ID <strong>$(getId ${MAC})</strong> bloqueado"
                return
            }
            ;;
        
        "unblockHost")
            local MAC=$(echo "${POST_DATA}" | sed "s/.*mac=\([^&]*\).*$/\1/")
            local TIME=$(echo "${POST_DATA}" | sed "s/.*time=\([^&]*\).*$/\1/")
        
            unblockHost "${MAC}" "${TIME}" && {
                RESULT="0"
                MSG="ID <strong>$(getId ${MAC})</strong> desbloqueado por $(timeFormat ${TIME})"
                return
            }
            ;;
        
        "ssidUpdate")
            local SSID=$(echo "${POST_DATA}" | sed "s/.*ssid=\([^&]*\).*$/\1/")

            test "${SSID}" = "$(getSsid)" && {
                RESULT="1"
                MSG="O nome <strong>\"${SSID}\"</strong> já está configurado"
                return
                } || { 
                    ssidUpdate "${SSID}" && {
                        RESULT="0"
                        MSG="SSID alterado para <strong>\"${SSID}\"</strong>"
                        return
                    }
                }
    esac

    MSG="Ocorreu um erro"
    RESULT="1"
}

timeFormat() {
    # 1: Minutes
    test "${1}" -gt "60" && {
        local MIN=$((${1} % 60))
        local HOUR=$((${1} / 60))
        
        test "${MIN}" -eq "0" && {
            echo "${HOUR}h"
        } || {
            echo "${HOUR}h e ${MIN}min"
        }
    } || {
        echo "${1}min"
    }
}

remainingTime() {
    # 1: Mac address
    local TMP=$(iptables -t mangle -S PREROUTING | grep -i "${1}" 2> /dev/null)
    
    test -n "${TMP}" && { 
        local LEASE=$(echo "${TMP}" | grep -Eo "comment [0-9]+" | cut -d" " -f2)
        local MINUTES=$((($(date -d@${LEASE} +%s) - $(date +%s)) / 60))

        timeFormat "${MINUTES}"
    } || {
        echo "-"
    }
}

checkHostStatus() {
    # 1: Mac address
    iptables -t mangle -S PREROUTING | \
    grep -i "${1}" &> /dev/null && {
        return 0
    } || {
        return 1
    }
}

unblockHost() {
    # 1: Mac address
    # 2: Time in minutes
    iptables -t mangle -n -L PREROUTING | \
    grep -i "${1}" || {
        iptables -t mangle -I PREROUTING -m comment --comment "$(date -d@$(($(date +%s) + ${2} * 60)) +%s)" \
            -m mac --mac-source "${1}" -j INTERNET
    }
}

blockHost() {
    # 1: Mac address
    local RULE_NUMBER=$(iptables --line-numbers -t mangle -n -L PREROUTING | grep -i "${1}" | cut -d" " -f1)

    iptables -t mangle -D PREROUTING "${RULE_NUMBER}"
}

ssidUpdate() {
    # 1: SSID name
    uci set wireless.AP.ssid="${1}" && {
        uci commit && {
            wifi
        }
    }
}

isWifiHost() {
    echo "${REMOTE_ADDR}" \
    | grep "$(uci get network.ap.ipaddr \
    | cut -d"." -f1-3)" &> /dev/null && {
        return 0
    } || {
        return 1
    }
}

getSsid() {
    uci get wireless.AP.ssid
}