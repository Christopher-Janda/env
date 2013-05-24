
Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

include env

class { "deploy_user": }

if $::environment != 'deploy' {
    file { "${env::scripts_dir}/init.sh":
        ensure  => file,
        mode    => 'u+x',
        owner   => $env::deploy_user,
        group   => $env::deploy_group,
    }
}
