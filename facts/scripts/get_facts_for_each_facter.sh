#!/bin/bash
operatingsystemmajrelease=$1
export PATH=/opt/puppetlabs/bin:$PATH
export FACTERLIB=`ls -1d /vagrant/modules/*/lib/facter | tr '\n' ':'`

wget "https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${operatingsystemmajrelease}.noarch.rpm" -O /tmp/puppetlabs-release-pc1.rpm
rpm -ivh /tmp/puppetlabs-release-pc1.rpm

# Because `yum install epel-release -y` doesn't work for RedHat:
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-${operatingsystemmajrelease}.noarch.rpm
rpm -Uvh epel-release-latest-${operatingsystemmajrelease}*.rpm


# Capture data for (c)facter 3.X
for puppet_agent_version in 1.2.2 1.2.7; do
  yum install -y puppet-agent-${puppet_agent_version} rubygems git ruby-devel
  output_dir="/vagrant/$(facter --version | cut -c1-3)"
  output_file="$(facter operatingsystem | tr '[:upper:]' '[:lower:]')-$(facter operatingsystemmajrelease)-$(facter hardwaremodel).facts"
  mkdir -p $output_dir
  puppet facts | tee "${output_dir}/${output_file}"
done

operatingsystem=$(facter operatingsystem | tr '[:upper:]' '[:lower:]')
operatingsystemmajrelease=$(facter operatingsystemmajrelease)
hardwaremodel=$(facter hardwaremodel)

PATH=/opt/puppetlabs/puppet/bin:$PATH
gem install bundler --no-ri --no-rdoc --no-format-executable
bundle install --path vendor/bundler

# Capture data for ruby-based facters
for version in 1.7.0 2.0.0 2.1.0 2.2.0 2.3.0 2.4.0; do
  FACTER_GEM_VERSION="~> ${version}" bundle update
  os_string="$(bundle exec facter --version | cut -c1-3)/${operatingsystem}-${operatingsystemmajrelease}-${hardwaremodel}"
  echo
  echo
  echo ============== ${os_string} ================
  echo
  echo
  output_file="/vagrant/${os_string}.facts"
  mkdir -p $(dirname $output_file)
  FACTER_GEM_VERSION="~> ${version}" bundle exec ruby /vagrant/scripts/get_facts.rb | tee $output_file
done
