# @TEST-SERIALIZE: comm
#
# @TEST-EXEC: btest-bg-run manager-1 BROPATH=$BROPATH:.. CLUSTER_NODE=manager-1 bro %INPUT
# @TEST-EXEC: sleep 1
# @TEST-EXEC: btest-bg-run worker-1  BROPATH=$BROPATH:.. CLUSTER_NODE=worker-1 bro %INPUT
# @TEST-EXEC: btest-bg-run worker-2  BROPATH=$BROPATH:.. CLUSTER_NODE=worker-2 bro %INPUT
# @TEST-EXEC: btest-bg-wait 15
# @TEST-EXEC: cat manager-1/.stdout | sort > out
# @TEST-EXEC: btest-diff out

@TEST-START-FILE cluster-layout.bro
redef Cluster::nodes = {
	["manager-1"] = [$node_type=Cluster::MANAGER, $ip=127.0.0.1, $p=37757/tcp, $workers=set("worker-1", "worker-2")],
	["worker-1"]  = [$node_type=Cluster::WORKER,  $ip=127.0.0.1, $p=37760/tcp, $manager="manager-1", $interface="eth0"],
	["worker-2"]  = [$node_type=Cluster::WORKER,  $ip=127.0.0.1, $p=37761/tcp, $manager="manager-1", $interface="eth1"],
};
@TEST-END-FILE

redef Log::default_rotation_interval = 0secs;

global n = 0;

event bro_init() &priority=5
	{
	local r1: SumStats::Reducer = [$stream="test", $apply=set(SumStats::SAMPLE), $num_samples=5];
	SumStats::create([$epoch=5secs,
	                  $reducers=set(r1),
	                  $epoch_finished(rt: SumStats::ResultTable) =
	                  	{
	                  	for ( key in rt )
	                  		{
					print key$host;
	                     		local r = rt[key]["test"];
					for ( sample in r$samples ) {
						print r$samples[sample];
					}
					print r$sample_elements;
	                  		}

	                  	terminate();
	                  	}]);
	}

event remote_connection_closed(p: event_peer)
	{
	terminate();
	}

global ready_for_data: event();
redef Cluster::manager2worker_events += /^ready_for_data$/;

event ready_for_data()
	{
	if ( Cluster::node == "worker-1" )
		{
		SumStats::observe("test", [$host=1.2.3.4], [$num=5]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=22]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=94]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=50]);
		# I checked the random numbers. seems legit.
		SumStats::observe("test", [$host=1.2.3.4], [$num=51]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=61]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=61]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=71]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=81]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=91]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=101]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=111]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=121]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=131]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=141]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=151]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=161]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=171]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=181]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=191]);

		SumStats::observe("test", [$host=6.5.4.3], [$num=2]);
		SumStats::observe("test", [$host=7.2.1.5], [$num=1]);
		}
	if ( Cluster::node == "worker-2" )
		{
		SumStats::observe("test", [$host=1.2.3.4], [$num=75]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=30]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=3]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=57]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=52]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=61]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=1.2.3.4], [$num=95]);
		SumStats::observe("test", [$host=6.5.4.3], [$num=5]);
		SumStats::observe("test", [$host=7.2.1.5], [$num=91]);
		SumStats::observe("test", [$host=10.10.10.10], [$num=5]);
		}
	}

@if ( Cluster::local_node_type() == Cluster::MANAGER )

global peer_count = 0;
event remote_connection_handshake_done(p: event_peer) &priority=-5
	{
	++peer_count;
	if ( peer_count == 2 )
		event ready_for_data();
	}

@endif
