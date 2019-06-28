workspace:
    build: ./workspace
    restart: always
    volumes:
        - ./web/:/var/www
        - ./web/.ssh:/home/web[[WEB_ID]]/.ssh
        - ./web/profile:/home/web[[WEB_ID]]/profile
        - ./web/logs/access.log:/var/log/apache2/myapp-access.log
        - ./web/logs/error.log:/var/log/apache2/myapp-error.log
        - ./web/apache2/app.conf:/etc/apache2/sites-enabled/app.conf
        - ./web/public:/var/www/public

    privileged: true
    tty: true
    ports:
        - '[[USER_ID]]22:22'
        - '[[USER_ID]]80:80'
    links:
        - mysql

mysql:
    image: 'mariadb'
    restart: always
    volumes:
        - ./web/db-data:/var/lib/mysql
    environment:
        - MYSQL_ROOT_PASSWORD=[[ROOT_PASS]]

phpmyadmin:
    image: 'phpmyadmin/phpmyadmin'
    hostname: phpmyadmin
    restart: always
    ports:
       - '[[USER_ID]]81:80'
    links:
        - mysql:mysql
    environment:
        MYSQL_USERNAME: root
        MYSQL_ROOT_PASSWORD: [[ROOT_PASS]]
        PMA_HOST: mysql