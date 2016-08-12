#!/usr/bin/env bash

# Restart serviços Apache & MySql
# ---------------------------------
sudo service apache2 restart
sudo service mysql restart


# Start mailcatcher
# ---------------------------------
mailcatcher

