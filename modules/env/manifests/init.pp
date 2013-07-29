
class env (
    $custom_webroot = '',
) {

    # HIERA DATA
    $deploy_user = hiera('deploy_user')
    $deploy_group = hiera('deploy_group')
    $deploy_pass = hiera('deploy_pass')
    $deploy_hash = hiera('deploy_hash')
    $deploy_keys = hiera_array('deploy_keys')
    $project_name = hiera('project_name')
    $nginx_vhost = hiera('nginx_vhost')
    $nginx_serveraliases = hiera('nginx_serveraliases')
    $nginx_listen_port = hiera('nginx_listen_port')
    $ssh_permit_root_login = hiera('ssh_permit_root_login')
    $ssh_password_authentication = hiera('ssh_password_authentication')
    $apache_listen_port = hiera('apache_listen_port')
    $apache_servername = hiera('apache_servername')
    $php_modules = hiera_array('php_modules')
    $php5_modules = hiera_array('php5_modules')
    $mysql_root_password = hiera('mysql_root_password')
    $mysql_listen_port = hiera('mysql_listen_port')
    $disable_sendfile = hiera('disable_sendfile')
    $apache_index_rewrite = hiera('apache_index_rewrite')
    $mysql_bind_address = hiera('mysql_bind_address')
    $ftp_listen_port = hiera('ftp_listen_port')
    $ftp_pasv_min_port = hiera('ftp_pasv_min_port')
    $ftp_pasv_max_port = hiera('ftp_pasv_max_port')
    $ftp_dir = hiera('ftp_dir')
    $ftp_users = hiera('ftp_users')
    $xdebug_remote_connect_back = hiera('xdebug_remote_connect_back')
    $xdebug_remote_autostart = hiera('xdebug_remote_autostart')
    $xdebug_remote_port = hiera('xdebug_remote_port')
    $xdebug_profiler_enable_trigger = hiera('xdebug_profiler_enable_trigger')
    $xdebug_profiler_output_name = hiera('xdebug_profiler_output_name')
    $selenium_listen_port = hiera('selenium_listen_port')

    ## DYNAMIC SETTINGS
    $deploy_path = "/home/${deploy_user}/${project_name}/${::environment}"
    $deploy_script = "/home/${deploy_user}/${project_name}/deploy_${::environment}.sh"
    if $custom_webroot == '' {
        $webroot = "${deploy_path}/www"
    } else {
        $webroot = $custom_webroot
    }
    $scripts_dir = "${deploy_path}/env/scripts"
    $composer_autoload = "${deploy_path}/vendor/autoload.php"

    $xdebug_profiler_output_dir = "${deploy_path}/tmp"

    if defined( "file_line" ) {
        file_line{ 'PHP CLI environment"':
            ensure  => present,
            path    => '/etc/environment',
            line    => "PHP_ENV=\"${::environment}\"",
        }
    }
}