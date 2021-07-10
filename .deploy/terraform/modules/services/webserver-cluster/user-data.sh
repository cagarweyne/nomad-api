#!/bin/bash 
docker run --log-driver=awslogs --log-opt awslogs-group=docker-logs -d -e SECRET_KEY='${SECRET_KEY}' \
-e DB_ADDRESS='${DB_ADDRESS}' -e DB_PORT='${DB_PORT}' -e DB_NAME='${DB_NAME}' -e WEB_APP_URL='${WEB_APP_URL}' \
-e WEB_HOOK_SECRET='${WEB_HOOK_SECRET}' -e GOOGLE_APPLICATION_CREDENTIALS='${GOOGLE_APPLICATION_CREDENTIALS}' \
-p ${server_port}:${server_port} cagarweyne/nomad 