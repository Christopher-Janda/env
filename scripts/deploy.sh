#!/bin/bash
# requires root
# deploy.sh project_name deploy_key

wget --no-check-certificate https://github.com/Riser/env/archive/master.tar.gz
tar xpvf master.tar.gz
mv env-master env

cat > deploy.json  <<EOL
{
        "project_name": "$1",
        "deploy_keys":
         [
                "$2"
        ]
}
EOL

. /etc/lsb-release

DEB="puppetlabs-release-${DISTRIB_CODENAME}.deb"
DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list" # Assume that this file's existence means we have the Puppet Labs repo added

if [ ! -e $DEB_PROVIDES ]
then
    print "Could not find $DEB_PROVIDES - fetching and installing $DEB"
    wget -q http://apt.puppetlabs.com/$DEB
    dpkg -i $DEB

    apt-get update
    apt-get install --yes puppet
    apt-get -f install --yes

    rm $DEB

    cat >/etc/apt/preferences.d/00-puppet.pref <<EOL
Package: puppet puppet-common
Pin: version 3.1*
Pin-Priority: 501
EOL

fi

puppet apply --environment deploy --hiera_config "env/config/hiera.yaml" --modulepath "env/modules" env/manifests/init.pp
