#!/bin/bash


TIMEOUT="${1:-1800}"

WALG_WAL_CONTAINER=$(grep -Po '^[^#].*WALG_SWIFT_PREFIX="\K[^"]*' /var/lib/postgresql/data/postgresql.conf)
result=$?

if [[ $result -eq 0 ]]
then

	sudo -u postgres SWIFT_REGION=GRA SWIFT_AUTHURL=https://auth.cloud.ovh.net/v3/ WALG_SWIFT_PREFIX=$WALG_WAL_CONTAINER timeout $TIMEOUT ionice -c2 -n7 nice -n19 envdir /run/secrets/ wal-g backup-push $PGDATA
	result=$?

	if [[ $result -eq 0 ]]
	then
	        echo "Backup to $WALG_WAL_CONTAINER successful"
	else
	        >&2 echo  "Backup to $WALG_WAL_CONTAINER failed"
		exit $result
	fi

	sudo -u postgres SWIFT_REGION=GRA SWIFT_AUTHURL=https://auth.cloud.ovh.net/v3/ WALG_SWIFT_PREFIX=$WALG_WAL_CONTAINER timeout $TIMEOUT ionice -c2 -n7 nice -n19 envdir /run/secrets/ wal-g delete --confirm retain 15
	result=$?

	if [[ $result -eq 0 ]]
	then
	        echo "Cleaning of $WALG_WAL_CONTAINER successful"
	else
	        >&2 echo  "Cleaning of $WALG_WAL_CONTAINER failed"
		exit $result
	fi
fi
