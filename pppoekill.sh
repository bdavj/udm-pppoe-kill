#!/bin/sh
IFACE=eth9

while true; do
  echo Checking link is down
  PPP_LINK=$(ip link show ppp0 | head -1)

  if [ -z "${PPP_LINK}" ]
  then
      echo Getting session ID
    SESSION_ID=$(journalctl _COMM=pppd --output cat | grep session | tail -1 | cut -d' ' -f4)

    if [ -z "${SESSION_ID}" ]
    then
      echo No session ID found.
      exit
    fi

    echo Got session id $SESSION_ID

    echo Getting Remote PPP MAC
    REMOTE_MAC=$(journalctl _COMM=pppd --output cat | grep "peer from calling number" | tail -1 | cut -d' ' -f5)

    if [ -z "${REMOTE_MAC}" ]
    then
      echo No Remote MAC found.
      exit
    fi

    echo Got Remote MAC: $REMOTE_MAC
    echo PPP Link Down. Proceeding to kill.
    python3 /mnt/data/ppp/pppoekill.py --iface $IFACE --session_id $SESSION_ID --remote_mac $REMOTE_MAC
    sleep 120
  else
    echo PPP link is up. not killing.
  fi

  sleep 5
done

