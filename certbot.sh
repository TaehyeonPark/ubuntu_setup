#!/bin/bash

FULLDOMAIN=''
EMAIL='op@taehyeon.me'
echo "email(=op@taehyeon.me)"
echo "Enter fulldomain"
read FULLDOMAIN

certbot certonly --webroot --agree-tos --email $EMAIL -d $FULLDOMAIN -w /var/www/html/
