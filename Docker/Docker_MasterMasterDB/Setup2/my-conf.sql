-- Create normal user
CREATE USER 'mylibrarian'@'%' IDENTIFIED BY 'librarianPass';
GRANT ALL PRIVILEGES ON

CREATE USER 'repluser'@'%' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%';

CHANGE MASTER TO
    MASTER_HOST='192.168.100.156',
    MASTER_USER='repluser',
    MASTER_PASSWORD='replpass',
    MASTER_PORT=3306;
    MASTER_AUTO_POSITION = 1;

START SLAVE;
