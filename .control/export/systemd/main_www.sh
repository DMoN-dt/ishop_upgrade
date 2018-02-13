#!/bin/bash

SERVICE_NAME=main_www
PROJECT_NAME=zagruz
USER_NAME=depuser

EXPORT_TEMPLATE=systemd
EXPORT_DIR=/etc/systemd/system

PROJECT_PARENT_DIR=/home/depuser/web-apps/${PROJECT_NAME}
SERVICE_DIR=${PROJECT_PARENT_DIR}/${SERVICE_NAME}
LOG_DIR=${PROJECT_PARENT_DIR}/.log/${SERVICE_NAME}

cd ${SERVICE_DIR}
bundle install
foreman export -a ${PROJECT_NAME}_${SERVICE_NAME} -f ${SERVICE_DIR}/procfile.dev -l ${LOG_DIR} -u ${USER_NAME} ${EXPORT_TEMPLATE} ${EXPORT_DIR}