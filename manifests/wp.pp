
class wp (
    $deploy_path = "www",
    $db_name = "wordpress",
    $db_password,
    $db_host = "localhost",
    $multisite = "false",
    $db_prefix = "wp_",
    $home = 'http://localhost',
    $siteurl = 'http://localhost:8080',
) {}

class wp::config {
    include wp

    file { "${env::deploy_path}/${wp::deploy_path}/wp-config.php":
        ensure      => file,
        content     => template("config/wp/wp-config.php.erb"),
    }

}

class wp::db {
    Class["mysql_server"] -> Class["wp::db"]

    include wp

    mysql::grant { $wp::db_name:
        mysql_privileges    => 'ALL',
        mysql_password      => $wp::db_password,
        mysql_db            => $wp::db_name,
        mysql_user          => $wp::db_name,
        mysql_host          => $wp::db_host,
    }

}

class wp::local {
    include mysql_server
    include wp::config
    include wp::db
}