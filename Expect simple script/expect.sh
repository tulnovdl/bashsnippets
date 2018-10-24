#!/usr/bin/expect -f

        set timeout 20

        set IPaddress 10.1.1.1

        set Username "login"

        set Password "pass"

        log_file -a /usr/lib/zabbix/externalscripts/wifi-restart/expect_log.log

        send_log "### /START-SSH-SESSION/ IP: $IPaddress @ [exec date] ###\r"

        spawn ssh -o "StrictHostKeyChecking no" $Username@$IPaddress

        expect *ser*

        send "$Username\r"

	expect *assword

	send "$Password\r"

        expect "#"

        send "conf t\r"

        expect "(config)#"

        send "int rang gi7-16\r"

        expect "(config-if-range)#"

        send "power inline never\r"

        expect "(config-if-range)#"

        sleep 5

        send "power inline auto\r"

        expect "(config)#"

        send "exit"

        expect "(config)#"

        send "exit\r"

        expect "#"

        send "exit\r"

        sleep 1

        send_log "\r### /END-SSH-SESSION/ IP: $IPaddress @ [exec date] ###\r"
exit