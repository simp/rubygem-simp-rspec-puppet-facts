## 2018-03-08 - Add OracleLinux 6 and 7 factssets - 2.1.0
- Added factsets for OracleLinux 6 and 7
- Updated the fact collection Vagrantfile and scripts to handle non-GCE
  environments properly

## 2017-08-02 - Fix and normalize factsets - 2.0.1
The GCE-derived RHEL facts broke some spec tests due to changes in the
fqdns & IP addresses, which had been standardized as foo.example.com /
10.0.2.15. Additionally, the data structure from all CFacter (3.x) facts
was in an unusable format, and the data for some unsupported operating
systems and facter versions had gone stale.

To correct these issues, this patch:
  - Normalizes all data to include standard facterdb values
  - Corrects the data structure in facter 3.x factsets
  - Removes unsupported OSes (fedora) and Facter versions (3.1, 3.2)
  - Adds spec tests to check all factsets for structure and normalization

NOTE: It isn't possible to permanently set the fqdn or hostname of a GCE
VM(†), and temporarily changing them didn't affect all the facts. So
for the time being, the data structures are scrubbed back into place
using the gce_scrub_data.rb script.

† Ref: https://stackoverflow.com/questions/25313049/configuring-fqdn-for-gce-instance-on-startup

## 2017-07-27 - Fix lots of things - 2.0.0
- Added Facter 2.5 facts
- Added CFacter facts for all supported PE and SIMP versions
- `Vagrantfile` now uses official CentOS boxes from Atlus
- Updated scripts to collect facts for all 
- `on_supported_os` is now smart enough to avoid facterdb crashes by only
   asking for factsets that haven't been recorded for SIMP
  data that has been recorded for SIMP (avoids facterdb crashes)
- Added RHEL license support to `Vagrantfile`
  - **NOTE:** RHEL7 will not collect facts without a license
  - Updating RHEL boxes is now optional and off by defaulta
- Added fix suggestions to important fail messages
- Added Vagrant plugin check for `vagrant-vbguest`
  - Fixes fact syncing on the `centos/6` and `centos/7` boxes


## 2016-07-13 - Add auditd_version fact and update - 1.4.1
- Added auditd_version fact
- Added Facter 3.4 facts
- Updated facts

## 2016-05-22 - Collect facts for Fedora 23 - 1.4.0
- Updated `Vagrantfile` to handle both Fedora and EL
- Updated the collection script to handle both Fedora and EL

## 2016-05-07 - Collect SIMP module facts from running systems - 1.3.0
- Adapted `Vagrantfile` from facterdb to collect facts from any modules left
  under `facts/modules`.
- Added new options `:selinux_mode` and `:extra_facts_immutable`.
- SELinux-related facts are managed by logic (configurable with
  `:selinux_mode`), including any existing `:tmp_mount_*` facts.

## 2015-07-07 - Relax dependencies 1.0.1
- Fixed bug where the facter dep was too stringent for bundler to resolve in
  certain Travis tests.

## 2015-06-29 - First Release 1.0.0
- Happy Birthday!
