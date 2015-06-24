# Cookbook Name:: ambari_test
# Recipe:: blueprint
#
# Copyright 2014, Julien Pellet
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#

ambari_cluster node['ambari_test']['cluster']['name'] do
  fields node['ambari_test']['cluster']['fields']
  password node['ambari_test']['password']
  server node['ambari_test']['server']
  timeout_duration node['ambari_test']['cluster']['timeout']
  user node['ambari_test']['user']
end
