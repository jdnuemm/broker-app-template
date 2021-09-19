#!/usr/bin/env bash

# Python3 needs LC_ALL and LANG set. This is not the case if you start this script over cron or ssh.
export LC_ALL=de_DE.UTF-8
export LANG=de_DE.UTF-8

# Jump to the script dir.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ -f "../application.conf" ]; then
  echo "Warning!!! This is a Production System"
  export "SETTINGS"=../../application.conf
else
    if [ ! -f "./local.cfg" ]; then
        echo "There is no local config file. Please edit local.cfg and rerun this script!"
	    cp config.tpl local.cfg
        exit 1
    fi
fi

if [ ! -d "./python-venv" ]; then
    echo "Setup virtual python environment"
    python -m venv python-venv;. python-venv/bin/activate; pip install --upgrade pip; pip install -r requirements.txt; pip install pipreqs broker-cli
fi

source "./python-venv/bin/activate"

export SETTINGS=../local.cfg
export FLASK_ENV=development
export FLASK_APP=application

BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE=$(git config --get remote.origin.url)
PROJECT=${PWD##*/}

case "$1" in
        flask) flask "${@:2}"
            ;;
        broker) broker "${@:2}"
            ;;
        freeze) pipreqs --force ./
            ;;
        shell) $SHELL
            ;;
        deploy)
            broker dev.blacktre.es develop deploy --domain $BRANCH.$PROJECT.dev.blacktre.es --branch $BRANCH --git_remote $REMOTE
            ;;
        destroy)
            broker dev.blacktre.es develop destroy --domain $BRANCH.$PROJECT.dev.blacktre.es --branch $BRANCH --git_remote $REMOTE
            ;;
        *) echo "Use one of the following args: flask, broker, freeze"
            ;;
esac
