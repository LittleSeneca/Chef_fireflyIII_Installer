#
# Cookbook:: firefly_iii
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

# Install Dependancies Stack
apt_repository 'php' do
    uri 'ppa:ondrej/php'
end

apt_repository 'mariadb' do
    uri 'http://mariadb.mirror.globo.tech/repo/10.5/ubuntu'
    distribution 'focal main'
    key 'https://mariadb.org/mariadb_release_signing_key.asc'
    action :add
end


apt_update 'update' do
    ignore_failure true
    action :update
end

apt_package %w(git nginx curl software-properties-common mariadb-server mariadb-client) do
    action :install
end

apt_package %w(php7.3 php7.3-cli php7.3-zip php7.3-gd php7.3-fpm php7.3-json php7.3-common php7.3-mysql php7.3-zip php7.3-mbstring php7.3-curl php7.3-xml php7.3-bcmath php7.3-imap php7.3-ldap php7.3-intl) do
    action :install
end

# Configure PHP
template '/etc/php/7.3/fpm/php.ini' do 
   source 'php.erb' 
   variables( 
      memory_limit: '512M', 
      date_timezone: 'America/Los_Angeles', 
   ) 
end

service 'apache2' do
  action [:disable, :stop]
end

# Configure NGINX
template '/etc/nginx/sites-enabled/firefly.conf' do 
   source 'firefly.erb' 
   variables( 
      server_name: 'budget.brooksnet.lan', 
   ) 
end

file '/etc/nginx/sites-enabled/default' do
    action :delete
end

service 'nginx' do
    action :restart
end

service 'php7.3-fpm' do
    action :restart
end

# Configure SQL Server
bash 'install_mysql_database' do
    code <<-EOC
        mysql -e "CREATE DATABASE firefly_database"
        mysql -e "CREATE USER 'fireflyuser'@'localhost' IDENTIFIED BY 'StrongPassword'"
        mysql -e "GRANT ALL PRIVILEGES ON firefly_database. * TO 'fireflyuser'@'localhost'"
        mysql -e 'FLUSH PRIVILEGES;'
    EOC
end

# Install Composer
bash "install Composer" do
    code <<-EOC
        cd /tmp/
        curl -sS https://getcomposer.org/installer -o composer-setup.php
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    EOC
    action :run
end

# Install FireFly
bash "install Firefly" do
    code <<-EOC
        cd /var/www/html/
        composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii 5.2.8
        chown -R www-data:www-data firefly-iii
        chmod -R 775 firefly-iii/storage
    EOC
    action :run
end

# Configure FireFly
template '/var/www/html/firefly-iii/.env' do
    source 'env.erb'
    action :create
end

# Initialize FireFly
bash 'initialize FireFly' do
    code <<-EOH
        cd /var/www/html/firefly-iii
        php artisan migrate:refresh --seed
        php artisan firefly-iii:upgrade-database
        php artisan passport:install
        apt-get install -y language-pack-nl-base
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
        locale-gen
    EOH
    action :run
end
reboot 'reboot configuration' do
    action :request_reboot
    reason 'Configuration requires a reboot'
    delay_mins 0
end

