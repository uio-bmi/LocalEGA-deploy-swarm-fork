#!/bin/bash

source variables.sh

mkcert -install
mkcert db vault public-mq private-mq
mkcert -client db vault public-mq private-mq

docker swarm init
docker config create rootCA.pem "$(mkcert -CAROOT)/rootCA.pem"
docker config create server.pem db+3.pem
docker config create server-key.pem db+3-key.pem
docker config create client.pem db+3-client.pem
docker config create client-key.pem db+3-client-key.pem

echo "${KEY_PASSWORD}" > ega.sec.pass
crypt4gh -g ega -kf crypt4gh -kp "${KEY_PASSWORD}"
docker config create ega.sec ega.sec.pem
docker config create ega.sec.pass ega.sec.pass
docker config create ega.pub ega.pub.pem

perl -i.bak -pe 's!MINIO_ACCESS_KEY!$ENV{"MINIO_ACCESS_KEY"}!g' default.conf.ini
perl -i.bak -pe 's!MINIO_SECRET_KEY!$ENV{"MINIO_SECRET_KEY"}!g' default.conf.ini
perl -i.bak -pe 's!DB_HOST!$ENV{"DB_HOST"}!g' default.conf.ini
perl -i.bak -pe 's!DB_LEGA_IN_PASSWORD!$ENV{"DB_LEGA_IN_PASSWORD"}!g' default.conf.ini
perl -i.bak -pe 's!MQ_CONNECTION!$ENV{"MQ_CONNECTION"}!g' default.conf.ini
cat default.conf.ini
docker config create conf.ini default.conf.ini