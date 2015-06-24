class Chef
  class Resource
    # Chef Resource representing an Ambari Blueprint
    class AmbariBlueprint < Ambari::Resource::Base
      self.resource_name = :ambari_blueprint

      def equal_to? resource:
        equator = Ambari::BlueprintEquator.new remote: structure,
                                               local: resource.structure

        equator.equivalent?
      end

      def post_to_server
        structure.post_to_server
      end

      private

      def category
        'blueprints'
      end
    end
  end
end unless defined? Chef::Resource::AmbariBlueprint
