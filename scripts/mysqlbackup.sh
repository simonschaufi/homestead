#!/usr/bin/env bash

MYSQL_USER=root
MYSQL_PASS=secret
MYSQL_CONN="-u${MYSQL_USER} -p${MYSQL_PASS}"

#
# Collect all database names except for
# mysql, information_schema, and performance_schema
#
SQL="SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN"
SQL="${SQL} ('information_schema','mysql','performance_schema','sys')"

DBLISTFILE=/tmp/DatabasesToDump.txt
mysql ${MYSQL_CONN} -ANe"${SQL}" > ${DBLISTFILE}

DBLIST=""
for DB in `cat ${DBLISTFILE}` ; do DBLIST="${DBLIST} ${DB}" ; done

#MYSQLDUMP_OPTIONS="--routines --triggers --single-transaction"
#mysqldump ${MYSQL_CONN} ${MYSQLDUMP_OPTIONS} --databases ${DBLIST} > all-dbs.sql


FILE=${1:-/home/simon/mysqldump.sql.gz}

SIZE_QUERY="select ceil(sum(data_length) * 0.8) as size from information_schema.TABLES"

echo "Exporting databases to '$FILE'"

ADJUSTED_SIZE=$(mysql --vertical -usimon -psecret -e "$SIZE_QUERY" 2>/dev/null | grep 'size' | awk '{print $2}')
HUMAN_READABLE_SIZE=$(numfmt --to=iec-i --suffix=B --format="%.3f" $ADJUSTED_SIZE)

echo "Estimated uncompressed size: $HUMAN_READABLE_SIZE"
mysqldump ${MYSQL_CONN} --skip-lock-tables --databases ${DBLIST} 2>/dev/null | pv --size=$ADJUSTED_SIZE | gzip > "$FILE"
echo "Done."

