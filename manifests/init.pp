class elasticsearch {

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
	  path => '/tmp/elasticsearch-0.20.5.deb',
	  ensure => present,
	  source => 'puppet:///modules/elasticsearch/elasticsearch-0.20.5.deb',
	}
    
    #Package resources
    
    #The OpenJDK Java 7 runtime
	package { 'openjdk-7-jre-headless':
	  ensure => installed,
	  provider => 'apt',
	}
    
    #Elasticsearch itself
    #The source is the 'elastic-search' package farther above
	package { 'elasticsearch':
	  source => '/tmp/elasticsearch-0.20.5.deb',
	  name => 'elasticsearch-0.20.5.deb',
	  ensure => latest,
	  provider => dpkg,
	  require => [Package['openjdk-7-jre-headless'], File['elasticsearch-package']],
	}
    
    #Service resources
    
    #ElasticSearch service
    service { 'elasticsearch':
      ensure => running,
      require => Package['elasticsearch', 'openjdk-7-jre-headless'],
      subscribe => File['elasticsearch.yml'],
    }
            
}