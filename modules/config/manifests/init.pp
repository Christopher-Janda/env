
class config {
    include robots_txt
}

class robots_txt {
    $robots_disallow = $::environment ? {
        'prod'      => hiera_array("robots_disallow"),
        default     => ["/"],
    }
    file{ "${env::webroot}/robots.txt":
        ensure      => file,
        content     => template('config/site/robots.txt.erb'),
    }
}
