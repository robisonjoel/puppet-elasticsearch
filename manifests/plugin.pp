# == Class: elasticsearch::plugin
#
# This subclass contains a defined type for .
# 
#
# === Parameters
# [*plugin_author*]
#    The name of the ElasticSearch cluster that this node will be a part of. This is used
#    when automatic multicast node discovery is used, as is the case with ElasticSearch.
#    Defaults to "mycluster01".    
#
# [*plugin_name*]
#    The name of the plugin. This is generally the name of the Github project.
#
# === Examples
# 
#   class {
#     cluster_name     => 'logstash-cluster',
#     bind_interface   => 'eth1',
#   }
#
#
# c
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

class elasticsearch::plugin {

    define elasticsearch_plugin ($plugin_author, $plugin_name) { "plugin -install $plugin_author/$plugin_name"

        exec {
          cwd => '/usr/share/elasticsearch/bin',
          creates => '',
    
        }
    }
}