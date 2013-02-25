puppet-elasticsearch
====================

A module to install and configure ElasticSearch either on a standalone system or in a cluster.

This is for Debian/Ubuntu.

###Usage

Download the latest .deb package from ElasticSearch's [download page](http://www.elasticsearch.org/download/) and place it in the `files/` directory, naming it `elasticsearch.deb`.

In the **Variables** section at the top of `init.pp`, specify values for:

* `$cluster_name`: The name for the node cluster
* `$bind_interface`: The network interface ElasticSearch will use to communicate with other the ElasticSearch nodes on (**eth0**, **eth1**, etc.)

In your `site.pp`, apply the `elasticsearch` class to a node:

<pre>
node 'elasticsearch-node1' {
    include elasticsearch
}
</pre>

Yes, I will expose turn this into a parameterized class later on.


