# Cookbook Name:: ambari_test
# Recipe:: blueprint
#
# Copyright 2014, Julien Pellet
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#

ambari_blueprint node['ambari_test']['blueprint']['name'] do
  fields node['ambari_test']['blueprint']['fields']
  password node['ambari_test']['password']
  server node['ambari_test']['server']
  user node['ambari_test']['user']
end
