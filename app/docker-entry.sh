#!/bin/bash
set -m

config=/mattermost/config/config.json
DB_HOST=${DB_HOST:-db}
DB_PORT_5432_TCP_PORT=${DB_PORT_5432_TCP_PORT:-5432}
MM_USERNAME=${MM_USERNAME:-mmuser}
MM_PASSWORD=${MM_PASSWORD:-mmuser_password}
MM_DBNAME=${MM_DBNAME:-mattermost}
echo -ne "Configure database connection..."
if [ ! -f $config ]
then
    cp /config.template.json $config
    sed -Ei "s/DB_HOST/$DB_HOST/" $config
    sed -Ei "s/DB_PORT/$DB_PORT_5432_TCP_PORT/" $config
    sed -Ei "s/MM_USERNAME/$MM_USERNAME/" $config
    sed -Ei "s/MM_PASSWORD/$MM_PASSWORD/" $config
    sed -Ei "s/MM_DBNAME/$MM_DBNAME/" $config
    echo OK
else
    echo SKIP
fi

echo "Wait until database $DB_HOST:$DB_PORT_5432_TCP_PORT is ready..."
until nc -z $DB_HOST $DB_PORT_5432_TCP_PORT
do
    sleep 1
done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

cd /mattermost/bin

# Enable CJK search
fulltext_index_created=/fulltext_index_created
if [ ! -f $fulltext_index_created ]; then
    echo "Starting platform"
    # Start in background to execute follow sql.
    ./platform $* &

    # Wait to create tables by platform command.
    sleep 30

    # Create fulltext index with ngram parser (see: https://github.com/mattermost/platform/issues/2033)
    mysql -u $MM_USERNAME -p$MM_PASSWORD -h $DB_HOST $MM_DBNAME <<-EOSQL
		DROP INDEX idx_posts_message_txt ON Posts;
		CREATE FULLTEXT INDEX idx_posts_message_txt ON Posts (Message) WITH PARSER ngram COMMENT 'ngram index';
	EOSQL
	echo "fulltext index with ngram parser was created."
    touch $fulltext_index_created

    fg
else
    echo "Starting platform"
    ./platform $*
fi
