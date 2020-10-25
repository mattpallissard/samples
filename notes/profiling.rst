=========
profiling
=========

I authored, and lead two instute mandate sessions.

1. on is on what hpc is, and how to use the scheduler.  baby's first job.  This course is more or less 'hey, this is how you run jobs on hundreds of computers with out ddos'ing your co-workers' easy peasy.

2. the second one is all about resource utilization and application profiling.  Now, this is a bit challenging for one main reasons

1. I'm given no baseline skills that new hires will have.  I could have a PhD in computer science from a prestigious university, and I may get someone who has never used a computer before their background is in global health, and now their told their job is to turn their models into programs.

2. historically this company was ran like a startup of health professionals, because it was.  I had a coworker who summed it up very concicely, 'academia is full of terrible things done by really well-meaning individuals'.  Nobody cared about maintainability, resource utilization, or reproducibility.

Now because of this we're starting to see a shift in that, we have real engineers and developers trying to train health science professionals.  That's where I come in.

I teach them what proc is, what metrics matter, and the general process for figuring out memory usage on ancient code that's full of atrocities that they are now responsible for.   I demo a bit of really simple static instrumentation through logs, and pulling info out of proc.  I walk them through submitting jobs, and the patterns of submitting many buckets of resource request sizes, then how to reason about the results.  

examples like submitting a spread of jobs that use varying amounts of cpu requests to peform the same work.  THen look at the tradeoff between runtime of the job and wait time spent in the work queue.

Some of the time it's frustrating, because people walk in the room with a bad attitude.  A lot of these folks are typically statisticians of some sort who think that they shouldn't have to learn technical skills because they don't have technical role.

But some of the times it's super rewarding when you can take someone who has mess of an application, teach them about proc, show them how to write a custom log adapter to show the memory use, track down the problem to something silly.  Like reading an entire dataset into memory just to perform something cumulative a the sum of a function over one single risk factor.  Then in front of the class you have them restructure 6 lines of code, swapping out the raw read statement with an iterator and watch the memory usage drop by several orders of mag nutated.


Now I don't get into anything interesting like any sort of dynamic instrumentation. But I do teach folks about the relationship between threads and runtime.  How memory works, how to perform basic napkin math and reason about the behavior of your program when you're designing your application, before you have a problem.

I also cover how to debug these issue, how to look at the logs and metrics, how to use our in house tooling to look at historical job runs, little idiosyncrasies with timer gathered, time-series data



