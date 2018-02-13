#!/bin/bash


systemctl stop zagruz_api.target
systemctl stop zagruz_auth.target
systemctl stop zagruz_cabinet.target
systemctl stop zagruz_main_www.target

systemctl status zagruz_api.target
systemctl status zagruz_auth.target
systemctl status zagruz_cabinet.target
systemctl status zagruz_main_www.target
