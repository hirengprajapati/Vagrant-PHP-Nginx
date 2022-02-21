#!/usr/bin/env bash

set -o errexit
set -o nounset

export DEBIAN_FRONTEND=noninteractive

echo "Provisioning virtual machine..."

echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8

apt-get update
apt-get install software-properties-common
add-apt-repository ppa:ondrej/php
apt-get update
apt-get upgrade -y

# general packages
apt-get install -y \
  make \
  ntp \
  git \
  vim \
  tmux \
  zip \
  unzip \
  htop \
  nginx \
  supervisor \
  ghostscript \
  gdebi \
  ttf-mscorefonts-installer \
  python-pip

# php packages
apt-get install -y --no-install-recommends \
  php7.4-cli \
  php7.4-fpm \
  php7.4-bcmath \
  php7.4-curl \
  php7.4-gd \
  php7.4-imap \
  php7.4-intl \
  php7.4-mbstring \
  php7.4-mcrypt \
  php7.4-mysql \
  php7.4-soap \
  php7.4-tidy \
  php7.4-xml \
  php7.4-zip \
  php7.4-dev \
  php7.4-mailparse \
  php7.4-xdebug \
  php7.4-apcu

# pdftk packages
apt install -y \
  default-jre-headless \
  libcommons-lang3-java \
  libbcprov-java

curl -Lo /vagrant/pdftk-java_0.0.0+20180723.1-1_all.deb http://launchpadlibrarian.net/383018194/pdftk-java_0.0.0+20180723.1-1_all.deb
dpkg -i /vagrant/pdftk-java_0.0.0+20180723.1-1_all.deb
rm -f /vagrant/pdftk-java_0.0.0+20180723.1-1_all.deb

curl -Lo /vagrant/prince_14.2-1_ubuntu18.04_amd64.deb https://www.princexml.com/download/prince_14.2-1_ubuntu18.04_amd64.deb
gdebi -n /vagrant/prince_14.2-1_ubuntu18.04_amd64.deb
rm -f /vagrant/prince_14.2-1_ubuntu18.04_amd64.deb

pip install xlsx2csv

wget https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64
mv MailHog_linux_amd64 /usr/local/bin/mailhog
chmod 0755 /usr/local/bin/mailhog

curl -Lo /vagrant/wkhtmltox_0.12.6-1.bionic_amd64.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb
gdebi -n /vagrant/wkhtmltox_0.12.6-1.bionic_amd64.deb
rm -f /vagrant/wkhtmltox_0.12.6-1.bionic_amd64.deb

rm -f /usr/bin/php
cp /usr/bin/php7.4 /usr/bin/php

if [ ! -d /var/bak ]; then
    mkdir -p /var/bak
    mv /etc/nginx/nginx.conf /var/bak/nginx.conf
    mv /etc/nginx/sites-available/default /var/bak/default
    mv /etc/php/7.4/cli/php.ini /var/bak/php-cli.ini
    mv /etc/php/7.4/fpm/php.ini /var/bak/php-fpm.ini
    mv /etc/php/7.4/fpm/php-fpm.conf /var/bak/php-fpm.conf
    mv /etc/supervisor/supervisord.conf /var/bak/supervisord.conf
fi

pushd /opt
  wget https://github.com/sass/dart-sass/releases/download/1.32.8/dart-sass-1.32.8-linux-x64.tar.gz
  tar -xf dart-sass-1.32.8-linux-x64.tar.gz
  rm dart-sass-1.32.8-linux-x64.tar.gz
  ln -s /opt/dart-sass/sass /usr/local/bin/sass
popd

pushd /opt
    wget http://www.libxl.com/download/libxl-lin-3.8.3.tar.gz
    tar -xzf libxl-lin-3.8.3.tar.gz
    rm libxl-lin-3.8.3.tar.gz
    #git clone https://github.com/iliaal/php_excel.git
    git clone https://github.com/Jan-E/php_excel.git
    pushd php_excel
        git checkout php7_with_pulls
        phpize
        ./configure \
            --with-excel=../libxl-3.8.3.0 \
            --with-libxl-incdir=../libxl-3.8.3.0/include_c \
            --with-libxl-libdir=../libxl-3.8.3.0/lib64
        make
        make install
    popd
popd

# install email reader component (msgconvert)
# if cpan is not present, install perl-cpan
# execute sudo cpan, and use upgrade command if neccessary
# common issue: versions of msgconvert exist which do not or do accept --output parameter. The output parameter is required
cpan -i Email::Outlook::Message

rm -f /etc/nginx/nginx.conf
rm -f /etc/php/7.4/cli/php.ini
rm -f /etc/php/7.4/fpm/php.ini
rm -f /etc/php/7.4/fpm/php-fpm.conf
rm -f /etc/nginx/common.conf
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/php/7.4/fpm/pool.d/app.conf
rm -f /etc/supervisor/supervisord.conf

cp /vagrant/vm/nginx.conf /etc/nginx/nginx.conf
cp /vagrant/vm/nginx-common.conf /etc/nginx/common.conf
cp /vagrant/vm/nginx-app.conf /etc/nginx/sites-available/app.conf
cp /vagrant/vm/php.ini /etc/php/7.4/php.ini
ln -s /etc/php/7.4/php.ini /etc/php/7.4/cli/php.ini
ln -s /etc/php/7.4/php.ini /etc/php/7.4/fpm/php.ini
cp /vagrant/vm/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
cp /vagrant/vm/php-fpm-pool.conf /etc/php/7.4/fpm/pool.d/app.conf
cp /vagrant/vm/excel.ini /etc/php/7.4/mods-available/excel.ini
cp /vagrant/vm/supervisord.conf /etc/supervisor/supervisord.conf

ln -s /etc/php/7.4/mods-available/excel.ini /etc/php/7.4/cli/conf.d/21-excel.ini
ln -s /etc/php/7.4/mods-available/excel.ini /etc/php/7.4/fpm/conf.d/21-excel.ini
ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
composer install

service php7.4-fpm restart
service nginx restart
service supervisor restart

echo "Finished!"
