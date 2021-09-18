#!/usr/bin/env bash

# Python3 needs LC_ALL and LANG set. This is not the case if you start this script over cron or ssh.
export LC_ALL=de_DE.UTF-8
export LANG=de_DE.UTF-8

# Change to the Script dir.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ -f "../application.conf" ]; then
  echo "Warning!!! This is a Production System"
  export "SETTINGS"=../../application.conf
else
    if [ ! -f "./local.cfg" ]; then
        echo "There is no local config file. Please edit local.cfg and rerun this Script!"
	    cp config.tpl local.cfg
        exit 1
    fi
fi

if [ ! -d "./env" ]; then
    echo "\nSetup VirtualEnv\n"
    python -m venv env;. env/bin/activate; pip install -r requirements.txt; pip install pipreqs broker-cli
fi

source "./env/bin/activate"

export SETTINGS=../local.cfg
export FLASK_ENV=development
export FLASK_APP=application

case "$1" in
        flask) flask "${@:2}"
            ;;
        broker) broker "${@:2}"
            ;;
        freeze) pipreqs --force ./
            ;;
        *) echo "Use one of the following args: flask, broker, freeze"
            ;;
esac
