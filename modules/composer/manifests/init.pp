class composer {

    $flags = $::environment ? {
        dev     => '--dev',
        default => '',
    }

    if defined(Class['apache_server']) == true {
        require apache_server
    }

    if defined(Class['mysql_server']) == true {
        require mysql_server
    }

    if defined(Class['php']) == false {
        include php
    }

    exec{ "curl -sS https://getcomposer.org/installer | php -- --install-dir=/tmp; mv /tmp/composer.phar /usr/local/bin/composer":
        creates     => '/usr/local/bin/composer',
        require     => [ Package['curl'], Class['php'] ],
        onlyif      => "test -f ${env::deploy_path}/composer.json",
    }->
    exec{ "composer install ${flags}":
        cwd         => $env::deploy_path,
        require     => Package['git'],
        environment => "HOME=/home/${env::deploy_user}",
        onlyif      => "test -f ${env::deploy_path}/composer.json",
    }->
    exec{ "composer update ${flags}":
        cwd         => $env::deploy_path,
        environment => "HOME=/home/${env::deploy_user}",
        onlyif      => "test -f ${env::deploy_path}/composer.lock"
    }

    file_line { "Composer CLI autoload":
        ensure  => present,
        path    => '/etc/environment',
        line    => "COMPOSER_AUTOLOAD=\"${env::composer_autoload}\"",
    }

}