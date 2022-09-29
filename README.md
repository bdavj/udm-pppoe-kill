# udm-pppoe-kill
Many providers enforce long PPPoE timeout delays. This can be hours in some cases, and can result in the inability to reconnect after an unclean clear-down on the PPPoE session.
Unfortunately, routers such as the UDM drop the PPPoE session without a clean disconnect for just about any configuration change.

# Compatible devices
This has been tested on UDM-SE devices. If anyone is able to verify on other devices such as USG, UDM-PRO/BASE please do post an issue to update the compatibility list with the result, positive or negative.

# Operation

The script scrapes the journal for the most recent PPPoE session ID, and remote peer. It then issues a PPPoE PADT packet (Force disconnect) to clear the stale session. 
The router is then able to re-establish a PPPoE session.


# Installation

Drop the contents repo into `/mnt/data/ppp`. Copy the `pppoekill.sh` script to `/mnt/data/on_boot`

Alternatively:
```
mkdir /mnt/data/ppp
curl -Lo /mnt/data/on_boot.d/pppoekill.sh https://raw.githubusercontent.com/bdavj/udm-pppoe-kill/main/pppoekill.sh
curl -Lo /mnt/data/ppp/pppoekill.py https://raw.githubusercontent.com/bdavj/udm-pppoe-kill/main/pppoekill.py
chmod +x /mnt/data/on_boot.d/pppoekill.sh
```

The script will run on next boot, or you could start it with

```
nohup /mnt/data/on_boot.d/pppoekill.sh &
```

Once installed, change the interface at the top of `/mnt/data/on_boot.d/pppoekill.sh` to your required WAN interface.
By default, this is set to eth9 (SFP WAN on a UDM-SE).

# Contributing
Pull requests are welcome, or if there is a case in which the tool doesn't work, please do open an issue.