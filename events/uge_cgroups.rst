
uge cgroups
-----------

We have a fleet of servers.  Jobs need to be scheduled on them.  We originally
had no memory or cpu limits on jobs, so you could have auser "request" memory,
go over the limit causing an OOM condition, and get a well behaving neighbor
get his or her job killed.

Typically in HPC the granularity is one per node.  If a job is smaller than the
size of a server, this is wasted compute and space.  I needed to come up with
aa finer grained solution.

grid engine does support this in some capacity.  However, It has a faulty
cgroups implementation.  Rather than use the cfs_period and quota to limit
processes to the amount of compute they can use.  It pin's processes to
specific processors.  At first you might think that could feasibly improve
performance due to memory locality and NUMA.  But the restrictions imposed on
the scheduler this isn't the reality for most workloads.   This is bad for
several reasons that intel highlights in their documentation.

1. The kernel scheduler is already numa aware, with affinity constraints are
placed upon it, degrading scheduling performance.  2. This doesn't prevent the
scheduler from preempting a process.  You run into conditions where you could
feasibly run on another core, but you're stuck waiting for the processor you're
pinned to.  3. once you consume the memory on a CPU you're guaranteeing that
the memory access path is sub-optimal.  You have to reach out to memory on a
remote node.

If you aren't specifically using the NUMA api's, Intel recommends to avoid
these bottlenecks by striping data and compute across all nodes. tl'dr let the
scheduler schedule

Too add to that, grid engine has a bug when assigning processor affinity.  It
completely ignores SMT, instead pinning to physical cores.  So if you have a
single threaded application.  you have to use two hardware threads at a minium.
Tons of our workloads are large sets of single threaded jobs, working in
parallel.  This wastes a *ton* of compute


2. It has another terrible bug.  The execution daemon, which spawns all
applications, has the capability to self-report resource utilization on a given
server.  It incorrectly reports cached memory as unavailable.  You wind up
where a box has no jobs running, and several hundred G of cache used so no new
jobs get scheduled.  Admittedly, descerning between cache, buffers, and slab
space is more complicated than it sounds.  STill, it be better to ignore all of
that than to treat inode/dentry/filesystem cache as used memory.

So I came up with an in-house solution.

One thing grid engine does do well is basic arithmetic on arbitrary resources,
called 'complexes in ge land.  You can create a complex, assign a number of
them to a given server.  As applications request resources, grid engine
decrements the available amount.  As jobs end, the complex amounts are
incremented.  Simple, create a fake memory and fake thread complex.

I wrote a little salt module that gathered hardware info for the box,
subtracted management overhead of resources, and posted that data to a rest
api deployed in k8s.  The rest api was a simple http -> apmq  (adavnced message
queuing protocol) translation layer.  I then wrote a daemon that pulled work
off of the queue and  automatically added hosts to the scheduler based on the
submitted resources. If the host already existed it checked if the resources
had changed, updating them accordingly.

Now, that solves the incorrect memory accounting problem, but still leaves
resource requests and enforcement decoupled.  I had already written a job
submission validator, jsv, that did some simple sanity checks when users
submitted jobs.  I had the jsv add the resource requests as environment
variables to the job.  This was beneficial for two reasons.

1. I had a means of getting the requests from the submission, to the job
itself.
2. extra; users had an easy means of accessing request information
from the application itself.

Now, grid engine keeps a directory tree of current jobs running on the node. I
wrote a daemon that ran on every node. That daemon.

* Picked the parent process out of the directory tree.  parsed the environment
  variable file for that process, obtaining the memory and cpu requests I
  shoved in at validation time converted cpu requests to the equivalent
  cfs_quota (cfs_period/number of threads * number of threads requested) This
  allowed me to limit jobs to the equivalent compute of a physical thread
  whithout pinning to a processor.  there is the ability to only restrict when
  the box is under resource constraint,  but this would have made it hard for
  users to profile compute.  setup the cpu and memory cgroup.  walk the process
  tree, grabbing all child processes, all related process groups, and any
  children of related process groups.  this catches and orphans Since there are
  cases in the 3.x kernels where forked processes can escape a cgroup, I
  periodically check the process tree against cgroup.procs

So to sum it all up, users can request resources for a job, dividing up the
resources of individual nodes, and enforcing resources to prevent noisy
neighbor problems (to an extent, I didn't implement vfs or network requests
