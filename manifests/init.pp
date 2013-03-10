# == Class: elasticsearch
#
# This base class installs and configures an ElasticSearch node with basic settings.
# Multicast networking is used (it's ElasticSearch's default).
#
# === Parameters
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
  $elasticsearch_version ='0.20.5'
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
