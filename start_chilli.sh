#!/bin/bash

# parsing values

CHILLI=/etc/chilli
localFile="$CHILLI/local.conf"
defaultFile="$CHILLI/defaults"


getopt --test > /dev/null
if [[ $? != 4 ]]; then
  echo "`getopt --test` failed in this environment. stopping here"
  exit 1
fi

SHORT=lDd
LONG=local,default,debug

PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
if [[ $? != 0 ]]; then
  exit 2
fi

eval set -- "$PARSED"
while true; do
  case "$1" in
    -l|--local)
      localFile="$2"
      shift 2
      ;;
    -D|--default)
      defaultFile="$2"
      shift 2
      ;;
    -d|--debug)
      d=y
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Programming error"
      exit 3
      ;;
  esac
done
echo "localConf path: $localFile, defaultFile path: $defaultFile, debug: $d"
cp $defaultFile $CHILLI/defaults
cp $localFile $CHILLI/local.conf
. /etc/chilli/functions

writeconfig
OPTS="--fg"

if [[ $d ]]; then
  OPTS= $OPTS + " --debug"
fi
echo "options for chilli: $OPTS"

/usr/sbin/chilli $OPTS
