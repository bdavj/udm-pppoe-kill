#!/bin/sh
IFACE=eth9

FILE_SESSION=/mnt/data/session
FILE_MAC=/mnt/data/mac


decho() {
  #echo $@
  null=1
 }


  #$1 File
  #$2 Value
  # Return Value
get_or_write()
{
  if [ -f "$1" ]; then
      decho "$1 exists."
      FILE_VALUE=$(cat "$1")
      if [ -z $2 ]; then
        decho "File present variable empty. $FILE_VALUE"
        retval="$FILE_VALUE"
       elif [ $FILE_VALUE = $2 ]; then
        decho "File is the same as value provided"
        retval="$FILE_VALUE"
      else
        decho "Updating file."
        echo $2 > $1
        retval="$2"
       fi
  else
      decho "$1 does not exist."
      echo $2 > $1
      retval="$2"
  fi
}


while true; do
  sleep 15
  decho Checking link is down
  PPP_LINK=$(ip link show ppp0 | grep POINTOPOINT | head -1)

  SESSION_ID=$(journalctl _COMM=pppd --output cat | grep session | tail -1 | cut -d' ' -f4)
  unset retval
  get_or_write $FILE_SESSION "$SESSION_ID"
  SESSION_ID=$retval

    if [ -z "${SESSION_ID}" ]
    then
      echo No session ID found.
      continue
    fi

    REMOTE_MAC=$(journalctl _COMM=pppd --output cat | grep "peer from calling number" | tail -1 | cut -d' ' -f5)
    unset retval
    get_or_write $FILE_MAC "$REMOTE_MAC"
    REMOTE_MAC=$retval

    if [ -z "${REMOTE_MAC}" ]
    then
      echo No Remote MAC found.
      continue
    fi

  if [ -z "${PPP_LINK}" ]
  then

    echo "Got Remote MAC / Session ID: $REMOTE_MAC $SESSION_ID"
    echo PPP Link Down. Proceeding to kill.
    python3 /mnt/data/ppp/pppoekill.py --iface $IFACE --session_id $SESSION_ID --remote_mac $REMOTE_MAC
    sleep 30
  else
    decho PPP link is up. not killing.
  fi



done

