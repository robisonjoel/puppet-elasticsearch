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


include elasticsearch::config, elasticsearch::install, elasticsearch::service 


        
}


class elasticsearch::install {


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
      name => 'elasticsearch',
      ensure => installed,
      provider => dpkg,
      require => Package['openjdk-7-jre-headless'],
    }

}


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
