require 'spec_helper'

describe 'Simp::RspecPuppetFacts' do

  describe '#on_supported_os' do

    context 'Without parameter' do
      subject { on_supported_os() }

      context 'Without a metadata.json file' do
        it { expect { subject }.to raise_error(StandardError, /Can't find metadata.json/) }
      end

      context 'With a metadata.json file' do
        context 'that is broken' do
          context 'with missing operatingsystem_support section' do
            before :all do
              fixture = File.read('spec/fixtures/metadata.json_with_missing_operatingsystem_support')
              File.expects(:file?).with('metadata.json').returns true
              File.expects(:read).with('metadata.json').returns fixture
            end

            it { expect { subject }.to raise_error(StandardError, /Unknown operatingsystem support/) }
          end
        end

        context 'that is valid' do
          before :all do
            fixture = File.read('spec/fixtures/metadata.json')
            File.expects(:file?).with('metadata.json').returns true
            File.expects(:read).with('metadata.json').returns fixture
          end

          it 'should return a hash' do
            expect( on_supported_os().class ).to eq Hash
          end
          it 'should have 4 elements' do
            expect(subject.size).to eq 4
          end
          it 'should return supported OS' do
            expect(subject.keys.sort).to eq [
              'centos-6-x86_64',
              'centos-7-x86_64',
              'redhat-6-x86_64',
              'redhat-7-x86_64',
            ]
          end
          it 'should return SIMP-specific OS facts' do
            expect(subject.map{ |os,data|  {os =>
              data.select{ |x,v| x == :uid_min || x == :grub_version }}}
            ).to eq [
              {"centos-6-x86_64"=>{:grub_version=>"0.97",       :uid_min=>"500"}},
              {"centos-7-x86_64"=>{:grub_version=>"2.02~beta2", :uid_min=>"500"}},
              {"redhat-6-x86_64"=>{:grub_version=>"0.97",       :uid_min=>"500"}},
              {"redhat-7-x86_64"=>{:grub_version=>"2.02~beta2", :uid_min=>"500"}},
            ]
          end
        end
      end
    end

    context 'When specifying supported_os' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "RedHat",
                "operatingsystemrelease" => [
                  "6",
                  "7"
                ]
              }
            ]
          }
        )
      }
      it 'should return a hash' do
        expect(subject.class).to eq Hash
      end
      it 'should have 2 elements' do
        expect(subject.size).to eq 2
      end
      it 'should return supported OS' do
        expect(subject.keys.sort).to eq [
          'redhat-6-x86_64',
          'redhat-7-x86_64',
        ]
      end
    end


    context 'When specifying wrong supported_os' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "Debian",
                "operatingsystemrelease" => [
                  "4",
                ],
              },
            ]
          }
        )
      }

      it 'should output warning message' do
        expect { subject }.to output(/Can't find facts for 'debian-4-x86_64'/).to_stderr
      end
    end
  end
end
