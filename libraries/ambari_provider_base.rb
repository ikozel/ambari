require 'chef/provider/lwrp_base'

module Ambari
  module Provider
    # Super class for Amari Chef Providers
    class Base < Chef::Provider::LWRPBase
      use_inline_resources

      action :create do
        {'recursive-open-struct' => '~> 0.6.3', 'rest-client' => '~> 1.8'}
          .each_pair { |name, version|
            chef_gem name do
              compile_time true
              version version
            end
          }

        ruby_block "delete current #{ current_resource.name }" do
          block { current_resource.delete_from_server }

          only_if { resource_update_required? }
        end

        ruby_block "post new #{ new_resource.name }" do
          block { new_resource.post_to_server }

          not_if { current_resource_exists? }
        end
      end

      def current_resource
        @current_resource ||= new_resource.clone
      end

      def current_resource_exists?
        current_resource.sync_from_server

        true
      rescue => exception
        raise unless exception.message.include? 'resource doesn\'t exist'

        false
      end

      def resource_update_required?
        current_resource_exists? and not
          current_resource.equal_to? resource: new_resource
      end

      def whyrun_supported?
        true
      end
    end
  end
end
