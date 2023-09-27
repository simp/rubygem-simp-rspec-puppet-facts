## 2023-09-27 / 3.8.1 - Fix GHA release workflow
- Fix GHA release workflow

## 2023-09-27 / 3.8.0 - Add facter 4.5 factsets
- Add facter 4.5 factsets
- Add Rocky 9 and OEL 9 facts
- Update boxes for beaker nodesets
- Bump `vagrant_memsize` to 2GB for all nodesets to improve performance

## 2023-08-28 / 3.7.0 - Fix Ruby 3 compatibility
- Replace various calls to `File.exists?` with `File.exist?`
- Update gem dependencies

## 2023-05-15 / 3.6.3 - Update facter 4.4 factsets with legacy facts
- updated 4.4 factsets with legacy facts
- modified beaker task to include legacy facts in the future

## 2023-05-15 / 3.6.2 - Add initial facter 4.4 factsets
- added initial 4.4 factsets, sans win2016
- updated Rocky box

## 2023-04-17 / 3.6.1 - Ignore upstream facterdb factsets
- Simply ignores non-simp factsets by not merging results
- This is quick measure to get simp/simp spec tests working with missing
  factsets from 3.6.0
- Follow-on issue should remove all logic to to with lookups from default
  facterdb data sources


## 2023-02-16 / 3.6.0 - Add initial facter 4.3 factsets
- Added initial facter 4.3 factsets

## 2022-06-24 / 3.5.1 - Update facter 3 facts
- Updated all facter 3 fact sets (2.X directory)
  - Added Alma, Rocky, and new Windows facts
  - Added EL9 facts

## 2022-06-24 / 3.5.0 - Add facter 4 facts
- Added facter 4 fact sets
  - Added Alma, Rocky, and new Windows facts
  - Added EL9 facts

## 2022-06-20 / 3.4.0 - Allow versionless metadata
- Allow lists of supported OSs that are not pinned to specific versions
- Install puppet from gem if the facter version is explicitly set
  - Prep for facter 4.X support
  - Skip hosts where the gem install fails

## 2022-02-27 / 3.3.1 - Pin puppetlabs_spec_helper to ~> 3.0

## 2021-06-16 / 3.3.0 - Add partial matching to SIMP_FACTS_OS
- `SIMP_FACTS_OS` can now match factsets' full name, partial name, or regexp

## 2021-06-02 / 3.2.0 - Amazon 2, Rocky 8, and Updates
- Added Amazon Linux 2 facts
- Added Rocky 8 facts
- Updated all facts so that the 'modern' facts are in play

## 2020-02-25 / 3.1.1 - Update OEL facts
- The OEL fact sets were old to the point of breaking newer code

## 2020-02-23 / 3.1.0 - Windows facts and fixes
- Add Windows 2016 Facts
- Add Windows 2019 Facts
- Update Windows 2012 Facts
- Ensure that SELinux facts are not added to Windows nodes
- Work around a strange issue where the supported OSs would be empty and cause
  issues in jgrep. The workaround doesn't show any adverse effects during
  testing.

## 2020-02-10 / 3.0.0 - Fix gemspec versions
- Drop Ruby 1.9 support
- Fix '~> 0' notation
- Bumped minimum facter version to 2.5
- Fix Facter x.y version bug
- Updated supported/sampled Facter versions
- Dropped deprecated factsets

## 2020-01-14 - Exclude NAT interface from facts
- Updated acceptance test to disable NAT interface
- Broke out nodesets for OEL7 and OEL8
- Updated collected facts for:
  - RHEL 8
  - RHEL 7
  - CentOS 8
  - OEL8

## 2019-12-10 - Add OEL8 facts
- Added collected facts for OEL8

## 2019-10-15 - Add RHEL8 facts
- Added collected facts for:
  - RHEL 8
  - RHEL 7 (updated)
  - CentOS 8

## 2019-08-19 - Add basic Windows support
- Added a set of Server 2012 R2 facts
- Added a fact collector beaker job so that we don't have to wait for GCE
-
## 2019-03-11 - Add 'augeasversion' fact to all fact sets
- More modules are starting to need the 'augeasversion' fact so it was added to
  all fact sets for reference.

## 2018-10-25 - Add ssh_host_keys custom fact - 2.2.0
- Added a 'ssh_host_keys' custom fact to support the new fact that ships with
  the SIMP ssh module.

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
