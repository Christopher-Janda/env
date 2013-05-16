
$hosts = hiera_hash('hosts')
$host_ips = keys( $hosts )

set_host { $host_ips: }

define set_host {
	host { $::hosts[$name]:
		ip 		=> $name
	}
}
