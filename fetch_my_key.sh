#!/usr/bin/env bash

# Script for adding a user and ssh keys in cam.
#
# Author: Andreas Grammenos (andreas.grammenos@gmail.com)
#
# Last touched: 24/10/2017

# check for sudo
if [[ $(id -u) -ne 0 ]]; then
  echo "Need to run as root"; exit 1;
fi

# check for the correct number of arguments
if [ "$#" -ne 2 ]; then
  echo -e "not enough arguments, got $# expected 2.\nUsage: ./fetch_my_key.sh username ssh_key_link"; exit 1;
fi

## beautiful and tidy way to expand tilde (~) by C. Duffy.
expandPath() {
  case $1 in
    ~[+-]*)
      local content content_q
      printf -v content_q '%q' "${1:2}"
      eval "content=${1:0:2}${content_q}"
      printf '%s\n' "$content"
      ;;
    ~*)
      local content content_q
      printf -v content_q '%q' "${1:1}"
      eval "content=~${content_q}"
      printf '%s\n' "$content"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

KEY_LINK=$2
USER_NAME=$1
USER_PATH=$(eval echo ~${USER_NAME})
USER_SSH_PATH="${USER_PATH}/.ssh"

AUTH_KEYS="authorized_keys"
CL_ASUSER="cl-asuser"

# check if the user exists
if id "$1" >/dev/null 2>&1; then
  echo "User ${USER_NAME} already exists"
else
  echo "User ${USER_NAME} doesn't exist, trying to create it"
  # check if we can
  command -v ${CL_ASUSER} >/dev/null 2>&1 ||
    { echo >&2 "I require ${CL_ASUSER} but it's not installed, cannot create user ${USER_NAME} aborting..."; exit 1; }

  # now check if want to add the user
  read -p "Add user ${USER_NAME}? (y/n): " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # do dangerous stuff
    echo "Creating using cl-way, if this fails that means user doesn't have CL account..."
    cl-asuser cl-add-user -q ${USER_NAME}
    if [ $? -eq 0 ]; then
      echo "User ${USER_NAME} added successfully, now proceeding to add ssh key."
    else
      echo "User ${USER_NAME} failed to be added, ensure CL account exists."
      exit 1;
    fi
  else
    echo "User needs to present in the system in order to add the keys, aborting..."; exit 1;
  fi
fi

# get the key and put it in the correct file
# if it does not exist create it.
echo -e "\nAdding key to ssh"

if [ ! -d "${USER_SSH_PATH}" ]; then
  mkdir -p ${USER_SSH_PATH}
  wget ${KEY_LINK} -O ${USER_SSH_PATH}/${AUTH_KEYS}
else
  wget ${KEY_LINK} -O ->> ${USER_SSH_PATH}/${AUTH_KEYS}
fi

# check if any of the above failed.
if [ $? -eq 0 ]; then
  echo -e "\nKey added successfully, now fixing permissions..."
else
  echo -e "\nKey failed to be added, skipping ssh permissions"; exit 1;
fi

# fix permissions
echo -e "Fixing user permissions"
chown -R ${USER_NAME} ${USER_SSH_PATH}
chmod 700 ${USER_SSH_PATH}
chmod 600 ${USER_SSH_PATH}/${AUTH_KEYS}

# done
echo -e "Adding ssh-key for user: ${USER_NAME} was performed successfully"



