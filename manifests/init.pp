# == Class: elasticsearch
#
# This base class installs and configures an ElasticSearch node with basic settings.
# Multicast networking is used (it's ElasticSearch's default).
#
# === Parameters
#
# [*cluster_name*]
#    The name of the ElasticSearch cluster that this node will be a part of. This is used
#    when automatic multicast node discovery is used, which is ElasticSearch's default.
#    Defaults to "mycluster01".    
#
# [*bind_interface*]
#    The network interface on which discovery and inter-node communication will be done.
#    Defaults to 'eth1'.
#
# [*elasticsearch_version*]
#    The version of ElasticSearch you would like to install. Defaults to 0.20.5, which is
#    the latest stable version as of March 2013.
#
# [*number_of_shards*]
#    The number of shards each index gets broken into. Defaults to 5.
#
# [*number_of_replicas*]
#    The number of additional copies of each shard that are made. Defaults to 2, giving a
#    total of 3 copies of each shard.
#
# [*node_is_master*]
#    Whether the node is eligible to be elected a master node, coordinating traffic
#    in the cluster. Defaults to true.
#
# [*node_is_data*]
#    Whether the node will hold index data. Defaults to true.
#
# [*node_rack*]
#    A purely informational setting that can be used to divide nodes into groups analogous
#    to racks in a data center. This allows for things like making sure that all of the 
#    replicas of a certain shard are not stored on nodes that are physically in the same
#    rack, for instance. Defaults to rack01.
#
# [*data_dir_path*]
#    The version of ElasticSearch you would like to install. Defaults to 0.20.5, which is
#    the latest stable version as of March 2013.
#
# [*data_dir_path*]
#    Where index data is stored. Defaults to `/var/elasticsearch/`.    
#
# [*temp_dir_path*]
#    Where data is temporarily kept before getting permanently stored in an index.
#    Defaults to `/tmp/elasticsearch/`.
#
# [*log_dir_path*]
#    Where logs are stored. Defaults to `/var/log/elasticsearch/`.
#
# === Examples
# 
#   class {
#     cluster_name     => 'logstash-cluster',
#     bind_interface   => 'eth1',
#   }
#
#
class elasticsearch (
  $cluster_name = 'mycluster01',
  $bind_interface = 'eth1',
  $elasticsearch_version ='0.20.5',
  $number_of_shards = '5',
  $number_of_replicas = '2',
  $node_is_master = 'true',
  $node_is_data = 'true',
  $node_rack = 'rack01',
  $data_dir_path = '/var/elasticsearch/',
  $temp_dir_path = '/tmp/elasticsearch/',
  $log_dir_path = '/var/log/elasticsearch/',
  $static_hosts = '',
  $multicast_enabled = 'true'
) {	
    
    #Include the rest of the manifest's classes
    include elasticsearch::config, elasticsearch::install, elasticsearch::service 
        
}

#Install packages for ElasticSearch and its prerequite, Java
class elasticsearch::install {

    #ElasticSearch .DEB package; this isn't in most repos, so we're copying it down from 
    #their site first and installing it with the package resource farther down below.
    exec { 'download-elasticsearch':
      cwd => '/tmp',
      path => '/usr/bin/',
      command => "wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${elasticsearch::elasticsearch_version}.deb",
      creates => "/tmp/elasticsearch-${elasticsearch::elasticsearch_version}.deb",
    }

    #Package resources
    
    #The OpenJDK Java 7 runtime; ElasticSearch is written in Java and requires this to run
    package { 'openjdk-7-jre-headless':
      ensure => installed,
      provider => 'apt',
    }

    #Elasticsearch itself
    #The source is the 'download-elasticsearch' exec resource farther above
    package { 'elasticsearch':
      source => "/tmp/elasticsearch-${elasticsearch::elasticsearch_version}.deb",
      name => 'elasticsearch',
      ensure => installed,
      provider => dpkg,
      require => Package['openjdk-7-jre-headless'],
    }

}

#Config folder and YAML file
class elasticsearch::config {

    #File resources

    #Elasticsearch's main config file and the directory its found in
    file { '/etc/elasticsearch/':
      ensure => directory,
    }
    
    file { 'elasticsearch.yml':
      path => '/etc/elasticsearch/elasticsearch.yml',
      ensure => file,
      content => template('elasticsearch/elasticsearch.yml.erb'),
      require => Class['elasticsearch::install'],
    }
    
    #Folder for the index data location
    file {'data-path':
      path => "${elasticsearch::data_dir_path}",
      ensure => directory,
      owner => 'elasticsearch',
      group => 'elasticsearch',
      mode => 755,
    }
    
    #Folder for the temp data location
      file {'temp-path':
      path => "${elasticsearch::temp_dir_path}",
      ensure => directory,
      owner => 'elasticsearch',
      group => 'elasticsearch',
      mode => 755,
    }
    
    #Folder for the log location
      file {'log-path':
      path => "${elasticsearch::log_dir_path}",
      ensure => directory,
      owner => 'elasticsearch',
      group => 'elasticsearch',
      mode => 755,
    }
}

#The service for ElasticSearch itself
class elasticsearch::service {

    #Service resources

    #ElasticSearch service
    service { 'elasticsearch':
      enable => true,
      ensure => running,
      require => Class['elasticsearch::config', 'elasticsearch::install'],
      subscribe => Class['elasticsearch::config'],
    }

}

#A class to remove and undo every resource that's defined above
class elasticsearch::remove {

    service { 'elasticsearch-stop':
      name => 'elasticsearch',
      enable => false,
      ensure => stopped,
    }

    file { 'elasticsearch.yml-remove':
      path => '/etc/elasticsearch/elasticsearch.yml',
      ensure => absent,
      require => Service['elasticsearch-stop'],
    }
    
    
     file { '/etc/elasticsearch/-remove':
      path => '/etc/elasticsearch',
      ensure => absent,
      require => File['elasticsearch.yml-remove'],
    }
    
    package { 'elasticsearch-uninstall':
      source => '/tmp/elasticsearch.deb',
      name => 'elasticsearch',
      ensure => absent,
      provider => dpkg,
      require => File['/etc/elasticsearch/-remove'],
    }
    
    file { 'elasticsearch-debfile-remove':
      path => '/tmp/elasticsearch.deb',
      ensure => absent,
      require => Package['elasticsearch-uninstall'],
    }

}
