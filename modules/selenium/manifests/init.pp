
class selenium{

    if defined(Package['openjdk-7-jre-headless']) == false {
        package { 'openjdk-7-jre-headless': ensure => present, }
    }

    if defined(Package['curl']) == false {
        package { 'curl': ensure  => present, }
    }

    package{ "firefox":
        ensure  => present,
    }

    file { "/var/lib/selenium":
        ensure      => 'directory',
    }->
    exec{ "curl http://selenium.googlecode.com/files/selenium-server-standalone-2.33.0.jar -o /var/lib/selenium/selenium-server.jar":
        creates     => '/var/lib/selenium/selenium-server.jar',
        require     => [ Package['openjdk-7-jre-headless'], Package['curl'] ],
    }

}

class googlechrome ($destFile  ='google-chrome-stable_current_i386.deb', $sourceURL ='https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb') {

  if defined(Package['gdebi-core']) == false {
      package { 'gdebi-core': ensure => present, }
  }

  ## Retrieve the Destination File from the Source URL.
  exec {"wget -O ${destFile} ${sourceURL}":
    cwd     => '/tmp',
    creates => "/tmp/${destFile}",
    unless  => 'dpkg -s google-chrome-stable|grep "ok installed"',
  }

  ## Install the Destination File using gdebi
  exec {"gdebi -n ${destFile}":
    require     => [ Package['gdebi-core'], Exec["wget -O ${destFile} ${sourceURL}"] ],
    cwd         => '/tmp',
    unless      => 'dpkg -s google-chrome-stable|grep "ok installed"',
  }

}
