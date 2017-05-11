#!/bin/bash
echo Starting Nginx
sed -Ei "s/APP_HOST/$APP_HOST/" /etc/nginx/sites-available/mattermost
sed -Ei "s/APP_HOST/$APP_HOST/" /etc/nginx/sites-available/mattermost-ssl
sed -Ei "s/APP_PORT/$PLATFORM_PORT_80_TCP_PORT/" /etc/nginx/sites-available/mattermost
sed -Ei "s/APP_PORT/$PLATFORM_PORT_80_TCP_PORT/" /etc/nginx/sites-available/mattermost-ssl
if [ "$MATTERMOST_ENABLE_SSL" = true ]; then
    ssl="-ssl"
fi
rm -f /etc/nginx/sites-enabled/mattermost
ln -s /etc/nginx/sites-available/mattermost$ssl /etc/nginx/sites-enabled/mattermost
nginx -g 'daemon off;'
