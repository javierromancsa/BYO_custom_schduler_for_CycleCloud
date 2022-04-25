# Bring your own custom scheduler for CycleCloud
In this example we are going to use a version of the OpenGridEngine scheduler compiled with support for Java DRMAA API. This OpenGridEngine version is the baseline version use for CycleCloud SGE scheduler sge-2011.11-64.tgz and sge-2011.11-common.tgz [latest](https://github.com/Azure/cyclecloud-gridengine/releases/latest)

## Prerequisites  
1. [Deploy CycleCloud using Market Place image](https://docs.microsoft.com/en-us/azure/cyclecloud/qs-install-marketplace?view=cyclecloud-8)
2. Use the Java compiled files OGE files named as follows (NOTE: do not change the file names):  		    
		    [sge-2011.11j-64.tgz](https://github.com/javierromancsa/BYO_custom_schduler_for_CycleCloud/blob/master/sge-2011.11j-64.tgz)  
		    [sge-2011.11j-common.tgz](https://github.com/javierromancsa/BYO_custom_schduler_for_CycleCloud/blob/master/sge-2011.11j-common.tgz)
		    
3. The cyclecloud cli must be configured. Documentation is available here:  
  [https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli)


### Copy the binaries into the cloud locker

To use another version upload the binaries to the storage account that CycleCloud uses.

```bash

$ azcopy cp sge-2011.11j-64.tgz https://<storage-account-name>.blob.core.windows.net/cyclecloud/gridengine/blobs/
$ azcopy cp sge-2011.11j-common.tgz https://<storage-account-name>.blob.core.windows.net/cyclecloud/gridengine/blobs/
```
### Modifying configs to the cluster template

Make a local copy of the gridengine template and modify it to use your binaries in the the default.

```bash
wget https://raw.githubusercontent.com/Azure/cyclecloud-gridengine/master/templates/gridengine.txt
```

In the _gridengine.txt_ file, locate the first occurrence of `[[[configuration]]]` and
insert text such that it matches the snippet below.  This file is not sensitive to 
indentation.

> NOTE:
> The details in the configuration, particularly version, should match the installer file name.

```ini
[[[configuration gridengine]]]
    make = sge
    version = 2011.11j
    root = /sched/sge/sge-2011-11j
    cell = "default"
    sge_qmaster_port = "537"
    sge_execd_port = "538"
    sge_cluster_name = "grid1"
    gid_range = "20000-20100"
    qmaster_spool_dir = "/sched/sge/sge-2011-11j/default/spool/qmaster" 
    execd_spool_dir = "/sched/sge/sge-2011-11j/default/spool"
    spooling_method = "berkeleydb"
    shadow_host = ""
    admin_mail = ""
    idle_timeout = 300

    managed_fs = true
    shared.bin = true

    ignore_fqdn = true
    group.name = "sgeadmin"
    group.gid = 536
    user.name = "sgeadmin"
    user.uid = 536
    user.gid = 536
    user.description = "SGE admin user"
    user.home = "/shared/home/sgeadmin"
    user.shell = "/bin/bash"

```

These configs will override the default gridengine version and installation location, as the cluster starts.  
It is not safe to move off of the `/sched` as it's a specifically shared nfs location in the cluster.

### Import the cluster template file

Using the cyclecloud cli, import a cluster template from the new cluster template file.

```bash
cyclecloud import_cluster OGE -c 'grid engine' -f gridengine.txt -t
```

Similar to this [tutorial](https://docs.microsoft.com/en-us/azure/cyclecloud/tutorials/modify-cluster-template) in the documentation, new OGE cluster type is now available in the *Create Cluster* menu in the UI.

Configure and create the cluster in the UI, save it, and start it.

## Verify GridEngine version
As an example, start a cluster in CycleCloud that has been configured and is named "test-OGE" or whatever you want to name it. When the master node reaches the Started state (green), log into the node with the cyclecloud connect command.  
		`cyclecloud connect master -c test-OGE`
