-- Create normal user
CREATE USER 'mylibrarian'@'%' IDENTIFIED BY 'librarianPass';
GRANT ALL PRIVILEGES ON *.* TO 'mylibrarian'@'%' WITH GRANT OPTION;

-- Create replication user
CREATE USER 'repluser'@'%' IDENTIFIED BY 'replpassword';

-- Grant replication privileges to the user
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'%';

-- Enable master-to-master replication on db1
CHANGE MASTER TO
  MASTER_HOST = '192.168.100.156',
  MASTER_PORT = 3306,
  MASTER_USER = 'repluser',
  MASTER_PASSWORD = 'replpassword',
  MASTER_AUTO_POSITION = 1;

-- Enable master-to-master replication on db2
SET @@GLOBAL.read_only = ON;
CHANGE MASTER TO
  MASTER_HOST = '192.168.100.155',
  MASTER_PORT = 3306,
  MASTER_USER = 'repluser',
  MASTER_PASSWORD = 'replpassword',
  MASTER_AUTO_POSITION = 1;

-- Start replication
START SLAVE;
SET @@GLOBAL.read_only = OFF;
