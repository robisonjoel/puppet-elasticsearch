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
#
#
# elasticsearch_plugin { 'paramedic':
#   plugin_author  => 'karmi'
#   plugin_name    => 'elasticsearch-paramedic'
# }
#

define elasticsearch::plugin (

$plugin_author, $plugin_name) 

{
    #Install the plugin via the built-in command ElasticSearch already has
    exec { "plugin_install_${title}":
      command => "/usr/share/elasticsearch/bin/plugin -install ${plugin_author}/${plugin_name}",
      cwd => '/usr/share/elasticsearch/bin',
      creates  => "/usr/share/elasticsearch/plugins/${plugin_name}.zip", 
    }
    
    notify { "install_notification_${plugin_name}":
      message => "$plugin_name was installed successfully!",
      subscribe => Exec["plugin_install_${title}"],
    }
}
