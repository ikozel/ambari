require 'spec_helper'
require_relative 'ambari_provider_base_shared_examples'
require library file: 'chef_provider_ambari_cluster'
require library file: 'chef_resource_ambari_cluster'

class Chef
  class Provider
    RSpec.describe AmbariCluster, :ambari_provider_base,
                   matcher: :create_ambari_cluster,
                   recipe_resource: :ambari_cluster,
                   resource_class: Chef::Resource::AmbariCluster,
                   resource_name: 'yarn',
                   test_cookbook: 'ambari_test',
                   test_recipe: 'cluster'
  end
end
