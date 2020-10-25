monitoring and observability
============================


monitoring
==========

observe or detect conditions with instruments that have no effect on the
operation.  This is typically done from the outside looking in.  Things you
monitor are usually black-box like firmware, disks, memory.  Technically you
can look inside of driver portion of memory or disks, to an exetent.   We're
usually dealing with linux and there is tooling for that sort of thing.  But my
point is, those things like firmware and hardware are portions of the stack
that are abstracted away, we're built on top of it.  There is a contract
between your application and those layers, and you monitor the boundary.

Checks are typically lightweight, unubtrusive and don't have lot of detail not
to mention context.

observability
=============

Making a system transparent to those operating it.  In order to be obserable,
it has to be instrumentable and there are two instrumentation methods that are
used in conjunction.

Static instrumentation, which is semantically relevant information; logging,
counters, whatever.  You bake this sort of logic into your system.  This can be
done manually, or added automatically to the source by tooling.

And dynamic instrumentation,  this allows the system to be changed while
running to emit data.  Things like dtrace, bpf/kernel tracepoints.

dynamic instrumentation lets you get answers to ad-hoc questions that can live
in deeper layers of the stack.  It gives you the ability to change the stack,
coaxing it to emit the data that you need to debug.

* Runtime instrumentation, this could be something like valgrind or gdb.
* compiler assisted, clangs memory santizer
* or runtime injection, this is like kernel uprobes and uretprobes leveraged with modules or ebpf.  This is how systemtap works.  In fact a lot of the uprobes code originates from systemtap.
  * this is the way to go.
    * kernel guys have it figured out
      * register address of library or binary, address pointing to a single virtual memory address per process
      * user space executes the instruction address out of order
      * then an event is genrated which can pulled out of the perf event channels or memory mapped ring-buffer.
      * now, the out of order execution part would be a tricky beast to solve, especially with multi-threaded applications
  * there may be a gdbstub in there allowing gdb to perform runtime injection as well


monitoring is watching things, observability having the facilities to ask a specific question


metrics
=======

when you're debugging a pathological issue,  you start with questions.

cacti
datadog
metricbeat
prometheus
snmp
statsd

apm
^^^

application performance metrics. which is just different way to obtain and look at metrics.  They're still metrics based under the hood.

questions
=========

You often start with something like the USE method, utilization, saturation, or RED request rate, error rate, duration of requests
errors (your monitoring metrics) to get your starting point.  Before you start
debugging.

questions are answered through observation, making observability an utmost
importance.  If the system cannot be observed, you're reduced to guessing and
inferring.




aggregation
===========

rolling up values into buckets, tossing out time metrics.

aggregates vs cardinality is the trade off between time and space.  Not a time
space tradeoff, like your algorithms and but like actual timestamps.

Honestly, this is why I don't like influx, it chokes on anything with a modest amount of cardinality.

have to be able to aggregate the data scalability without degrading the
performance. Some data needs to be disaggregated to debug, because aggregated
data tosses out time.

think like memory and cpu usage as a over time so you can see GC sweeps, or
buffer's being filled, whatever.  you aggregate too aggresively and you miss
the peaks, valleys, interesting points.  You aggregate too little and you have
a lot of data, too much

visualization
=============

people are really good at pattern matching,  like really good.  Once you can
see data, it often gives you new questions to ask.


examples
^^^^^^^^

We had a *swath* of jobs failing before runtime limits were hit.  We had
several people deep diving into the issue and couldn't figure it out.  I pulled
the info of jobs that had runtime limits of ten minutes, and plotted their end
times.  As soon as I threw it up on the screen everyone, and I mean everyone,
in the room immediately recognized it as a datetime bug in the work flow
manager.  They all died at 6 minutes instead of 600 seconds.

We'd been looking at the text data for several hours, it was right in our
faces, a no brainer, but nobody picked up on that until it was plotted.

Or like when you're wondering why things are blocking jobs from runnign, we
plotted running jobs and queued jobs.   as soon as you look at the graph and go
oh, as soon as number hits however many hundred thousand in the queue you see
the blocking periods coincide with scheduler runs.  Then you start cursing grid
engine under your breath because you realize that the more work there is to do,
the slower it gets done and you realize you have to come up with an in house
throttling mechanism.


Or debugging an openafs performance problem, using bptfrace to dump a
stacktrace and using brandon gregg's flamegraphs to visualize it.  It becomes
apparent that the time is spent locally, indicating a client misconfiguration

Visualize in multiple ways. heat maps, brandon gregg's flamegraphs (stack
traces on both side of the user/kernelspace boundary are magical).  Statemaps

Tools can help you but they can't do it for you.


performance isn't tuning, it's debugging.  You don't just toggle the knobs, you
have to hypothesize, gather data, and explore.  This is where the whole
observability is.


profile types
=============


* flat profiler - average call times
* call-graph - call times, frequencies, and the call chain in the context of the callee -> flame graphs
* input-sensite profiler - similar to a call-graph but it has further metrics, i.e what information was in the call
  * could be input size, or even the values itself.
  * I've never implemented this, but I've given it some thought.



lookup
time based profiling ( sampling )
statemaps  plot state transitions on the x axis


brandon gregg -> bptfrace, system tap netflix
bryan cantrill -> system tap joyent
tom wilkie -> grafana

