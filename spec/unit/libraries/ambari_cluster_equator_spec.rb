require 'spec_helper'
require 'recursive_open_struct'
require 'restclient'
require library file: 'ambari_cluster_equator'
require library file: 'ambari_structure'

module Ambari
  RSpec.describe ClusterEquator do
    context 'instance' do
      let :instance_arguments do [{remote: remote, local: local}] end

      let :local do Ambari::Structure.new local_fields end

      let :local_fields do
        {
          'blueprint' => 'bar',
          'host_groups' => [
            {'hosts' => [{'fqdn' => 'foo'}, {'fqdn' => 'bar'}]},
            {'hosts' => [{'fqdn' => 'biz'}, {'fqdn' => 'biz'}]}
          ]
        }
      end

      let :remote do Ambari::Structure.new remote_fields end

      let :remote_fields do
        {
          'Clusters' => {'cluster_name' => 'foo'},
          'href' => 'http://localhost:8080/api/v1/clusters/foo',
          'hosts' => [
            {'Hosts' => {'host_name' => 'foo'}},
            {'Hosts' => {'host_name' => 'bar'}},
            {'Hosts' => {'host_name' => 'bar'}}
          ]
        }
      end

      before :example do
        allow(remote).to receive(:clone).and_return remote

        allow(remote).to receive(:follow).and_return remote
      end

      context 'public' do
        describe '#equivalent?', :method do
          before :example do
            allow(instance).to receive(
              :remote_components_equal_referenced_components?
            ).and_return metadata[:components_equal] || false

            allow(instance).to receive(:remote_hosts).and_return ['foo']

            allow(instance)
              .to receive(:local_hosts).and_return metadata[:local_hosts]
          end

          context 'when components are equal', :components_equal do
            context 'and hosts are equal', local_hosts: ['foo'] do
              it { is_expected.to be true }
            end

            context 'and hosts are not equal', local_hosts: ['bar'] do
              it { is_expected.to be false }
            end
          end

          context 'when components are not equal' do
            it { is_expected.to be false }
          end
        end
      end

      context 'private' do
        let :blueprint do Ambari::Structure.new blueprint_fields end

        let :blueprint_fields do
          {'host_groups' => [{'components' => [{'name' => 'foo'}]}]}
        end

        describe '#components_of blueprint', :method do
          let :arguments do {blueprint: blueprint} end

          it { is_expected.to contain_exactly ['foo'] }
        end

        describe '#components_of_host_groups member', :method do
          let :arguments do {member: blueprint.host_groups.first} end

          it { is_expected.to contain_exactly 'foo' }
        end

        describe '#follow href', :method,
                 arguments: {href: 'http://remotehost'} do
          its :href do is_expected.to eq 'http://remotehost' end
        end

        describe '#initialize remote, local', :procedural, :method do
          let :arguments do {remote: remote, local: local} end

          its :instance_variables do
            is_expected.to contain_exactly :@remote, :@local
          end
        end

        describe '#local_hosts', :method do
          it { is_expected.to contain_exactly 'bar', 'biz', 'foo' }
        end

        describe '#referenced_blueprint', :method do
          its :href do
            is_expected.to eq 'http://localhost:8080/api/v1/blueprints/bar'
          end
        end

        describe '#remote_as_blueprint', :method do
          its :href do
            is_expected.to eq 'http://localhost:8080/api/v1/clusters/foo' \
                                '?format=blueprint'
          end
        end

        describe '#remote_components_equal_referenced_components?', :method do
          context 'when the components are equal' do
            before :example do
              allow(instance).to receive(:components_of).and_return ['foo']
            end

            it { is_expected.to be true }
          end

          context 'when the components are not equal' do
            before :example do
              allow(instance)
                .to receive(:components_of).and_return ['foo'], ['bar']
            end

            it { is_expected.to be false }
          end
        end

        describe '#remote_hosts', :method do
          it { is_expected.to contain_exactly 'bar', 'foo' }
        end
      end
    end
  end
end
