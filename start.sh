docker network create replicanet

docker run -d --name=master --net=replicanet --hostname=master -p 3308:3306 \
  -v $PWD/d0:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypass \
  mysql/mysql-server:5.7 \
  --server-id=1 \
  --log-bin='mysql-bin-1.log'

docker run -d --name=slave1 --net=replicanet --hostname=slave1 -p 3309:3306 \
  -v $PWD/d1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypass \
  mysql/mysql-server:5.7 \
  --server-id=2

docker run -d --name=slave2 --net=replicanet --hostname=slave2 -p 3310:3306 \
  -v $PWD/d2:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypass \
  mysql/mysql-server:5.7 \
  --server-id=3


# Note update
mysql -u root -pmypass

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'mypass' WITH GRANT OPTION;
FLUSH PRIVILEGES;

docker exec -it master mysql -uroot -pmypass \
  -e "INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';" \
  -e "SET GLOBAL rpl_semi_sync_master_enabled = 1;" \
  -e "SET GLOBAL rpl_semi_sync_master_wait_for_slave_count = 2;" \
  -e "SHOW VARIABLES LIKE 'rpl_semi_sync%';"

docker exec -it master mysql -uroot -pmypass \
  -e "CREATE USER 'repl'@'%' IDENTIFIED BY 'slavepass';" \
  -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';" \
  -e "SHOW MASTER STATUS;"

for N in 1 2
  do docker exec -it slave$N mysql -uroot -pmypass \
    -e "INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';" \
    -e "SET GLOBAL rpl_semi_sync_slave_enabled = 1;" \
    -e "SHOW VARIABLES LIKE 'rpl_semi_sync%';"
done

MASTER_LOG_FILE='mysql-bin-1.000003'

for N in 1 2
  do docker exec -it slave$N mysql -uroot -pmypass \
    -e "CHANGE MASTER TO MASTER_HOST='master', MASTER_USER='repl', \
      MASTER_PASSWORD='slavepass', MASTER_LOG_FILE='mysql-bin-1.000003';"

  docker exec -it slave$N mysql -uroot -pmypass -e "START SLAVE;"
done

docker exec -it slave1 mysql -uroot -pmypass -e "SHOW SLAVE STATUS\G"
docker exec -it slave2 mysql -uroot -pmypass -e "SHOW SLAVE STATUS\G"

docker exec -it master mysql -uroot -pmypass -e "CREATE DATABASE TEST; SHOW DATABASES;"

for N in 1 2
  do docker exec -it slave$N mysql -uroot -pmypass \
  -e "SHOW VARIABLES WHERE Variable_name = 'hostname';" \
  -e "SHOW DATABASES;"
done
