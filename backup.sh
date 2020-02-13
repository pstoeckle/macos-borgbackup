#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
REPO_URL=''
REPO_PASSWORD=''
SSH_KEY='path/to/ssh/key'
EXCLUDE_FILE='path/to/exclude/file'

function backup {
	eval `ssh-agent -s`
	ssh-add ${SSH_KEY}
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
	backup $DIFF
	remove_old_backup
}

export BORG_PASSPHRASE=${REPO_PASSWORD}
check_last_backup
