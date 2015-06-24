require 'spec_helper'
require 'recursive_open_struct'
require 'restclient'
require library file: 'ambari_structure'

module Ambari
  RSpec.describe Structure do
    let :escaped_json do '"{\"foo\":\"bar\"}"' end

    let :hash do {'foo' => 'bar'} end

    let :instance_arguments do
      [
        hash,
        {href: 'http://localhost', user: 'alice', password: 'supersecret'}
      ]
    end

    let :response do
      instance_double RestClient::Response, body: '{"foo":"bar"}'
    end

    let :uri do
      instance_double URI::HTTP,
                      :user= => true, :password= => true,
                      to_s: 'http://alice:supersecret@localhost'
    end

    before :example do
      allow(response).to receive(:return!).and_return response
      allow(RestClient).to receive(:get).and_yield response
      allow(RestClient).to receive(:post).and_yield response
      allow(URI).to receive(:parse).and_return uri
    end

    context 'public instance method' do
      describe '#delete_from_server', :procedural, :method do
        it { is_expected.to receive(:issue).with request: :delete }
      end

      describe '#follow', :method do
        it { is_expected.to be_kind_of instance.class }
      end

      describe '#post_to_server', :procedural, :method do
        it { is_expected.to receive :issue }
      end
    end

    context 'private instance method' do
      describe '#arguments_for request', :method do
        context 'when request is POST', arguments: {request: :post} do
          it {
            is_expected.to contain_exactly escaped_json,
                                           content_type: :json,
                                           'X-Requested-By' => 'ambari-cookbook'
          }
        end
      end

      describe '#authenticated_url', :method do
        it { is_expected.to eq 'http://alice:supersecret@localhost' }
      end

      describe '#escaped_json', :method do
        it { is_expected.to eq escaped_json }
      end

      describe '#fields_from hash, arguments', :method do
        context 'when requested to load remote fields',
                arguments: {hash: {}, arguments: {remote: true}} do
          it { is_expected.to eq hash }
        end

        context 'when not requested to load remote fields' do
          let :arguments do {hash: hash, arguments: {}} end

          it { is_expected.to eq hash }
        end
      end

      describe '#initialize hash, arguments', :procedural, :method do
        it { is_expected.to respond_to :foo }
      end

      describe '#issue', :exception, :method, arguments: {request: :get} do
        context 'when the request is successful' do
          it { is_expected.to yield_with_args hash }
        end

        context 'when the request is unsuccessful', :exception do
          before :example do
            allow(RestClient).to receive(:send).and_raise RestClient::Exception
          end

          it { is_expected.to raise_error %r{Issuing get to http://localhost} }
        end
      end

      describe '#memoize', :procedural, :method,
               arguments: {
                 arguments: {
                   href: 'http://localhost', user: 'alice',
                   password: 'supersecret'
                 }
               } do
        context 'instance variables' do
          its :instance_variables do is_expected.to include :@href end
        end

        context 'class variables' do
          subject { instance.class }

          its :class_variables do
            is_expected.to contain_exactly :@@user, :@@password
          end
        end
      end

      describe '#remote_fields', :method do
        it { is_expected.to eq hash }
      end
    end
  end
end
