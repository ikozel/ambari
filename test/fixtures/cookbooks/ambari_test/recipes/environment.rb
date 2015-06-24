include_recipe 'apt'

hostsfile_entry '192.168.50.10' do
  hostname 'server.ambari.test'

  action :create_if_missing
end

3.times { |x|
  hostsfile_entry "192.168.50.2#{ x }" do
    hostname "agent-#{ x }.ambari.test"

    action :create_if_missing
  end
}
