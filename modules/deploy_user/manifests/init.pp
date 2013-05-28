class deploy_user {

    user { $env::deploy_user:
      ensure        => 'present',
      gid           => $env::deploy_group,
      home          => "/home/${env::deploy_user}",
      shell         => '/bin/bash',
      managehome    => true,
      groups        => ['sudo'],
      password      => $env::deploy_hash,
    }->
    file {"/home/${env::deploy_user}/.ssh":
        ensure      => directory,
        owner       => $env::deploy_user,
        group       => $env::deploy_group,
    }->
    file {"/home/${env::deploy_user}/.ssh/authorized_keys":
        recurse     => true,
        owner       => $env::deploy_user,
        group       => $env::deploy_group,
        ensure      => present,
        mode        => 644,
    }->
    ssh_authorized_keys_deploy { $env::deploy_keys: }
    define ssh_authorized_keys_deploy {
        ssh_authorized_key { $name:
            user    => $env::deploy_user,
            ensure  => present,
            type    => 'ssh-rsa',
            key     => $name,
        }
    }

    file {"sshd_config":
        path        => "/etc/ssh/sshd_config",
        ensure      => file,
        content     => template('config/deploy/sshd_config.erb'),
    }->
    service { "ssh":
        ensure      => running,
        enable      => true,
        subscribe   => File['sshd_config'],
        hasrestart  => true,
    }

    if $::environment != 'deploy' {
        file { "${env::deploy_script}":
            ensure  => file,
            mode    => '0600',
            owner   => 'root',
            group   => $env::deploy_group,
            content => template('config/deploy/deploy.sh.erb'),
        }->
        exec { "tr -d '\\015' < ${env::deploy_script} > /tmp/temp.sh && mv /tmp/temp.sh ${env::deploy_script}":
        }->
        exec { "chmod 700 ${env::deploy_script}; chgrp ${env::deploy_group} ${env::deploy_script}": }
    }

    if $::environment != 'dev' {
        file {"/home/${env::deploy_user}":
            ensure      => directory,
            recurse     => true,
            owner       => $env::deploy_user,
            group       => $env::deploy_group,
            require     => User[$env::deploy_user],
        }
    }
    else
    {
        file{"/home/vagrant/${::environment}":
            ensure      => link,
            target      => $env::deploy_path,
        }
    }
}

