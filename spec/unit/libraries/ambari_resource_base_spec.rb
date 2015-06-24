require 'spec_helper'
require library file: 'ambari_resource_base'
require library file: 'ambari_structure'

module Ambari
  module Resource
    RSpec.describe Base do
      let :instance_arguments do ['foo'] end

      let :structure do instance_double Ambari::Structure end

      before :all do
        described_class.resource_name = :foo
      end

      before :example do
        allow(Ambari::Structure).to receive(:new).and_return structure

        allow(instance).to receive(:category).and_return 'foos'

        instance.fields Hash['foo', 'bar']

        instance.password 'supersecret'

        instance.user 'alice'

        instance.server 'localhost'
      end

      context 'public instance method' do
        describe '#delete_from_server', :procedural, :method do
          subject { structure }

          it { is_expected.to receive :delete_from_server }
        end

        describe '#equal_to? resource', :exception, :method,
                 arguments: {resource: nil} do
          it { is_expected.to raise_error %r{implemented by} }
        end

        describe '#href', :method do
          it { is_expected.to eq 'http://localhost:8080/api/v1/foos/foo' }
        end

        describe '#post_to_server', :exception, :method do
          it { is_expected.to raise_error %r{implemented by} }
        end

        describe '#structure', :method do
          it { is_expected.to eq structure }
        end

        describe '#sync_from_server', :method do
          it { is_expected.to eq structure }
        end
      end

      context 'private instance method' do
        describe '#category', :method, :exception do
          before :example do
            allow(instance).to receive(method_name).and_call_original
          end

          it { is_expected.to raise_error %r{must be implemented} }
        end
      end
    end
  end
end
