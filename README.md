#puppet-elasticsearch
---

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
    number_of_shards => '6',
    number_of_replicas => '2',
  }

}
</pre>

The node's name in the ElasticSearch cluster (as other ElasticSearch nodes will see it) defaults to the machine's hostname and doesn't need to be set.

To apply it to more than one machine and have each one be a part of the same cluster, just list more nodes:

<pre>
node 'elasticsearch1', 'elasticsearch2', 'elasticsearch3', 'elasticsearch4' {

  class {'elasticsearch':
    cluster_name    => 'mycluster01',
    bind_interface  => 'eth1',
    number_of_shards => '6',
    number_of_replicas => '2',
  }

}
</pre>

####Parameters

* `$cluster_name`: The name for the node cluster. Defaults to **mycluster01**.
* `$bind_interface`: The network interface ElasticSearch will use to communicate with other the ElasticSearch nodes on ( **eth0**, **eth1**, etc.). Defaults to **eth1**.
`$elasticsearch_version`: The version of ElasticSearch you would like to install. Defaults to **0.20.5**, which is the latest stable version as of March 2013.
* `$number_of_shards`: The number of shards each index gets broken into. Defaults to **5**.
* `$number_of_replicas`: The number of additional copies of each shard that are made. Defaults to **2**, giving a total of 3 copies of each shard.
* `$node_is_master` Whether the node is eligible to be elected a master node, coordinating traffic in the cluster. Defaults to `true`.
* `$node_is_data`: Whether the node will hold index data. Defaults to `true`.
* `$node_rack`: A purely informational setting that can be used to divide nodes into groups analogous
to racks in a data center. This allows for things like making sure that all of the replicas of a certain shard are not stored on nodes that are physically in the same rack, for instance. Defaults to `rack01`.
* `$data_dir_path`: Where index data is stored. Defaults to `/var/elasticsearch/`.
* `$temp_dir_path`Where data is temporarily kept before getting permanently stored in an index. Defaults to `/tmp/elasticsearch/`.
* `$log_dir_path`: Where logs are stored. Defaults to `/var/log/elasticsearch/`.