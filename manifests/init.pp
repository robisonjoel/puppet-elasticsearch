# == Class: elasticsearch
#
# This base class installs and configures an ElasticSearch node with basic settings.
# Multicast networking is used (it's ElasticSearch's default).
#
# === Parameters
# [*cluster_name*]
#    The name of the ElasticSearch cluster that this node will be a part of. This is used
#    when automatic multicast node discovery is used, as is the case with ElasticSearch.
#    Defaults to "mycluster01".    
#
# [*bind_interface*]
#    The network interface on which discovery and inter-node communication will be done.
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
  $bind_interface = 'eth1'
) {	
    
    #File resources
    
    #Elasticsearch's main config file and the directory its found in
    file { '/etc/elasticsearch/':
      ensure => directory,
    }
    
    file { 'elasticsearch.yml':
      path => '/etc/elasticsearch/elasticsearch.yml',
      ensure => file,
      content => template('elasticsearch/elasticsearch.yml.erb'),
      require => File['/etc/elasticsearch/'],
    }

    #ElasticSearch .DEB package; this isn't in most repos, so we're copying it down first
    #here and installing it with the package resource farther down below.
    file { 'elasticsearch-package':
      path => '/tmp/elasticsearch.deb',
      ensure => present,
      source => 'puppet:///modules/elasticsearch/elasticsearch.deb',
    }

    #Package resources

    #The OpenJDK Java 7 runtime; ElasticSearch is written in Java and requires this to run
    package { 'openjdk-7-jre-headless':
      ensure => installed,
      provider => 'apt',
    }

    #Elasticsearch itself
    #The source is the 'elastic-search' package farther above
    package { 'elasticsearch':
      source => '/tmp/elasticsearch.deb',
      name => 'elasticsearch-0.20.5.deb',
      ensure => installed,
      provider => dpkg,
      require => [Package['openjdk-7-jre-headless'], File['elasticsearch-package']],
    }

    #Service resources

    #ElasticSearch service
    service { 'elasticsearch':
      enable => true,
      ensure => running,
      require => Package['elasticsearch', 'openjdk-7-jre-headless'],
      subscribe => File['elasticsearch.yml'],
    }
        
}
