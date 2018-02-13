#!/bin/bash

# systemctl daemon-reload

systemctl restart zagruz_auth.target
systemctl restart zagruz_api.target
systemctl restart zagruz_cabinet.target
systemctl restart zagruz_main_www.target


systemctl status zagruz_api.target
systemctl status zagruz_auth.target
systemctl status zagruz_cabinet.target
systemctl status zagruz_main_www.target
