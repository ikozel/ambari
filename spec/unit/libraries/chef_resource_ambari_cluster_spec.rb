require 'spec_helper'
require library file: 'chef_resource_ambari_cluster'
require library file: 'ambari_cluster_equator'
require library file: 'ambari_structure'

class Chef
  class Resource
    RSpec.describe AmbariCluster do
      let :instance_arguments do ['foo', nil] end

      context 'class' do
        context 'public' do
          subject { described_class }

          its :resource_name do is_expected.to eq :ambari_cluster end
        end
      end

      context 'instance' do
        let :fields do {'foo' => 'bar'} end

        let :structure do
          object_double Ambari::Structure
            .new Hash['Requests', '', 'request_status', '']
        end

        before :example do
          instance.fields fields

          instance.password 'supersecret'

          instance.server 'localhost'

          instance.timeout_duration 1

          instance.user 'alice'
        end

        context 'public' do
          describe '#equal_to? resource', :method do
            let :arguments do {resource: instance } end

            let :equator do
              instance_double Ambari::ClusterEquator,
                              equivalent?: metadata[:equivalent] || false
            end

            before :example do
              allow(Ambari::ClusterEquator).to receive(:new).and_return equator
            end

            context 'with resource that is equal', :equivalent do
              it { is_expected.to be true }
            end

            context 'with resource that is not equal' do
              it { is_expected.to be false }
            end
          end

          describe '#post_to_server', :procedural, :method do
            before :example do
              allow(instance).to receive(:structure).and_return structure

              allow(structure).to receive(:post_to_server).and_yield fields
            end

            it {
              is_expected.to receive(:wait_for_request_in).with body: fields
            }
          end
        end

        context 'private' do
          describe '#category', :method do
            it { is_expected.to eq 'clusters' }
          end

          describe '#poll_status_of structure', :exception, :method do
            let :arguments do {structure: structure} end

            before :example do
              allow(structure).to receive(:follow).and_return structure

              allow(structure).to receive(:Requests).and_return structure

              allow(structure)
                .to receive(:request_status).and_return metadata.fetch :status
            end

            context 'when request is faster than timeout duration' do
              context 'when the request is successful',
                      status: 'COMPLETED' do
                it { is_expected.to_not raise_error }
              end

              context 'when the request is unsuccessful',
                      status: 'FAILED' do
                it { is_expected.to raise_error %r{request has failed} }
              end
            end

            context 'when request is slower than timeout duration',
                    status: 'PENDING' do
              it { is_expected.to raise_error TimeoutError }
            end

            context 'when the status is unrecognized', status: 'FOO' do
              it { is_expected.to raise_error %r{Unrecognized} }
            end
          end

          describe '#wait_for_request_in body', :procedural, :method,
                   arguments: {body: {}} do
            before :example do
              allow(Ambari::Structure).to receive(:new).and_return structure
            end

            it {
              is_expected.to receive(:poll_status_of).with structure: structure
            }
          end
        end
      end
    end
  end
end
