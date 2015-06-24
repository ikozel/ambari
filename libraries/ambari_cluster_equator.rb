module Ambari
  # Compares remote and local Clusters
  class ClusterEquator
    def equivalent?
      remote_components_equal_referenced_components? &&
        remote_hosts == local_hosts
    end

    private

    def components_of blueprint:
      blueprint.host_groups.map { |host_group|
        components_of_host_groups member: host_group
      }.uniq.sort
    end

    def components_of_host_groups member:
      names = member.components.map &:name

      names.sort
    end

    def follow href:
      @remote.clone.tap { |structure| structure.href = href }.follow
    end

    def initialize remote:, local:
      @remote = remote
      @local = local
    end

    def local_hosts
      @local.host_groups.map { |host_group|
        host_group.hosts.map &:fqdn
      }.flatten.uniq.sort
    end

    def referenced_blueprint
      href = @remote.href.sub %r{clusters/#{ @remote.Clusters.cluster_name }},
                              "blueprints/#{ @local.blueprint }"

      follow href: href
    end

    def remote_as_blueprint
      href = "#{ @remote.href }?format=blueprint"

      follow href: href
    end

    def remote_components_equal_referenced_components?
      remote_components = components_of blueprint: remote_as_blueprint
      blueprint_components = components_of blueprint: referenced_blueprint

      remote_components == blueprint_components
    end

    def remote_hosts
      @remote.hosts.map { |host| host.Hosts.host_name }.uniq.sort
    end
  end
end
