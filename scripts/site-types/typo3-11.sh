#!/usr/bin/env bash

declare -A params=$6       # Create an associative array
declare -A headers=${9}    # Create an associative array
declare -A rewrites=${10}  # Create an associative array
paramsTXT=""
if [ -n "$6" ]; then
    for element in "${!params[@]}"
    do
        paramsTXT="${paramsTXT}
        fastcgi_param ${element} ${params[$element]};"
    done
fi
headersTXT=""
if [ -n "${9}" ]; then
    for element in "${!headers[@]}"
    do
        headersTXT="${headersTXT}
        add_header ${element} ${headers[$element]};"
    done
fi
rewritesTXT=""
if [ -n "${10}" ]; then
    for element in "${!rewrites[@]}"
    do
        rewritesTXT="${rewritesTXT}
        location ~ ${element} { if (!-f \$request_filename) { return 301 ${rewrites[$element]}; } }"
    done
fi

if [ "$7" = "true" ]
then configureXhgui="
location /xhgui {
        try_files \$uri \$uri/ /xhgui/index.php?\$args;
}
"
else configureXhgui=""
fi

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl http2;
    server_name .$1;
    root \"$2\";

    index index.html index.php;

    charset utf-8;

    $rewritesTXT

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    sendfile off;

    # see https://docs.typo3.org/m/typo3/tutorial-getting-started/main/en-us/SystemRequirements/Index.html#web-server

    # Compressing resource files will save bandwidth and so improve loading speed especially for users
    # with slower internet connections. TYPO3 can compress the .js and .css files for you.
    # *) Set \$GLOBALS['TYPO3_CONF_VARS']['BE']['compressionLevel'] = 9 for the Backend
    # *) Set \$GLOBALS['TYPO3_CONF_VARS']['FE']['compressionLevel'] = 9 together with the TypoScript properties
    #    config.compressJs and config.compressCss for GZIP compression of Frontend JS and CSS files.
    location ~ \.js\.gzip$ {
        add_header Content-Encoding gzip;
        gzip off;
        types { text/javascript gzip; }
    }
    location ~ \.css\.gzip$ {
        add_header Content-Encoding gzip;
        gzip off;
        types { text/css gzip; }
    }

    # TYPO3 - Rule for versioned static files, configured through:
    # - \$GLOBALS['TYPO3_CONF_VARS']['BE']['versionNumberInFilename']
    # - \$GLOBALS['TYPO3_CONF_VARS']['FE']['versionNumberInFilename']
    if (!-e \$request_filename) {
        rewrite ^/(.+)\.(\d+)\.(php|js|css|png|jpg|gif|gzip)$ /$1.$3 last;
    }

    # TYPO3 - Block access to composer files
    location ~* composer\.(?:json|lock) {
        deny all;
    }

    # TYPO3 - Block access to flexform files
    location ~* flexform[^.]*\.xml {
        deny all;
    }

    # TYPO3 - Block access to language files
    location ~* locallang[^.]*\.(?:xml|xlf)$ {
        deny all;
    }

    # TYPO3 - Block access to static typoscript files
    location ~* ext_conf_template\.txt|ext_typoscript_constants\.txt|ext_typoscript_setup\.txt {
        deny all;
    }

    # TYPO3 - Block access to miscellaneous protected files
    location ~* /.*\.(?:bak|co?nf|cfg|ya?ml|ts|typoscript|tsconfig|dist|fla|in[ci]|log|sh|sql|sqlite)$ {
        deny all;
    }

    # TYPO3 - Block access to recycler and temporary directories
    location ~ _(?:recycler|temp)_/ {
        deny all;
    }

    # TYPO3 - Block access to configuration files stored in fileadmin
    location ~ fileadmin/(?:templates)/.*\.(?:txt|ts|typoscript)$ {
        deny all;
    }

    # TYPO3 - Block access to libraries, source and temporary compiled data
    location ~ ^(?:vendor|typo3_src|typo3temp/var) {
        deny all;
    }

    # TYPO3 - Block access to protected extension directories
    location ~ (?:typo3conf/ext|typo3/sysext|typo3/ext)/[^/]+/(?:Configuration|Resources/Private|Tests?|Documentation|docs?)/ {
        deny all;
    }

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
        $headersTXT
    }

    # TYPO3 Backend URLs
    location = /typo3 {
        rewrite ^ /typo3/;
    }

    location /typo3/ {
        try_files \$uri /typo3/index.php\$is_args\$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php$5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        $paramsTXT

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$1.crt;
    ssl_certificate_key /etc/nginx/ssl/$1.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
