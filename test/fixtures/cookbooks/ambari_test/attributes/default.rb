default['ambari']['server_fqdn'] = 'server.ambari.test'

default['ambari_test'].tap { |test|
  test['blueprint'].tap { |blueprint|
    blueprint['fields'] = {
      'host_groups' => [
        {
          'name' => 'master',
          'configurations' => [
            {
              'nagios-env' => {
                'properties' => {
                  'nagios_contact' => 'me@my-awesome-domain.example'
                }
              }
            }
          ],
          'components' => [
            {
              'name' => 'NAMENODE'
            },
            {
              'name' => 'SECONDARY_NAMENODE'
            },
            {
              'name' => 'RESOURCEMANAGER'
            },
            {
              'name' => 'HISTORYSERVER'
            },
            {
              'name' => 'NAGIOS_SERVER'
            },
            {
              'name' => 'GANGLIA_SERVER'
            },
            {
              'name' => 'ZOOKEEPER_SERVER'
            },
            {
              'name' => 'APP_TIMELINE_SERVER'
            },
            {
              'name' => 'GANGLIA_MONITOR'
            },
            {
              'name' => 'HDFS_CLIENT'
            },
            {
              'name' => 'MAPREDUCE2_CLIENT'
            },
            {
              'name' => 'YARN_CLIENT'
            }
          ],
          'cardinality' => '1'
        },
        {
          'name' => 'slaves',
          'components' => [
            {
              'name' => 'DATANODE'
            },
            {
              'name' => 'HDFS_CLIENT'
            },
            {
              'name' => 'NODEMANAGER'
            },
            {
              'name' => 'YARN_CLIENT'
            },
            {
              'name' => 'MAPREDUCE2_CLIENT'
            },
            {
              'name' => 'ZOOKEEPER_CLIENT'
            },
            {
              'name' => 'GANGLIA_MONITOR'
            }
          ],
          'cardinality' => '1+'
        }
      ],
      'Blueprints' => {
        'stack_name' => 'HDP',
        'stack_version' => '2.1'
      }
    }

    blueprint['name'] = 'multi-node-hdfs-yarn'
  }

  test['cluster'].tap { |cluster|
    cluster['fields'] = {
      'blueprint' => 'multi-node-hdfs-yarn',
      'default_password' => 'admin',
      'host_groups' => [
        {
          'name' => 'master',
          'hosts' => [
            {
              'fqdn' => 'agent-0.ambari.test'
            }
          ]
        },
        {
          'name' => 'slaves',
          'hosts' => [
            {
              'fqdn' => 'agent-1.ambari.test'
            },
            {
              'fqdn' => 'agent-2.ambari.test'
            }
          ]
        }
      ]
    }

    cluster['name'] = 'yarn'

    cluster['timeout'] = 300
  }

  test['password'] = 'admin'

  test['server'] = 'server.ambari.test'

  test['user'] = 'admin'
}

default['java'].tap { |java|
  java['install_flavor'] = 'oracle'

  java['jdk_version'] = '7'

  java['oracle']['accept_oracle_download_terms'] = true
}
