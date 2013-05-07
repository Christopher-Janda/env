#!/bin/bash
# requires root access

cd $1

. /etc/lsb-release

DEB="puppetlabs-release-${DISTRIB_CODENAME}.deb"
DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list" # Assume that this file's existence means we have the Puppet Labs repo added

if [ ! -e $DEB_PROVIDES ]
then
    print "Could not find $DEB_PROVIDES - fetching and installing $DEB"
    wget -q http://apt.puppetlabs.com/$DEB
    dpkg -i $DEB
fi
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
echo "deploy ALL=(ALL) NOPASSWD:$1/env/scripts/deploy.sh" >> /tmp/sudoers.tmp
visudo -c -f /tmp/sudoers.tmp
if [ "$?" -eq "0" ]
then
    cp /tmp/sudoers.tmp /etc/sudoers
fi
rm /tmp/sudoers.tmp

puppet apply --environment $2 --hiera_config "$1/env/config/hiera.yaml" --modulepath "$1/env/modules" --templatedir "$1/config/templates" $1/env/manifests/site.pp
