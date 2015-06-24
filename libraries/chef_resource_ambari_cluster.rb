require 'timeout'

require_relative 'ambari_cluster_equator'
require_relative 'ambari_resource_base'

class Chef
  class Resource
    # Chef Resource representing an Ambari Cluster
    class AmbariCluster < Ambari::Resource::Base
      include Timeout

      self.resource_name = :ambari_cluster

      attribute :timeout_duration, kind_of: Integer, required: true

      def equal_to? resource:
        equator = Ambari::ClusterEquator.new remote: structure,
                                             local: resource.structure

        equator.equivalent?
      end

      def post_to_server
        structure.post_to_server do |body| wait_for_request_in body: body end
      end

      private

      def category
        'clusters'
      end

      def poll_status_of structure:
        timeout timeout_duration do
          status = structure.follow.Requests.request_status

          case status
          when 'COMPLETED', 'SUCCESSFUL'
            break
          when 'PENDING', 'IN_PROGRESS'
            redo
          when 'FAILED', 'ABORTED'
            fail "Cluster request has #{ status.downcase }"
          else
            fail "Unrecognized Cluster request status:\n#{ status }"
          end
        end
      end

      def wait_for_request_in body:
        structure = ambari_structure.new body

        Chef::Log.warn "Waiting for Cluster request:\n" \
                         "#{ timeout_duration } seconds"
        poll_status_of structure: structure
      end
    end
  end
end unless defined? Chef::Resource::AmbariCluster
