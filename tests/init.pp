# == Tests
# This manifest contains test instantiations of the elasticsearch parameterized class.

    class {'elasticsearch':
      cluster_name => 'logstash_cluster',
      bind_interface    => 'eth1',
    }