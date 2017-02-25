#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

#send a message
verbose "Installing the web server"

arch=$(uname -m)
real_os=$(lsb_release -is)
codename=$(lsb_release -cs)
if [ .$USE_SWITCH_PACKAGE_UNOFFICIAL_ARM = .true ]; then
        #9.x - */stretch/
        #8.x - */jessie/
        if [ .$codename = .'jessie' ]; then
                USE_PHP5_PACKAGE = true
        fi
fi
if [ .$USE_PHP5_PACKAGE = .true ]; then
        #don't add php7.0 repository
        verbose "Switching forcefully to php5* packages"
elif [ .$real_os = .'Ubuntu' ]; then
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ .$codename = .'trusty' ]; then
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
else
        #9.x - */stretch/
        #8.x - */jessie/
        if [ .$codename = .'jessie' ]; then
                echo "deb http://packages.dotdeb.org $codename all" > /etc/apt/sources.list.d/dotdeb.list
                echo "deb-src http://packages.dotdeb.org $codename all" >> /etc/apt/sources.list.d/dotdeb.list
                wget -O - https://www.dotdeb.org/dotdeb.gpg | apt-key add -
        fi
fi
apt-get update

#install dependencies
apt-get install -y nginx
if [ .$USE_PHP5_PACKAGE = .true ]; then
        apt-get install -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-mcrypt
else
        apt-get install -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-mcrypt php7.0-xml
fi

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx
#prepare socket name
if [ .$USE_PHP5_PACKAGE = .true ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php5-fpm.sock;#g'
else
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.0-fpm.sock;#g'
fi
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#self signed certificate
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
rm /etc/nginx/sites-enabled/default

#add the letsencrypt directory
mkdir -p /var/www/letsencrypt/

#restart nginx
service nginx restart
