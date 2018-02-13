#!/bin/bash

./export/systemd/api.sh
./export/systemd/auth.sh
./export/systemd/cabinet.sh
./export/systemd/main_www.sh

systemctl daemon-reload