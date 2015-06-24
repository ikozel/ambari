require 'spec_helper'
require_relative 'ambari_provider_base_shared_examples'
require library file: 'chef_provider_ambari_blueprint'
require library file: 'chef_resource_ambari_blueprint'

class Chef
  class Provider
    RSpec.describe AmbariBlueprint, :ambari_provider_base,
                   matcher: :create_ambari_blueprint,
                   recipe_resource: :ambari_blueprint,
                   resource_class: Chef::Resource::AmbariBlueprint,
                   resource_name: 'multi-node-hdfs-yarn',
                   test_cookbook: 'ambari_test',
                   test_recipe: 'blueprint'
  end
end
