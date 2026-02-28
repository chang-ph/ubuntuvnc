#!/bin/bash
OUR_IP=$(hostname -i)

# start VNC server (Uses VNC_PASSWD Docker ENV variable)
mkdir -p $HOME/.config/tigervnc && echo "$VNC_PASSWD" | vncpasswd -f >$HOME/.config/tigervnc/passwd
# Remove potential lock files created from a previously stopped session
rm -rf /tmp/.X*
vncserver :0 -localhost no -nolisten -rfbauth $HOME/.config/tigervnc/passwd -xstartup /opt/x11vnc_entrypoint.sh

if [ -z "$1" ]; then
  tail -f /dev/null
else
  # unknown option ==> call command
  echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
  echo "Executing command: '$@'"
  exec $@
fi
