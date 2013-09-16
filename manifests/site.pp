
include env
import 'init.pp'
import 'hosts.pp'
class import_project {
    import '../../config/manifests/*.pp'
}
include config


### MISC ###
package { "vim":
    ensure      => installed,
}
package {
    'curl': ensure  => present,
}
package {
    'git': ensure => present,
}
include mysql::client
exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    refreshonly => true,
}


node default {
    hiera_include('classes')
}

######## CLASS DEFINITIONS ########

class firewall {
    include ufw

    ufw::allow { "allow-ssh-from-all":
        port        => 22,
    }
}

class nginx_server (
    $vhost_config = 'config/nginx/vhost.conf.erb'
) {

    class {"nginx":
        template            => 'nginx/conf.d/nginx.conf.erb',
        worker_connections  => hiera('nginx_worker_connections'),
    }
    file { "${nginx::vdir}":
        ensure      => directory,
        #recurse     => true,
        #purge       => true,
        #force       => true,
    }->
    nginx::vhost { $env::nginx_vhost:
        enable          => true,
        docroot         => $env::webroot,
        port            => $env::nginx_listen_port,
        owner           => $env::deploy_user,
        groupowner      => $env::deploy_group,
        template        => $vhost_config,
        serveraliases   => $env::nginx_serveraliases,
        notify          => Service['nginx'],
    }

    ufw::allow {"allow-http-nginx-${env::nginx_listen_port}-from-all":
        port        => $env::nginx_listen_port,
        ip          => 'any',
    }
}

class apache_server {

    include composer

    class { "apache":
        # port        => $env::apache_listen_port,
        template    => 'config/apache/apache.conf.erb',
    }

    apache::vhost { $env::apache_listen_port:
        docroot     => $env::webroot,
        server_name => $env::apache_servername,
        port        => $env::apache_listen_port,
        template    => 'config/apache/vhost.conf.erb',
    }->
    file { "${apache::config_dir}/sites-enabled/000-default":
        ensure      => absent,
        notify      => Service["apache"]
    }

    file{ "${apache::config_dir}/mods-enabled/rewrite.load":
        ensure      => link,
        target      => "${apache::config_dir}/mods-available/rewrite.load",
        notify      => Service["apache"],
        require     => Package["apache"],
    }

    class { "php::apache2":
        require => Package["apache"],
    }

    apache::module { $env::apache_modules:
        notify => Service["apache"],
    }

    php::module { $env::php5_modules:
        notify  => Service["apache"],
    }

    php::module { $env::php_modules:
        notify          => Service["apache"],
        package_prefix  => "php-",
    }

    ufw::allow {"allow-http-apache-${env::apache_listen_port}-from-all":
        port        => $env::apache_listen_port,
        ip          => 'any',
    }

    php::conf { [ 'mysqli', 'pdo', 'pdo_mysql', ]:
        require => Package['php-mysql'],
        notify  => Service['apache'],
    }

    if "xdebug" in $env::php5_modules {
        file { "/etc/php5/conf.d/xdebug_remote.ini":
    		ensure      => present,
    		content     => template('config/php/xdebug_remote.ini.erb'),
    		notify      => Service["apache"],
    		require     => Class["php::config"],
    	}
    }

}

class mysql_server {

    class { "mysql":
        root_password   => $env::mysql_root_password,
        template        => 'config/mysql/my.cnf.erb',
    }

    ufw::allow {"allow-mysql-3306-from-all":
        port        => $env::mysql_listen_port,
        ip          => 'any',
    }

}

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

    if defined(Package['git']) == false {
        package { 'git': ensure => present, }
    }
    if defined(Package['curl']) == false {
        package { 'curl': ensure  => present, }
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
    }
    /*
    ->
    exec{ "composer update ${flags}":
        cwd         => $env::deploy_path,
        environment => "HOME=/home/${env::deploy_user}",
        onlyif      => "test -f ${env::deploy_path}/composer.lock"
    }
    */

    file_line { "Composer CLI autoload":
        ensure  => present,
        path    => '/etc/environment',
        line    => "COMPOSER_AUTOLOAD=\"${env::composer_autoload}\"",
    }

}


