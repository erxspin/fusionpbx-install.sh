#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh
. ./resources/environment.sh

# removes the cd img from the /etc/apt/sources.list file (not needed after base install)
#sed -i '/cdrom:/d' /etc/apt/sources.list

#Update to latest packages
verbose "Update installed packages"
pkg upgrade

#PF - Packet Filter
resources/pf.sh

#FusionPBX
resources/fusionpbx.sh

#NGINX web server
resources/nginx.sh

#PHP
resources/php.sh

#Fail2ban
#resources/fail2ban.sh

#FreeSWITCH
resources/switch.sh

#Postgres
resources/postgres.sh

#set the ip address
server_address=$(hostname -I)

#restart services
if [ ."$php_version" = ."5" ]; then
        service php5-fpm restart
fi
if [ ."$php_version" = ."7" ]; then
        service php7.0-fpm restart
fi
service nginx restart
service fail2ban restart

#add the database schema, user and groups
resources/finish.sh
