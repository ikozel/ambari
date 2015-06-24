module Ambari
  # Compares remote and local Blueprints
  class BlueprintEquator
    def equivalent?
      equal_top_level_configurations? && equal_host_groups? && equal_blueprints?
    end

    private

    def equal_blueprints?
      normalized_remote = normalized_blueprints map: @remote.Blueprints
      normalized_local = normalized_blueprints map: @local.Blueprints

      normalized_remote == normalized_local
    end

    def equal_configurations? remote:, local:
      normalized_remote = normalized_configurations list: remote
      normalized_local = normalized_configurations list: local

      normalized_remote == normalized_local
    end

    def equal_host_groups?
      normalized_remote = normalized_host_groups list: @remote.host_groups
      normalized_local = normalized_host_groups list: @local.host_groups

      normalized_remote == normalized_local
    end

    def equal_top_level_configurations?
      equal_configurations? remote: @remote.configurations,
                            local: @local.configurations
    end

    def initialize remote:, local:
      @remote = remote
      @local = local
    end

    def normalized_blueprints map:
      map.to_h.reject { |key| key == 'blueprint_name' }
    end

    def normalized_configurations list:
      normalized_list = list || []

      normalized_list.sort_by { |configuration| configuration.to_h.keys.first }
    end

    def normalized_host_group member:
      member.cardinality ||= 'NOT SPECIFIED'

      member.components = normalized_named list: member.components

      member.configurations =
        normalized_configurations list: member.configurations

      member
    end

    def normalized_host_groups list:
      normalized_list = normalized_named list: list

      normalized_list.map { |member| normalized_host_group member: member }
    end

    def normalized_named list:
      list.sort_by &:name
    end
  end
end
