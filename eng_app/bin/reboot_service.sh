#! /bin/bash

sudo systemctl stop eng_app
sleep 1

sudo systemctl start eng_app
sleep 1

sudo watch systemctl status eng_app

