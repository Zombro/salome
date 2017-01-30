#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

SALOME_USER=${SALOME_USER:-salome}

create_user() {
  # ensure home directory is owned by browser
  # and that profile files exist
  if [[ -d /home/${SALOME_USER} ]]; then
    chown ${USER_UID}:${USER_GID} /home/${SALOME_USER}
    # copy user files from /etc/skel
    cp /etc/skel/.bashrc /home/${SALOME_USER}
    cp /etc/skel/.bash_logout /home/${SALOME_USER}
    cp /etc/skel/.profile /home/${SALOME_USER}
    chown ${USER_UID}:${USER_GID} \
		/home/${SALOME_USER}/.bashrc \
		/home/${SALOME_USER}/.profile \
		/home/${SALOME_USER}/.bash_logout
  fi
  # create group with USER_GID
  if ! getent group ${SALOME_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${SALOME_USER} 2> /dev/null
  fi

  # create user with USER_UID
  if ! getent passwd ${SALOME_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'SALOME' ${SALOME_USER}
  fi

  # fixes issue #7
  if [[ "x$(stat -c '%U' /opt/salome)" != "x${SALOME_USER}"  ]]; then
    chown -R ${SALOME_USER}: /opt/salome
  fi
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=browser-box-video
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${SALOME_USER}
      break
    fi
  done
}

launch_salome() {
  cd /home/${SALOME_USER}
  exec sudo -HEu ${SALOME_USER} /opt/salome/appli/salome $@ ${extra_opts}
}

case "$1" in
  ""|start|context|shell|connect|kill|killall|test|info|doc|help|coffee)
    create_user
    grant_access_to_video_devices
    launch_salome $@
    ;;
  *)
    exec $@
    ;;
esac
