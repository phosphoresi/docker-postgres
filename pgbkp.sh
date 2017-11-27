#!/bin/bash


TIMEOUT="${1:-1800}"

WALE_WAL_CONTAINER=$(grep -Po '^[^#].*WALE_SWIFT_PREFIX="\K[^"]*' /var/lib/postgresql/data/postgresql.conf)
result=$?

if [[ $result -eq 0 ]]
then

	sudo -u postgres SWIFT_REGION=GRA3 SWIFT_AUTHURL=https://auth.cloud.ovh.net/v2.0/ WALE_SWIFT_PREFIX=$WALE_WAL_CONTAINER timeout $TIMEOUT ionice -c2 -n7 nice -n19 envdir /run/secrets/ wal-e backup-push $PGDATA
	result=$?

	if [[ $result -eq 0 ]]
	then
	        echo "Backup to $WALE_WAL_CONTAINER successful"
	else
	        >&2 echo  "Backup to $WALE_WAL_CONTAINER failed"
		exit $result
	fi

	sudo -u postgres SWIFT_REGION=GRA3 SWIFT_AUTHURL=https://auth.cloud.ovh.net/v2.0/ WALE_SWIFT_PREFIX=$WALE_WAL_CONTAINER timeout $TIMEOUT ionice -c2 -n7 nice -n19 envdir /run/secrets/ wal-e delete --confirm retain 15
	result=$?

	if [[ $result -eq 0 ]]
	then
	        echo "Cleaning of $WALE_WAL_CONTAINER successful"
	else
	        >&2 echo  "Cleaning of $WALE_WAL_CONTAINER failed"
		exit $result
	fi
fi
