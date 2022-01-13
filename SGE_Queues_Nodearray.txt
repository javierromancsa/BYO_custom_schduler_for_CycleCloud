Create OGE queues and hostgroups from nodearray:
Add queues to SGE that are associated to nodearrays defined in CC 

1.  CREATE NEW HOSTGROUPS NAMED NP, D8_v3, & D48_v3:

sudo -i
for h in GPUs D4v3 D48v3; do
  qconf -shgrp @allhosts > $SGE_ROOT/conf/${h}
  sed -i "s/allhosts/${h}/g" $SGE_ROOT/conf/${h}
  qconf -Ahgrp $SGE_ROOT/conf/${h}
done

2.  ADD NEW HOSTGROUPS TO AUTOSCALE.JSON 

sudo vim /opt/cycle/gridengine/autoscale.json

    "hostgroups": {
        "@cyclempi": {
            "constraints": {
                "node.colocated": true,
                "node.nodearray": "hpc"
            }
        },
        "@cyclehtc": {
            "constraints": {
                "node.colocated": false,
                "node.nodearray": "htc"
            }
        },
        "@GPUs": {
            "constraints": {
                "node.colocated": false,
	            "node.nodearray": "GPUs"
            }
        },
        "@D4v3": {
            "constraints": {
                "node.colocated": false,
	            "node.nodearray": "D4v3"
            }
        },
        "@D48v3": {
            "constraints": {
                "node.colocated": false,
	            "node.nodearray": "D48v3"
            }
        },

3.  CREATE QUEUES FOR EACH HOSTGROUP

sudo -i 
for q in GPUs D4v3 D48v3 ; do
  qconf -sq all.q > $SGE_ROOT/conf/${q}.q
  sed -i "s/all.q/${q}.q/g" $SGE_ROOT/conf/${q}.q
  sed -i "s/@cyclehtc @cyclempi/@${q}/g" $SGE_ROOT/conf/${q}.q
  sed -i 's/^pe_list.*/pe_list make,smpslots/g' $SGE_ROOT/conf/${q}.q
  qconf -Aq $SGE_ROOT/conf/${q}.q
done
