puppet-elasticsearch
====================

A module to install and configure ElasticSearch either on a standalone system or in a cluster.

This is for Debian/Ubuntu.

###Usage

Download the latest .deb package from ElasticSearch's [download page](http://www.elasticsearch.org/download/) and place it in the `files/` directory, naming it `elasticsearch.deb`.

In your `site.pp`, apply the `elasticsearc` class to a node:

<pre>
node 'elasticsearch-node1' {
    include elasticsearch
}
</pre>

