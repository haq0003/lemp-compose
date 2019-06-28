<VirtualHost *:80>
    ServerName [[DOMAIN]]
    ServerAlias [[DOMAIN]]

    DocumentRoot /var/www/public/web
    <Directory /var/www/public/web>
        AllowOverride All
        Order Allow,Deny
        Allow from All
    </Directory>

    ErrorLog /var/log/apache2/myapp-error.log
    CustomLog /var/log/apache2/myapp-access.log combined
</VirtualHost>
