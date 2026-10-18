require 'spec_helper'

describe 'Simp::RspecPuppetFacts' do
  describe '#on_supported_os' do
    context 'Without parameter' do
      subject(:subject_on_supported_os) { on_supported_os }

      context 'Without a metadata.json file' do
        it { expect { subject_on_supported_os }.to raise_error(StandardError, %r{Can't find metadata\.json}) }
      end

      context 'With a metadata.json file' do
        before(:each) do
          Dir.chdir(File.join(File.dirname(__FILE__), '../fixtures'))
        end

        after(:each) do
          Dir.chdir(File.join(File.dirname(__FILE__), '../..'))
        end

        it 'returns a hash' do
          expect(on_supported_os.class).to eq Hash
        end
        it 'has 4 elements' do
          expect(subject_on_supported_os.size).to be >= 4
        end
        it 'returns supported OS' do
          expect(subject_on_supported_os.keys.sort).to include 'centos-9-x86_64'
          expect(subject_on_supported_os.keys.sort).to include 'centos-10-x86_64'
          expect(subject_on_supported_os.keys.sort).to include 'redhat-9-x86_64'
          expect(subject_on_supported_os.keys.sort).to include 'redhat-10-x86_64'
        end
        it 'returns SIMP-specific OS facts' do
          grub_version_facts = subject_on_supported_os.map do |os, data|
            { os => data.slice(:uid_min, :grub_version) }
          end
          expect(grub_version_facts).to include(
            { 'centos-10-x86_64' => { uid_min: '1000', grub_version: '2.12' } },
          )
          expect(grub_version_facts).to include(
            { 'centos-9-x86_64' => { uid_min: '1000', grub_version: '2.06' } },
          )
          expect(grub_version_facts).to include(
            { 'redhat-10-x86_64' => { uid_min: '1000', grub_version: '2.12' } },
          )
          expect(grub_version_facts).to include(
            { 'redhat-9-x86_64' => { uid_min: '1000', grub_version: '2.06' } },
          )
        end
      end
    end

    context 'When specifying supported_os=redhat-8-x86_64,redhat-9-x86_64' do
      subject(:subject_on_supported_os) do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'RedHat',
                'operatingsystemrelease' => [
                  '8',
                  '9',
                ]
              },
            ]
          },
        )
      end

      it 'returns a hash' do
        expect(subject_on_supported_os.class).to eq Hash
      end
      it 'has 2 elements' do
        expect(subject_on_supported_os.size).to eq 2
      end
      it 'returns supported OS' do
        expect(subject_on_supported_os.keys.sort).to eq [
          'redhat-8-x86_64',
          'redhat-9-x86_64',
        ]
      end
    end

    context 'When specifying SIMP_FACTS_OS=centos,redhat-9-x86_64' do
      subject(:subject_on_supported_os) do
        x = ENV['SIMP_FACTS_OS']
        ENV['SIMP_FACTS_OS'] = 'centos,redhat-9-x86_64'
        h = on_supported_os
        ENV['SIMP_FACTS_OS'] = x
        h
      end

      it 'returns a hash' do
        expect(subject_on_supported_os.class).to eq Hash
      end
      it 'has 3 elements' do
        expect(subject_on_supported_os.size).to eq 3
      end
      it 'returns supported OS' do
        expect(subject_on_supported_os.keys.sort).to eq [
          'centos-10-x86_64',
          'centos-9-x86_64',
          'redhat-9-x86_64',
        ]
      end
    end

    context 'When a supported OS has no SIMP factset' do
      subject(:subject_on_supported_os) do
        on_supported_os(
          {
            supported_os: [
              { 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['9'] },
              { 'operatingsystem' => 'Ubuntu', 'operatingsystemrelease' => ['24.04'] },
            ],
            extra_facts: { custom_fact: 'extra' },
            extra_facts_immutable: { immutable_fact: 'immutable' },
          },
        )
      end

      before(:each) do
        Simp::RspecPuppetFacts.warned_fallback_os.clear
        allow(self).to receive(:warn)
      end

      it 'returns the SIMP factset and the FacterDB factset' do
        expect(subject_on_supported_os.keys).to contain_exactly('redhat-9-x86_64', 'ubuntu-24.04-x86_64')
      end

      it 'deep-symbolizes the FacterDB facts like the SIMP factsets' do
        facts = subject_on_supported_os['ubuntu-24.04-x86_64']
        expect(facts.keys).to all(be_a(Symbol))
        expect(facts[:os][:family]).to eq 'Debian'
        expect(facts[:os][:release][:major]).to eq '24.04'
      end

      it 'applies extra_facts and extra_facts_immutable to the FacterDB facts' do
        facts = subject_on_supported_os['ubuntu-24.04-x86_64']
        expect(facts[:custom_fact]).to eq 'extra'
        expect(facts[:immutable_fact]).to eq 'immutable'
      end

      it 'keeps using the SIMP factset for releases that have one' do
        expect(subject_on_supported_os['redhat-9-x86_64']).to eq(
          on_supported_os(
            {
              supported_os: [{ 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['9'] }],
              extra_facts: { custom_fact: 'extra' },
              extra_facts_immutable: { immutable_fact: 'immutable' },
            },
          )['redhat-9-x86_64'],
        )
      end

      it 'warns once per OS release that FacterDB facts are used' do
        expect(self).to receive(:warn).with(%r{No SIMP factsets for ubuntu-24\.04-x86_64; using the rspec-puppet-facts}).once
        subject_on_supported_os
        subject_on_supported_os
      end
    end

    context 'When specifying wrong supported_os' do
      subject(:subject_on_supported_os) do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Debian',
                'operatingsystemrelease' => [
                  'X',
                ],
              },
            ]
          },
        )
      end

      it 'outputs warning message', skip: 'rspec issue: No longer able to catch message on stdout or stderr' do
        expect { subject_on_supported_os }.to output(%r{No facts were found in the FacterDB}).to_stdout
      end
    end
  end

  describe '#selinux_facts' do
    context 'When :enforcing' do
      subject(:subject_selinux_facts) { selinux_facts(:enforcing, {}) }

      it 'returns a hash' do
        expect(subject_selinux_facts.class).to eq Hash
      end
      context 'when facts include `:tmp_mount_dev_shm => "rw,noatime"`' do
        subject(:subject_selinux_facts) { selinux_facts(:enforcing, { tmp_mount_dev_shm: 'rw,noatime' }) }

        it 'has a :tmp_mount_dev_shm key' do
          expect(subject_selinux_facts.key?(:tmp_mount_dev_shm)).to be true
        end
        it ':tmp_mount_dev_shm should include "seclabel"' do
          expect(subject_selinux_facts[:tmp_mount_dev_shm]).to match(%r{\bseclabel\b})
        end
      end
      context 'when facts include `:tmp_mount_dev_shm => "rw,noatime,seclabel"`' do
        subject(:subject_selinux_facts) { selinux_facts(:enforcing, { tmp_mount_dev_shm: 'rw,noatime,seclabel' }) }

        it ':tmp_mount_dev_shm should include "seclabel"' do
          expect(subject_selinux_facts[:tmp_mount_dev_shm]).to match(%r{\bseclabel\b})
        end
      end
    end

    context 'When :permissive' do
      subject(:subject_selinux_facts) { selinux_facts(:permissive, {}) }

      it 'returns a hash' do
        expect(subject_selinux_facts.class).to eq Hash
      end
      context 'when facts include `:tmp_mount_dev_shm => "rw,noatime"`' do
        subject(:subject_selinux_facts) { selinux_facts(:permissive, { tmp_mount_dev_shm: 'rw,noatime' }) }

        it 'has a :tmp_mount_dev_shm key' do
          expect(subject_selinux_facts.key?(:tmp_mount_dev_shm)).to be true
        end
        it ':tmp_mount_dev_shm should include "seclabel"' do
          expect(subject_selinux_facts[:tmp_mount_dev_shm]).to match(%r{\bseclabel\b})
        end
      end
      context 'when facts include `:tmp_mount_dev_shm => "rw,noatime,seclabel"`' do
        subject(:subject_selinux_facts) { selinux_facts(:permissive, { tmp_mount_dev_shm: 'rw,noatime,seclabel' }) }

        it ':tmp_mount_dev_shm should include "seclabel"' do
          expect(subject_selinux_facts[:tmp_mount_dev_shm]).to match(%r{\bseclabel\b})
        end
      end
    end

    context 'When :disabled' do
      subject(:subject_selinux_facts) { selinux_facts(:disabled, {}) }

      it 'returns a hash' do
        expect(subject_selinux_facts.class).to eq Hash
      end
      context 'when facts include `:tmp_mount_dev_shm => "rw,noatime"`' do
        subject(:subject_selinux_facts) { selinux_facts(:disabled, { tmp_mount_dev_shm: 'rw,noatime' }) }

        it 'has a :tmp_mount_dev_shm key' do
          expect(subject_selinux_facts.key?(:tmp_mount_dev_shm)).to be true
        end
        it ':tmp_mount_dev_shm should not include "seclabel"' do
          expect(subject_selinux_facts[:tmp_mount_dev_shm]).not_to match(%r{\bseclabel\b})
        end
      end
      context 'when facts include `:tmp_mount_dev_shm => "rw,noatime,seclabel"`' do
        subject(:subject_selinux_facts) { selinux_facts(:disabled, { tmp_mount_dev_shm: 'rw,noatime,seclabel' }) }

        it ':tmp_mount_dev_shm should not include "seclabel"' do
          expect(subject_selinux_facts[:tmp_mount_dev_shm]).not_to match(%r{\bseclabel\b})
        end
      end
    end
  end
end
