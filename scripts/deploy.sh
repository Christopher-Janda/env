#!/bin/bash
# requires root
# sudo curl -sS https://raw.github.com/riser/env/master/scripts/deploy.sh | bash -s {deploy_user} {project_name} {environment} {deploy_key}

PROJECT_PATH="/home/$1/$2"
DEPLOY_PATH="$PROJECT_PATH/$3"

mkdir -p $DEPLOY_PATH/config

wget --no-check-certificate https://github.com/Riser/env/archive/master.tar.gz
tar xpvf master.tar.gz
mv env-master $DEPLOY_PATH/env

cat > $DEPLOY_PATH/config/project.json  <<EOL
{
        "project_name": "$2",
        "deploy_keys":
         [
                "$4"
         ]
}
EOL

cd $DEPLOY_PATH

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

    # update sudoers to allow deploy to run deploy script w/o sudo password
    if [ -e /tmp/sudoers.tmp ]
    then
        rm /tmp/sudoers.tmp
    fi
    cp /etc/sudoers /tmp/sudoers.tmp
    echo "deploy ALL=(ALL) NOPASSWD:$PROJECT_PATH/deploy_$3.sh" >> /tmp/sudoers.tmp
    visudo -c -f /tmp/sudoers.tmp
    if [ "$?" -eq "0" ]
    then
        cp /tmp/sudoers.tmp /etc/sudoers
    fi
    rm /tmp/sudoers.tmp
fi

puppet apply --environment $3 --hiera_config "env/config/hiera.yaml" --modulepath "env/modules" env/manifests/init.pp
