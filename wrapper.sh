#!/bin/bash

## Refresh config
cp -R /opt/postal/config-original/* /opt/postal/config

## Generate keys
/opt/postal/bin/postal initialize-config

if [[ $(cat /opt/postal/config/postal.yml| grep -i web_server |wc -l) == 0 ]]; then
cat >> /opt/postal/config/postal.yml << EOF
web_server:
  bind_address: 0.0.0.0
EOF
fi

sed -i -e '/web:/!b' -e ':a' -e "s/  host.*/  host: $HOST_NAME/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
## Set MySQL/RabbitMQ usernames/passwords
### MySQL Main DB
sed -i -e '/main_db:/!b' -e ':a' -e "s/host.*/host: mysql/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e'/main_db:/!b' -e ':a' -e "s/username.*/username: root/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e'/main_db:/!b' -e ':a' -e "s/password.*/password: $MYSQL_ROOT_PASSWORD/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e'/main_db:/!b' -e ':a' -e "s/  database.*/  database: $MYSQL_DATABASE/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
### MySQL Message DB
sed -i -e '/message_db:/!b' -e ':a' -e "s/host.*/host: mysql/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e'/message_db:/!b' -e ':a' -e "s/username.*/username: root/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e'/message_db:/!b' -e ':a' -e "s/password.*/password: $MYSQL_ROOT_PASSWORD/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
### RabbitMQ
sed -i -e '/rabbitmq:/!b' -e ':a' -e "s/host.*/host: rabbitmq/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/rabbitmq:/!b' -e ':a' -e "s/username.*/username: $RABBITMQ_DEFAULT_USER/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/rabbitmq:/!b' -e ':a' -e "s/password.*/password: $RABBITMQ_DEFAULT_PASS/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/rabbitmq:/!b' -e ':a' -e "s/vhost.*/vhost: \/$RABBITMQ_DEFAULT_VHOST/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
### DNS
sed -i -e '/dns:/!b' -e ':a' -e "s/  smtp_server_hostname.*/  smtp_server_hostname: $DNS_SMTP_SERVER_HOSTNAME/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/dns:/!b' -e ':a' -e "s/  spf_include.*/  spf_include: $DNS_SPF_INCLUDE/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/dns:/!b' -e ':a' -e "s/  return_path.*/  return_path: $DNS_RETURN_PATH/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/dns:/!b' -e ':a' -e "s/  route_domain.*/  route_domain: $DNS_ROUTE_PATH/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/dns:/!b' -e ':a' -e "s/  track_domain.*/  track_domain: $DNS_TRACK_DOMAIN/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml
sed -i -e '/mx_records:/!b' -e ':a' -e "s/  -.*/  - $DNS_MX_RECORD/;t trail" -e 'n;ba' -e ':trail' -e 'n;btrail' /opt/postal/config/postal.yml

## Clean Up
rm -rf /opt/postal/tmp/pids/*

## Wait for MySQL to start up
echo "== Waiting for MySQL to start up =="
while ! mysqladmin ping -h mysql --silent; do
    sleep 0.5
done

## Start Postal
/opt/postal/bin/postal "$@"
