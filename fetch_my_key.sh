#!/usr/bin/env bash
# Script for adding a user and ssh keys in cam.
#
# Author: Andreas A. Grammenos (ag926@cl.cam.ac.uk)
#
# Last touched: 10/04/2020

# pretty functions for log output
function cli_info { echo -e "\033[1;32m -- ${1}\033[0m" ; }
function cli_info_read { echo -e -n "\e[1;32m -- ${1}\e[0m" ; }
function cli_warning { echo -e "\033[1;33m ** ${1}\033[0m" ; }
function cli_warning_read { echo -e -n "\e[1;33m ** ${1}\e[0m" ; }
function cli_error { echo -e "\033[1;31m !! ${1}\033[0m" ; }

# validate a given string if it is a URL.
function validate_url {
  # rudimentary input check
  if [[ ${#} -ne 1 ]]; then
    cli_error "Error: validate_url expected 1 argument, ${#} were supplied"
    return 0
  fi

  # check for a valid url
  regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  if [[ ${1} =~ ${regex} ]]; then
    #cli_info "The link: ${1}, seems valid"
    return 0
  else
    #cli_info "The link: ${1}, seems to be not valid"
    return 1
  fi
}

# check for sudo
if [[ $(id -u) -ne 0 ]]; then
  cli_error "Need to run as root"; exit 1;
fi

# check for the correct number of arguments
if [[ "${#}" -ne 2 ]]; then
  cli_error "not enough arguments, got ${#} expected 2.\nUsage: ./fetch_my_key.sh username ssh_key/ssh_key_link";
  exit 1
fi

# variables
USER_NAME=${1}
SSH_KEY_BUFF=${2}
KEY_IS_URL=false
AUTH_KEYS="authorized_keys"

# check if the key is a url based on normal patterns.
if validate_url ${SSH_KEY_BUFF}; then
  KEY_IS_URL=true
  cli_info "Detected ssh key url."
else
  cli_info "Detected inline ssh key."
fi

# check if the user exists
if id "${1}" >/dev/null 2>&1; then
  cli_info "User ${USER_NAME} already exists"
else
  cli_warning "User ${USER_NAME} doesn't exist, trying to create it"

  # now check if want to add the user
  cli_info_read "Add user ${USER_NAME}? (y/n): "; read -n 1 -r; echo ""
  # check if the user agrees
  if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    # do dangerous stuff
    cli_warning "Creating using cl-way, if this fails that means user doesn't have CL account..."
    cl-add-user -q ${USER_NAME}
    if [[ ${?} -eq 0 ]]; then
      cli_info "User ${USER_NAME} added successfully, now proceeding to add ssh key."
    else
      cli_error "User ${USER_NAME} failed to be added, ensure CL account exists."; exit 1;
    fi
  else
    cli_error "User needs to present in the system in order to add the keys, aborting..."; exit 1;
  fi
fi


# move evaluation of user path and ssh build-up
# down here, so we don't mess up if the user
# is created now.
USER_PATH=$(eval echo ~${USER_NAME})
USER_SSH_PATH="${USER_PATH}/.ssh"
USER_AUTH_KEYS=${USER_SSH_PATH}/${AUTH_KEYS}

# get the key and put it in the correct file
# if it does not exist create it.
cli_info "Adding key to ssh"

if [[ ! -d "${USER_SSH_PATH}" ]]; then
  mkdir -p ${USER_SSH_PATH}
fi

# check if we have a url or an actual key on file.
# NOTE: our preferred strategy is to *append*, thus any existing files are preserved
if [[ ${KEY_IS_URL} = true ]]; then
  cli_info "key is under URL, trying to fetch..."
  wget ${SSH_KEY_BUFF} -O - >> ${USER_SSH_PATH}/${AUTH_KEYS}
else
  cli_info "key is embedded, trying to append..."
  echo ${SSH_KEY_BUFF} >> ${USER_AUTH_KEYS}
fi

# check if any of the above failed.
if [[ ${?} -eq 0 ]]; then
  cli_info "Key added successfully, now fixing permissions..."
else
  cli_error "Key failed to be added, skipping ssh permissions and cannot continue."; exit 1;
fi

# fix permissions
cli_info "Fixing user permissions"
chown -R ${USER_NAME} ${USER_SSH_PATH} &&
chmod 700 ${USER_SSH_PATH} &&
chmod 600 ${USER_SSH_PATH}/${AUTH_KEYS}

if [[ ${?} -ne 0 ]]; then
  cli_error "Encountered non-zero return code when setting permissions - cannot continue."; exit 1;
else
  cli_info "Adding ssh-key for user: ${USER_NAME} was performed successfully"
fi

# done
cli_info "Finished adding user successfully!"



