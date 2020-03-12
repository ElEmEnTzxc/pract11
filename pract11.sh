#!/bin/bash
set -x

# Actualizamos los repositorios
apt-get update

# Instalamos apache2 
apt-get install apache2 -y

# Instalamos paquetes para apache
apt-get install php libapache2-mod-php php-mysql -y

# Instalamos adminer
cd /var/www/html
mkdir adminer
cd adminer
wget https://github.com/vrana/adminer/releases/download/v4.3.1/adminer-4.3.1-mysql.php
mv adminer-4.3.1-mysql.php index.php

# Instalamos git
apt-get install git -y

# Instalación de php-fpm y php-mysql
apt-get install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
apt-get install php-fpm php-mysql -y


# Configuración de php-fpm
cd /etc/php/7.2/fpm/
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' php.ini

# Descargamos Wordpress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz

# Descomprimimos el archivo recién descargado
tar -zxvf latest.tar.gz

# Modificamos el archivo wp-config-example.php donde metemos la ip del mysql y tambien movemos los archivos de la carpeta wordpress dentro de la carpeta /var/www/html
mv /var/www/html/wordpress/* /var/www/html
mv wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/' wp-config.php
sed -i 's/username_here/wordpress/' wp-config.php
sed -i 's/password_here/wordpress/' wp-config.php
sed -i 's/localhost/52.1.8.148/' wp-config.php

# Concedemos permisos a Wordpress
chown www-data:www-data * -R


# Creamos uploads
mkdir /var/www/html/wp-content/uploads -p

# Security Keys
cd /var/www/html
rm -r index.html

# Borramos todas las keys que ahy dentro del archivo wp-config.php
sed -i '/AUTH_KEY/d' wp-config.php
sed -i '/LOGGED_IN_KEY/d' wp-config.php
sed -i '/NONCE_KEY/d' wp-config.php
sed -i '/AUTH_SALT/d' wp-config.php
sed -i '/SECURE_AUTH_SALT/d' wp-config.php
sed -i '/LOGGED_IN_SALT/d' wp-config.php
sed -i '/NONCE_SALT/d' wp-config.php

#Añadimos las keys en nuestro archivo wp-config.php
CLAVES=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
CLAVES=$(echo $CLAVES | tr / _)
sed -i "/#@-/a $CLAVES" /var/www/html/wp-config.php
