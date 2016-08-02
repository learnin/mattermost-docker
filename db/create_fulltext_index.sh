#!/bin/bash
set -eu

# Enable cjk search
fulltext_index_created=/fulltext_index_created
if [ ! -f $fulltext_index_created ]; then
    # Use ngram parser (see: https://github.com/mattermost/platform/issues/2033)
    mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
		USE $MYSQL_DATABASE;
		DROP INDEX idx_posts_message_txt ON Posts;
		CREATE FULLTEXT INDEX idx_posts_message_txt ON Posts (Message) WITH PARSER ngram COMMENT 'ngram index';
	EOSQL
    touch $fulltext_index_created
fi
