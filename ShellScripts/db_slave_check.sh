#!/bin/bash

# Configure your database connection information
DB_HOST="your_database_host"
DB_USER="your_database_user"
DB_PASS="your_database_password"

# Check the replication status
STATUS=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running\|Slave_SQL_Running")

# If both Slave_IO_Running and Slave_SQL_Running are not 'Yes', attempt to fix the replication
if [[ ! $(echo "$STATUS" | grep "Slave_IO_Running: Yes") || ! $(echo "$STATUS" | grep "Slave_SQL_Running: Yes") ]]; then
  # Stop the slave
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "STOP SLAVE;"

  # Start the slave
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "START SLAVE;"
fi
