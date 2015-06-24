require 'chef/resource/lwrp_base'

require_relative 'ambari_structure'

module Ambari
  module Resource
    # Super class for Ambari Chef Resources
    class Base < Chef::Resource::LWRPBase
      actions :create
      default_action :create

      attribute :fields, kind_of: Hash, required: true
      attribute :password, kind_of: String, required: true
      attribute :server, kind_of: String, required: true
      attribute :user, kind_of: String, required: true

      def delete_from_server
        structure.delete_from_server
      end

      def equal_to? resource:
        fail "#equal_to? #{ resource.class } must be implemented by " \
               "#{ self.class }"
      end

      def post_to_server
        fail "#post_to_server must be implemented by #{ self.class }"
      end

      def structure
        @structure ||= ambari_structure.new fields,
                                            href: href, user: user,
                                            password: password
      end

      def sync_from_server
        @structure = ambari_structure.new Hash.new,
                                          remote: true, href: href, user: user,
                                          password: password
      end

      private

      def ambari_structure
        require 'recursive_open_struct'

        Ambari::Structure
      end

      def category
        fail "#category must be implemented by #{ self.class }"
      end

      def href
        "http://#{ server }:8080/api/v1/#{ category }/#{ name }"
      end
    end
  end
end
