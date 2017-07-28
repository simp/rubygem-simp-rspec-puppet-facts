## 2017-07-27 - Fix lots of things - 2.1.0
- Added Facter 2.5 facts
- `Vagrantfile` now uses official CentOS boxes from Atlus
- Updated facts
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
