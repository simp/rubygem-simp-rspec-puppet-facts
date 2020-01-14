require 'spec_helper_acceptance'

test_name 'we just want the facts'

describe 'look out muppets' do
  hosts.each do |host|
    let(:host_fqdn) { fact_on(host, 'fqdn') }
    let(:collection_dir) { 'collected_facts' }
    let(:os_info) { fact_on(host, 'os') }
    let(:os_arch) { fact_on(host, 'architecture') }

    let(:fact_collection) { File.join(collection_dir, [os_info['name'], os_info['release']['full'].gsub(/\s/,'_'), os_arch].join('-').downcase + '.facts') }

    let(:host_data) { JSON.load(File.read(fact_collection)) }

    context "on #{host}" do
      before(:all) do
        @output = []
      end

      it 'should install the simp_core module' do
        on(host, 'puppet module install simp/simp_core')
      end

      it 'should collect valid fact data' do
        # Delete NAT interface so facter does not report randomly generated ip addresses
        if fact_on(host, 'ipaddress_eth1') != '' and fact_on(host, 'operatingsystemmajrelease') != '6'
          on host, 'nmcli connection delete id System\ eth1'
        end
        if fact_on(host, 'ipaddress_enp0s8') != '' and fact_on(host, 'operatingsystemmajrelease') != '6'
          on host, 'nmcli connection delete id System\ enp0s8'
        end
        # Stupid RSpec tricks
        output = on(host, 'puppet facts --render-as json').stdout

        expect{@output << JSON.parse(output)['values']}.to_not raise_error
      end

      # This should work regardless of OS
      it 'should have the "puppet_settings" fact' do
        expect(@output.first['puppet_settings']).to be_a(Hash)
      end

      it 'should clean up the data' do
        str_data = JSON.generate(@output.first)

        str_data = str_data.gsub(fact_on(host, 'fqdn'), 'foo.example.com').
          gsub(fact_on(host, 'domain'), 'example.com').
          gsub(%(:"#{fact_on(host, 'hostname')}"), ':"foo"').
          gsub(%(:"#{fact_on(host, 'networking')['ip']}"), ':"10.0.2.15"').
          gsub(%(:"#{fact_on(host, 'networking')['netmask']}"), ':"255.255.0.0"').
          gsub(%(:"#{fact_on(host, 'networking')['network']}"), ':"10.0.2.0"').
          gsub(%r("dhcp":"(.+?)"), '"dhcp":"10.0.2.2"')

        expect{JSON.parse(str_data)}.to_not raise_error

        FileUtils.mkdir_p(collection_dir) unless File.directory?(collection_dir)
        File.open(fact_collection, 'w'){ |fh| fh.puts(JSON.pretty_generate(JSON.parse(str_data))) }
      end
    end
  end
end
