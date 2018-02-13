#!/bin/bash

# systemctl daemon-reload

systemctl restart zagruz_api.target

systemctl status zagruz_api.target
