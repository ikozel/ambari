RSpec.shared_examples 'Ambari::Provider::Base', :ambari_provider_base do
  let :chef_run do
    test_recipe = metadata.fetch :test_recipe

    runner.converge "#{ test_cookbook }::#{ test_recipe }"
  end

  let :current_resource do
    instance_double resource_class, equal_to?: false, name: resource_name,
                                    sync_from_server: true
  end

  let :delete_current_resource do
    run_ruby_block "delete current #{ resource_name }"
  end

  let :matcher do metadata.fetch :matcher end

  let :metadata do |example| example.metadata end

  let :new_resource do
    instance_double resource_class,
                    cookbook_name: test_cookbook, name: resource_name
  end

  let :post_new_resource do
    run_ruby_block "post new #{ resource_name }"
  end

  let :resource_class do metadata.fetch :resource_class end

  let :resource_name do metadata.fetch :resource_name end

  let :runner do
    recipe_resource = metadata.fetch :recipe_resource

    ChefSpec::ServerRunner.new step_into: recipe_resource
  end

  let :test_cookbook do metadata.fetch :test_cookbook end

  subject { chef_run }

  before :example do
    allow_any_instance_of(described_class)
      .to receive(:new_resource).and_return new_resource

    allow(new_resource).to receive(:clone).and_return current_resource
  end

  describe '#action :create', :chef_run do
    it { is_expected.to send matcher, resource_name }

    it {
      is_expected.to install_chef_gem('recursive-open-struct')
        .with compile_time: true, version: '~> 0.6.3'
    }

    it {
      is_expected.to install_chef_gem('rest-client').with compile_time: true,
                                                          version: '~> 1.8'
    }

    context 'with a current resource that does not exist' do
      before :example do
        allow(current_resource)
          .to receive(:sync_from_server).and_raise 'resource doesn\'t exist'
      end

      it { is_expected.to_not delete_current_resource }

      it { is_expected.to post_new_resource }
    end

    context 'with a current resource that exists' do
      context 'when it is up to date' do
        before :example do
          allow(current_resource).to receive(:equal_to?).and_return true
        end

        it { is_expected.to_not delete_current_resource }

        it { is_expected.to_not post_new_resource }
      end

      context 'when it is not up to date' do
        before :example do
          allow_any_instance_of(described_class)
            .to receive(:current_resource_exists?).and_return true, false
        end

        it { is_expected.to delete_current_resource }

        it { is_expected.to post_new_resource }
      end
    end
  end
end
