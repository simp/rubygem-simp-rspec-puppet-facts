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
