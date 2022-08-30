#!/usr/bin/env bash

if [[ -f /home/vagrant/.phpmyadmin ]]
then
    echo "phpmyadmin already installed."
    exit 0
fi
touch /home/vagrant/.phpmyadmin

sudo apt update

sudo apt install -y phpmyadmin

sudo tee /etc/phpmyadmin/conf.d/homestead.php <<EOL
<?php

\$i = 1;

\$cfg['Servers'][\$i]['auth_type'] = 'config';
\$cfg['Servers'][\$i]['user'] = 'homestead';
\$cfg['Servers'][\$i]['password'] = 'secret';
EOL
