#!/bin/bash
set -eu

function illegalArgumentsError() {
  echo "required arguments database_name, mysql_root_password"
}

if [ -n "$1" ]; then
  database_name="$1"
else
  illegalArgumentsError
  exit 1
fi
if [ -n "$2" ]; then
  mysql_root_password="$2"
else
  illegalArgumentsError
  exit 1
fi

# Enable cjk search
fulltext_index_created=/fulltext_index_created
if [ ! -f $fulltext_index_created ]; then
    # Use ngram parser (see: https://github.com/mattermost/platform/issues/2033)
    mysql -uroot -p$mysql_root_password <<-EOSQL
		USE $database_name;
		DROP INDEX idx_posts_message_txt ON Posts;
		CREATE FULLTEXT INDEX idx_posts_message_txt ON Posts (Message) WITH PARSER ngram COMMENT 'ngram index';
	EOSQL
    touch $fulltext_index_created
fi
