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

SHORT=l:D:du:p:
LONG=local:,default:,debug,prescript:,upscript:

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
    -p|--prescript)
      preScript="$2"
      shift 2
      ;;
    -u|--upscript)
      upScript="$2"
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

echo "localConf path: $localFile, defaultFile path: $defaultFile, debug: $d, prescript: $preScript, upscript: $upScript"
cp $defaultFile $CHILLI/defaults
cp $localFile $CHILLI/local.conf
. /etc/chilli/functions

writeconfig
OPTS="--fg"

if [[ $preScript ]] && [[ -e $preScript ]]; then
  echo "launching the script $preScript"
  $preScript
fi

if [[ $upScript ]] && [[ -e $upScript ]]; then
  echo "using upscript $upScript in the configuration"
  cp $upScript $CHILLI/up.sh
fi

if [[ $d ]]; then
  OPTS="$OPTS --debug"
fi
echo "options for chilli: $OPTS"

/usr/sbin/chilli $OPTS
