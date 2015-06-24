class Chef
  class Provider
    class AmbariCluster < Ambari::Provider::Base
    end
  end
end unless defined? Chef::Provider::AmbariCluster
