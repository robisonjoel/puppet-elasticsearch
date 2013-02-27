puppet-elasticsearch
====================

A module to install and configure ElasticSearch either on a standalone system or in a cluster.

This is for Debian/Ubuntu.

###Usage

Download the latest .deb package from ElasticSearch's [download page](http://www.elasticsearch.org/download/) and place it in the `files/` directory, naming it `elasticsearch.deb`.

To apply the `elasticsearch` class to a node, in your `site.pp`, set the `cluster_name` and `bind_interface` parameters:

<pre>
node 'elasticsearch' {

  class {'elasticsearch':
    cluster_name    => 'mycluster01',
    bind_interface  => 'eth1',
    }

}
</pre>

To apply it to more than one machine and have each one be a part of the same cluster, just list more nodes:

<pre>
node 'elasticsearch1', 'elasticsearch2', 'elasticsearch3', 'elasticsearch4' {

  class {'elasticsearch':
    cluster_name    => 'mycluster01',
    bind_interface  => 'eth1',
  }

}
</pre>

####Parameters

* `$cluster_name`: The name for the node cluster
* `$bind_interface`: The network interface ElasticSearch will use to communicate with other the ElasticSearch nodes on (**eth0**, **eth1**, etc.)

