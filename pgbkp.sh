#!/bin/bash

parameters=$(grep archive_command /var/lib/postgresql/data/conf.d/walg.conf | cut -d '=' -f 2-  | sed -e 's/wal-g wal-push.*//g' | sed -e "s/'//g")
TIMEOUT="${1:-1800}"

eval "$parameters" timeout $TIMEOUT ionice -c2 -n7 nice -n19 wal-g backup-push $PGDATA
result=$?

if [[ $result -eq 0 ]];then
  echo "Backup to $WALG_SWIFT_PREFIX successful"
else
  >&2 echo  "Backup to $WALG_SWIFT_PREFIX failed"
  exit $result
fi

eval "$parameters" timeout $TIMEOUT ionice -c2 -n7 nice -n19 wal-g delete --confirm retain 15
result=$?

if [[ $result -eq 0 ]];then
  echo "Cleaning of $WALG_SWIFT_PREFIX successful"
else
  >&2 echo  "Cleaning of $WALG_SWIFT_PREFIX failed"
  exit $result
fi
