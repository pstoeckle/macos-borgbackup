#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
REPO_URL=''
REPO_PASSWORD=''
SSH_KEY='path/to/ssh/key'
EXCLUDE_FILE='path/to/exclude/file'

function backup {
	borg create \
		--exclude-from ${EXCLUDE_FILE} \
		${REPO_URL}::'{hostname}-{now:%Y_%m_%d_%H_%M}' \
		~/Documents \
		~/.ssh \
		&& osascript -e "display notification \"Backup completed\" with title \"Borgbackup\""
}

function remove_old_backup {
	borg prune -v --list ${REPO_URL} --prefix '{hostname}-' \
		--keep-daily=7 --keep-weekly=4 --keep-monthly=6
}

function check_last_backup {
	eval `ssh-agent -s`
	server_available=true
	ssh-add ${SSH_KEY}
	ssh -o ConnectTimeout=10 borg@borgbackup.in.tum.de 'borg -V' > /dev/null || server_available=false
	if [ "$server_available" = true ];
	then
		backup $DIFF
		remove_old_backup
	else
		osascript -e "display notification \"Backup failed!\" with title \"Borgbackup\""
	fi
}

export BORG_PASSPHRASE=${REPO_PASSWORD}
check_last_backup
