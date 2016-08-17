#!/bin/bash
operatingsystem=$( echo "$1" | cut -f1 -d' ' )
operatingsystemmajrelease=$( echo "$1" | cut -f2 -d' ' )

if [ -z "$operatingsystem" ] || [ -z "$operatingsystemmajrelease" ]; then
  echo "You must pass an operating system and version to $0"
  exit 1
fi

if [ "$operatingsystem" == "$operatingsystemmajrelease" ]; then
  echo "Your OS is the same as your version and this does not make sense"
  exit 1
fi

export PATH=/opt/puppetlabs/bin:$PATH
export FACTERLIB=`ls -1d /vagrant/modules/*/lib/facter | tr '\n' ':'`

which dnf > /dev/null 2>&1
if [ $? -eq 0 ]; then
  rpm_cmd='dnf --best --allowerasing'
else
  rpm_cmd='yum --skip-broken'
fi

if [ "${operatingsystem}" != 'fedora' ]; then
  plabs_ver='el'

  $rpm_cmd install -y --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-${operatingsystemmajrelease}.noarch.rpm
else
  plabs_ver=$operatingsystem
fi

$rpm_cmd install -y --nogpgcheck "https://yum.puppetlabs.com/puppetlabs-release-pc1-${plabs_ver}-${operatingsystemmajrelease}.noarch.rpm"

# Prereqs
$rpm_cmd install -y facter rubygem-bundler git augeas-devel \
  libicu-devel libxml2 libxml2-devel libxslt libxslt-devel \
  gcc gcc-c++ ruby-devel audit

rpm -qi puppet > /dev/null &&  $rpm_cmd remove -y puppet

# Capture data for (c)facter 3.X
for puppet_agent_version in 1.2.2 1.2.7 1.5.3 1.6.0; do
  rpm -qi puppet-agent > /dev/null && $rpm_cmd remove -y puppet-agent
  $rpm_cmd install -y puppet-agent-$puppet_agent_version
  facter_version=$( facter --version | cut -c1-3 )
  output_dir="/vagrant/${facter_version}"
  echo
  echo "---------------- facter: '${facter_version}'  puppet agent version: '${puppet_agent_version}'"
  echo
  output_file="$( facter operatingsystem | tr '[:upper:]' '[:lower:]' )-$( facter operatingsystemmajrelease )-$( facter hardwaremodel ).facts"
  mkdir -p $output_dir
  puppet facts | tee "${output_dir}/${output_file}"
done

operatingsystem=$( facter operatingsystem | tr '[:upper:]' '[:lower:]' )
operatingsystemmajrelease=$( facter operatingsystemmajrelease )
hardwaremodel=$( facter hardwaremodel )

rpm -qi puppet-agent > /dev/null && $rpm_cmd remove -y puppet-agent

export PUPPET_VERSION="~> 3.7"

#PATH=/opt/puppetlabs/puppet/bin:$PATH
gem install bundler --no-ri --no-rdoc --no-format-executable
bundle install --path vendor/bundler

# Capture data for ruby-based facters
for version in 1.7.0 2.0.0 2.1.0 2.2.0 2.3.0 2.4.0; do
  FACTER_GEM_VERSION="~> ${version}" PUPPET_VERSION="~> 3.7" bundle update
  os_string="$(FACTER_GEM_VERSION="~> ${version}" PUPPET_VERSION="~> 3.7" bundle exec facter --version | cut -c1-3)/${operatingsystem}-${operatingsystemmajrelease}-${hardwaremodel}"
  echo
  echo
  echo  ============== ${os_string} ================
  echo
  echo
  output_file="/vagrant/${os_string}.facts"
  mkdir -p $( dirname $output_file )
  FACTER_GEM_VERSION="~> ${version}" PUPPET_VERSION="~> 3.7" bundle exec ruby /vagrant/scripts/get_facts.rb | tee $output_file
done
