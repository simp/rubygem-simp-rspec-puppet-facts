#!/bin/bash
operatingsystemmajrelease=$1

export PATH=/opt/puppetlabs/bin:$PATH
export FACTERLIB=`ls -1d /vagrant/modules/*/lib/facter | tr '\n' ':'`

yum install epel-release -y
wget "https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${operatingsystemmajrelease}.noarch.rpm" -O /tmp/puppetlabs-release-pc1.rpm
rpm -ivh /tmp/puppetlabs-release-pc1.rpm

# Capture data for (c)facter 3.X
for puppet_agent_version in 1.2.2 1.2.7; do
  yum install -y puppet-agent-${puppet_agent_version} rubygems git ruby-devel
  output_file="/vagrant/$(facter --version | cut -c1-3)/$(facter operatingsystem | tr '[:upper:]' '[:lower:]')-$(facter operatingsystemmajrelease)-$(facter hardwaremodel).facts"
  mkdir -p $(dirname ${output_file})
  facter -j | tee ${output_file}
done

operatingsystem=$(facter operatingsystem | tr '[:upper:]' '[:lower:]')
operatingsystemmajrelease=$(facter operatingsystemmajrelease)
hardwaremodel=$(facter hardwaremodel)

PATH=/opt/puppetlabs/puppet/bin:$PATH
gem install bundler --no-ri --no-rdoc --no-format-executable
bundle install --path vendor/bundler

# Capture data for ruby-based facters
for version in 1.6.0 1.7.0 2.0.0 2.1.0 2.2.0 2.3.0 2.4.0; do
  FACTER_GEM_VERSION="~> ${version}" bundle update
  output_file="/vagrant/$(bundle exec facter --version | cut -c1-3)/${operatingsystem}-${operatingsystemmajrelease}-${hardwaremodel}.facts"
  mkdir -p $(dirname $output_file)
  echo $version | grep -q -E '^1\.' &&
    FACTER_GEM_VERSION="~> ${version}" bundle exec facter -j | bundle exec ruby -e 'require "json"; jj JSON.parse gets' | tee $output_file ||
    FACTER_GEM_VERSION="~> ${version}" bundle exec facter -j | tee $output_file
done
