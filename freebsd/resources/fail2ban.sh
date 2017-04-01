#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing Fail2ban"

#add the dependencies
pkg install --yes py27-fail2ban

#update the list of executables in the path
rehash

#enable fail2ban service
echo 'fail2ban_enable="YES"' >> /etc/rc.conf

#move the filters
cp fail2ban/freeswitch-dos.conf /usr/local/etc/fail2ban/filter.d/freeswitch-dos.conf
cp fail2ban/freeswitch-ip.conf /usr/local/etc/fail2ban/filter.d/freeswitch-ip.conf
cp fail2ban/freeswitch-404.conf /usr/local/etc/fail2ban/filter.d/freeswitch-404.conf
cp fail2ban/freeswitch.conf /usr/local/etc/fail2ban/filter.d/freeswitch.conf
cp fail2ban/fusionpbx.conf /usr/local/etc/fail2ban/filter.d/fusionpbx.conf
cp fail2ban/nginx-404.conf /usr/local/etc/fail2ban/filter.d/nginx-404.conf
cp fail2ban/nginx-dos.conf /usr/local/etc/fail2ban/filter.d/nginx-dos.conf
cp fail2ban/jail.local /usr/local/etc/fail2ban/jail.local

#update config if source is being used
if [ .$switch_source = .true ]; then
	sed -i' ' -e 's#var/log/freeswitch#usr/local/freeswitch/log#g' /etc/fail2ban/jail.local
fi

#restart fail2ban
service fail2ban restart
