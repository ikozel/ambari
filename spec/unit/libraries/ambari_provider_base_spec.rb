require 'spec_helper'
require library file: 'ambari_provider_base'
require library file: 'ambari_resource_base'

module Ambari
  module Provider
    RSpec.describe Base do
      let :current_resource do new_resource end

      let :instance_arguments do [new_resource, nil] end

      let :new_resource do
        instance_double Ambari::Resource::Base, sync_from_server: true
      end

      context 'instance' do
        context 'public' do
          before :example do
            allow(new_resource).to receive(:clone).and_return new_resource
          end

          describe '#current_resource', :method do
            it { is_expected.to eq new_resource }
          end

          describe '#current_resource_exists?', :method do
            context 'when resource does exist' do
              before :example do
                allow(current_resource)
                  .to receive(:sync_from_server).and_return true
              end

              it { is_expected.to be true }
            end

            context 'when resource does not exist' do
              before :example do
                allow(current_resource).to receive(:sync_from_server)
                  .and_raise 'resource doesn\'t exist'
              end

              it { is_expected.to be false }
            end
          end

          describe '#resource_update_required?', :method do
            before :example do
              allow(instance).to receive(:current_resource_exists?)
                .and_return metadata[:current_exists] || false

              allow(current_resource).to receive(:equal_to?)
                .and_return metadata[:equal_resources] || false
            end

            context 'when current resource exists', :current_exists do
              context 'and current resource is equal to new resource',
                      :equal_resources do
                it { is_expected.to be false }
              end

              context 'and current resource is not equal to new resource' do
                it { is_expected.to be true }
              end
            end

            context 'when current resource does not exist' do
              it { is_expected.to be false }
            end
          end

          describe '#whyrun_supported?', :method do
            it { is_expected.to be true }
          end
        end
      end
    end
  end
end
