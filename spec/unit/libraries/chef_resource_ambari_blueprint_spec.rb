require 'spec_helper'
require library file: 'chef_resource_ambari_blueprint'
require library file: 'ambari_structure'
require library file: 'ambari_blueprint_equator'

class Chef
  class Resource
    RSpec.describe AmbariBlueprint do
      let :instance_arguments do ['foo'] end

      context 'class' do
        context 'public' do
          subject { described_class }

          its :resource_name do is_expected.to eq :ambari_blueprint end
        end
      end

      context 'instance' do
        context 'public' do
          let :structure do instance_double Ambari::Structure end

          before :example do
            allow(instance).to receive(:structure).and_return structure
          end

          describe '#equal_to? resource', :method do
            let :arguments do {resource: resource} end

            let :equator do
              instance_double Ambari::BlueprintEquator,
                              equivalent?: metadata[:equivalent] || false
            end

            let :resource do
              instance_double Ambari::Resource::Base, structure: structure
            end

            before :example do
              allow(Ambari::BlueprintEquator)
                .to receive(:new).and_return equator
            end

            context 'with resource that is equal', :equivalent do
              it { is_expected.to be true }
            end

            context 'with resource that is not equal' do
              it { is_expected.to be false }
            end
          end

          describe '#post_to_server', :procedural, :method do
            subject { structure }

            it { is_expected.to receive :post_to_server }
          end
        end

        context 'private' do
          describe '#category', :method do
            it { is_expected.to eq 'blueprints' }
          end
        end
      end
    end
  end
end
