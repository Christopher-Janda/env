
class config {
    include robots_txt
}

class robots_txt {
    $sitemap = hiera('sitemap')
    $robots_disallow = $::environment ? {
        'prod'      => hiera_array("robots_disallow"),
        default     => ["/"],
    }
    $robots_allow = $::environment ? {
        'prod'      => hiera_array("robots_allow"),
        default     => [""],
    }
    file{ "${env::webroot}/robots.txt":
        ensure      => file,
        content     => template('config/site/robots.txt.erb'),
    }
}
