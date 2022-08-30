#!/usr/bin/env bash

if [[ "$1" && "$2" ]]
then
    sudo /home/simon/homestead/scripts/site-types/laravel.sh $1 $2 80 443 '7.4' '( [TYPO3_CONTEXT]=Development )' '' 'false' '' ''
    sudo /home/simon/homestead/scripts/hosts-add.sh 127.0.0.1 $1
    sudo /home/simon/homestead/scripts/create-certificate.sh $1
    sudo service nginx restart
    echo "Done"
else
    echo "Error: missing required parameters."
    echo "Usage: "
    echo "  create-site.sh domain path"
fi
