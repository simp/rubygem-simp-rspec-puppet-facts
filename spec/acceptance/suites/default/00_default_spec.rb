require 'spec_helper_acceptance'

test_name 'we just want the facts'

describe 'look out muppets' do
  hosts.each do |host|
    let(:host_fqdn) { fact_on(host, 'fqdn') }
    let(:collection_dir) { 'collected_facts' }
    let(:os_info) { fact_on(host, 'os') }
    let(:os_arch) { fact_on(host, 'architecture') }

    let(:fact_collection) { File.join(collection_dir, [os_info['name'], os_info['release']['major'].gsub(%r{\s}, '_'), os_arch].join('-').downcase + '.facts') }

    let(:host_data) { JSON.parse(File.read(fact_collection)) }

    # rubocop:disable RSpec/InstanceVariable
    context "on #{host}" do
      before(:all) do
        @output = []
      end

      it 'installs the simp_core module' do
        on(host, 'puppet module install simp/simp_core')
      end

      it 'disables the secondary network interface' do
        interfaces = fact_on(host, 'interfaces').strip.split(',')

        ifaces = {
          'eth1'       => 'ip link set eth1 down',
          'enp0s8'     => 'ip link set enp0s8 down',
          'Ethernet 2' => 'netsh interface set interface "Ethernet 2" disable'
        }

        ifaces.each_key do |iface|
          on(host, ifaces[iface]) if interfaces.include?(iface)
        end
      end

      it 'collects valid fact data' do
        output = on(host, 'puppet facts show --show-legacy --render-as json').stdout.lines.last

        expect {
          parsed_output = JSON.parse(output)

          # Something changed in the puppet facts output so handle both cases
          @output.push(parsed_output['values'] || parsed_output)
        }.not_to raise_error
      end

      # This should work regardless of OS
      it 'has the "puppet_settings" fact' do
        expect(@output.first['puppet_settings']).to be_a(Hash)
      end

      it 'cleans up the data' do
        str_data = JSON.generate(@output.first)

        str_data = str_data.gsub(fact_on(host, 'fqdn'), 'foo.example.com')
                           .gsub(fact_on(host, 'domain'), 'example.com')
                           .gsub(%(:"#{fact_on(host, 'hostname')}"), ':"foo"')
                           .gsub(%(:"#{fact_on(host, 'networking')['ip']}"), ':"10.0.2.15"')
                           .gsub(%(:"#{fact_on(host, 'networking')['netmask']}"), ':"255.255.0.0"')
                           .gsub(%(:"#{fact_on(host, 'networking')['network']}"), ':"10.0.2.0"')
                           .gsub(%r{"dhcp":"(.+?)"}, '"dhcp":"10.0.2.2"')

        expect { JSON.parse(str_data) }.not_to raise_error

        FileUtils.mkdir_p(collection_dir) unless File.directory?(collection_dir)
        File.open(fact_collection, 'w') { |fh| fh.puts(JSON.pretty_generate(JSON.parse(str_data))) }
      end
    end
    # rubocop:enable RSpec/InstanceVariable
  end
end
