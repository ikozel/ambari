if defined? ChefSpec
  def create_ambari_blueprint resource_name
    ChefSpec::Matchers::ResourceMatcher.new :ambari_blueprint, :create,
                                            resource_name
  end

  def create_ambari_cluster resource_name
    ChefSpec::Matchers::ResourceMatcher.new :ambari_cluster, :create,
                                            resource_name
  end
end
