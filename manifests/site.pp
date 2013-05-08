
include env
import 'init.pp'
class import_project {
    import '../../config/manifests/*.pp'
}
include config

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

class nginx_server {

    class {"nginx":
        template            => 'nginx/conf.d/nginx.conf.erb'
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
        template        => 'config/nginx/vhost.conf.erb',
        serveraliases   => $env::nginx_serveraliases,
        notify          => Service['nginx'],
    }

    ufw::allow {"allow-http-nginx-${env::nginx_listen_port}-from-all":
        port        => $env::nginx_listen_port,
    }
}

class apache_server {

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

    php::module { $env::php_modules:
        notify  => Service["apache"],
    }

    ufw::allow {"allow-http-apache-${env::apache_listen_port}-from-all":
        port        => $env::nginx_listen_port,
    }

}

class mysql_server {

    class { "mysql":
        root_password   => $env::mysql_root_password,
        template        => 'config/mysql/my.cnf.erb',
    }

    ufw::allow {"allow-mysql-3306-from-all":
        port        => $env::mysql_listen_port,
    }

}


