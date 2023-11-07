https://viblo.asia/p/database-replication-with-docker-mysql-images-rails-application-bWrZnxRw5xw

'docker exec -it master mysql -uroot -prootpassword\
-e "INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';"\
-e "SET GLOBAL rpl_semi_sync_master_enabled = 1;"\
-e "SET GLOBAL rpl_semi_sync_master_wait_for_slave_count = 2;"\
-e "SHOW VARIABLES LIKE 'rpl_semi_sync%';"'

docker exec -it master mysql -uroot -prootpassword\
-e "CREATE USER 'repl'@'%' IDENTIFIED BY 'slavepass';"\
-e "GRANT REPLICATION SLAVE ON _._ TO 'repl'@'%';"\
-e "SHOW MASTER STATUS;"

for N in 1 2 do docker exec -it slave$N mysql -uroot -prootpassword\
-e "INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';"\
-e "SET GLOBAL rpl_semi_sync_slave_enabled = 1;"\
-e "SHOW VARIABLES LIKE 'rpl_semi_sync%';" done

for N in 1 2 do docker exec -it slave$N mysql -uroot -prootpassword\
-e "CHANGE MASTER TO MASTER_HOST='master', MASTER_USER='repl',\
MASTER_PASSWORD='rootpassword', MASTER_LOG_FILE='mysql-bin-1.000003';"

docker exec -it slave$N mysql -uroot -pmypass -e "START SLAVE;" done

docker exec -it slave1 mysql -uroot -prootpassword -e "SHOW SLAVE STATUS\G"

docker exec -it master mysql -uroot -prootpassword\
-e "INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';"\
-e "SET GLOBAL rpl_semi_sync_master_enabled = 1;"\
-e "SET GLOBAL rpl_semi_sync_master_wait_for_slave_count = 2;"\
-e "SHOW VARIABLES LIKE 'rpl_semi_sync%';"
