class vsftp {

    $ftp_user_names = keys($env::ftp_users)
    $ftp_user_names_str = join($ftp_user_names, "\n")
    $ftp_db_str = join(join_keys_to_values($env::ftp_users, "\n"), "\n")

    package { 'vsftpd':
        ensure  => present,
    }

    service { 'vsftpd':
        enable      => true,
        ensure      => running,
        hasrestart  => true,
        require     => Package['vsftpd'],
    }

    file { "/etc/vsftpd.conf":
        ensure  => file,
        content => template('config/vsftp/vsftpd.conf.erb'),
        notify  => Service['vsftpd'],
        require => Package['vsftpd'],
    }->
    file { "/etc/pam.d/vsftpd.virtual":
        ensure  => file,
        content => template('config/vsftp/vsftpd.virtual.erb'),
        notify  => Service['vsftpd'],
    }->
    file { "/tmp/vusers.txt":
        ensure  => file,
        content => "${ftp_db_str}\n",
    }->
    package { "db-util":
        ensure  => present,
    }->
    file { "/etc/vsftpd":
        ensure  => directory,
    }->
    file{ "/etc/vsftpd/vsftpd-virtual-user.db":
        ensure  => present,
        mode    => "600",
        content => "",
    }->
    exec{ "db_load -T -t hash -f /tmp/vusers.txt /etc/vsftpd/vsftpd-virtual-user.db":
        notify  => Service['vsftpd'],
    }->
    file { "/tmp/vusers.txt remove":
        target  => "/tmp/vusers.txt",
        ensure  => absent,
    }

    file { "/etc/vsftpd.chroot_list":
        ensure  => file,
        content => $ftp_user_names_str,
    }

    vsftp::dir { $ftp_user_names: }

}

define vsftp::dir {

    file { $env::ftp_dir:
        ensure  => directory,
        owner   => $env::deploy_user,
        mode    => 660,
    }->
    file { "${env::ftp_dir}/${name}":
        ensure  => directory,
        owner   => $env::deploy_user,
        mode    => 660,
    }
}