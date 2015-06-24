require 'spec_helper'
require 'recursive_open_struct'
require library file: 'ambari_blueprint_equator'
require library file: 'ambari_structure'

module Ambari
  RSpec.describe BlueprintEquator do
    context 'instance' do
      shared_context 'equal_structures', :equal_structures do
        let :remote_structure do local_structure end
      end

      let :component_1 do Ambari::Structure.new Hash['name', 'foo'] end

      let :component_2 do Ambari::Structure.new Hash['name', 'bar'] end

      let :components do [component_1, component_2] end

      let :local_configuration_1 do
        Ambari::Structure.new Hash['type-2', {'key' => 'value'}]
      end

      let :local_configuration_2 do
        Ambari::Structure.new Hash['type-1', {'key' => 'value'}]
      end

      let :local_configurations do
        [local_configuration_1, local_configuration_2]
      end

      let :local_host_group_1 do
        Ambari::Structure.new Hash[
          'name', 'foo',
          'components', components,
          'configurations', local_configurations,
          'cardinality', '1'
        ]
      end

      let :local_host_group_2 do
        Ambari::Structure.new Hash[
          'name', 'bar',
          'components', components,
          'configurations', local_configurations
        ]
      end

      let :local_host_groups do [local_host_group_1, local_host_group_2] end

      let :instance_arguments do
        [{remote: remote_structure, local: local_structure}]
      end

      let :local_blueprints do
        Ambari::Structure.new Hash[
          'stack_name', 'bar',
          'stack_version', '1.0'
        ]
      end

      let :local_fields do
        {
          'Blueprints' => local_blueprints,
          'configurations' => local_configurations,
          'host_groups' => local_host_groups
        }
      end

      let :local_structure do Ambari::Structure.new local_fields end

      let :normalized_host_group_1 do
        Ambari::Structure.new Hash[
          'name', 'foo',
          'components', components.reverse,
          'configurations', local_configurations.reverse,
          'cardinality', '1'
        ]
      end

      let :normalized_host_group_2 do
        Ambari::Structure.new Hash[
          'name', 'bar',
          'components', components.reverse,
          'configurations', local_configurations.reverse,
          'cardinality', 'NOT SPECIFIED'
        ]
      end

      let :remote_blueprints do
        Ambari::Structure.new Hash[
          'blueprint_name', 'foo',
          'stack_name', 'biz',
          'stack_version', '1.0'
        ]
      end

      let :remote_configuration_1 do
        Ambari::Structure.new Hash['type-4', {'key' => 'value'}]
      end

      let :remote_configuration_2 do
        Ambari::Structure.new Hash['type-3', {'key' => 'value'}]
      end

      let :remote_configurations do
        [remote_configuration_1, remote_configuration_2]
      end

      let :remote_fields do
        {
          'Blueprints' => remote_blueprints,
          'configurations' => remote_configurations,
          'host_groups' => remote_host_groups
        }
      end

      let :remote_host_group_1 do
        Ambari::Structure.new Hash[
          'name', 'biz',
          'components', components,
          'configurations', remote_configurations,
          'cardinality', '1'
        ]
      end

      let :remote_host_group_2 do
        Ambari::Structure.new Hash[
          'name', 'baz',
          'components', components,
          'configurations', remote_configurations
        ]
      end

      let :remote_host_groups do [remote_host_group_1, remote_host_group_2] end

      let :remote_structure do Ambari::Structure.new remote_fields end

      context 'public' do
        describe '#equivalent?', :method do
          before :example do
            allow(instance).to receive(:equal_top_level_configurations?)
              .and_return metadata[:equal_top_level_configurations] || false

            allow(instance).to receive(:equal_host_groups?)
              .and_return metadata[:equal_host_groups] || false

            allow(instance).to receive(:equal_blueprints?)
              .and_return metadata[:equal_blueprints] || false
          end

          context 'when top level configurations are equal',
                  :equal_top_level_configurations do
            context 'when host groups are equal', :equal_host_groups do
              context 'when blueprints are equal', :equal_blueprints do
                it { is_expected.to be true }
              end

              context 'when blueprints are not equal' do
                it { is_expected.to be false }
              end
            end

            context 'when host groups are not equal' do
              it { is_expected.to be false }
            end
          end

          context 'when top level configurations are not equal' do
            it { is_expected.to be false }
          end
        end
      end

      context 'private' do
        describe '#equal_blueprints?', :method do
          before :example do
            allow(instance)
              .to receive(:normalized_blueprints).and_return *responses
          end

          context 'when Blueprints are equal' do
            let :responses do remote_blueprints end

            it { is_expected.to be true }
          end

          context 'when Blueprints are not equal' do
            let :responses do [remote_blueprints, local_blueprints] end

            it { is_expected.to be false }
          end
        end

        describe '#equal_configurations?', :method,
                 arguments: {remote: nil, local: nil} do
          before :example do
            allow(instance)
              .to receive(:normalized_configurations).and_return *responses
          end

          context 'when configurations are equal' do
            let :responses do [remote_configurations] end

            it { is_expected.to be true }
          end

          context 'when configurations are not equal' do
            let :responses do [remote_configurations, local_configurations] end

            it { is_expected.to be false }
          end
        end

        describe '#equal_host_groups?', :method do
          before :example do
            allow(instance)
              .to receive(:normalized_host_groups).and_return *responses
          end

          context 'when host groups are equal' do
            let :responses do [remote_host_groups] end

            it { is_expected.to be true }
          end

          context 'when host groups are not equal' do
            let :responses do [remote_host_groups, local_host_groups] end

            it { is_expected.to be false }
          end
        end

        describe '#equal_top_level_configurations?', :method do
          before :example do
            allow(instance).to receive(:equal_configurations?)
              .and_return metadata[:equal_configurations] || false
          end

          context 'when configurations are equal', :equal_configurations do
            it { is_expected.to be true }
          end

          context 'when configurations are not equal' do
            it { is_expected.to be false }
          end
        end

        describe '#initialize', :procedural, :method do
          let :arguments do
            {remote: remote_structure, local: local_structure}
          end

          its :instance_variables do
            is_expected.to contain_exactly :@remote, :@local
          end
        end

        describe '#normalized_blueprints map', :method do
          let :arguments do {map: remote_blueprints} end

          it {
            is_expected.to eq 'stack_name' => 'biz', 'stack_version' => '1.0'
          }
        end

        describe '#normalized_configurations list', :method do
          context 'with defined configurations' do
            let :arguments do {list: local_configurations} end

            it { is_expected.to eq local_configurations.reverse }
          end

          context 'with undefined configurations', arguments: {list: nil} do
            it { is_expected.to be_empty }
          end
        end

        describe '#normalized_host_group member', :method do
          before :example do
            allow(instance).to receive(:normalized_named).and_return components

            allow(instance).to receive(:normalized_configurations)
              .and_return local_configurations
          end

          context 'with cardinality specified' do
            let :arguments do {member: local_host_group_1} end

            its :cardinality do is_expected.to eq '1' end
          end

          context 'with cardinality not specified' do
            let :arguments do {member: local_host_group_2} end

            its :cardinality do is_expected.to eq 'NOT SPECIFIED' end
          end
        end

        describe '#normalized_host_groups list', :method,
                 arguments: {list: nil} do
          before :example do
            allow(instance)
              .to receive(:normalized_named).and_return local_host_groups

            allow(instance).to receive(:normalized_host_group)
              .and_return local_host_group_1, local_host_group_2
          end

          it {
            is_expected.to contain_exactly local_host_group_1,
                                           local_host_group_2
          }
        end

        describe '#normalized_named list', :method do
          let :arguments do {list: components} end

          it { is_expected.to eq components.reverse }
        end
      end
    end
  end
end
