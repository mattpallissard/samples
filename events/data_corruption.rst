I got a report that users had some very subtle data corruption at times. They
went up through an engineering team that runs a tight ship, that team brought
in a second one.  The issue was confirmed, but the cause wasn't known.


1.) I can consistently hit this error on gen-uge-exec-p076 and gen-uge-exec-p088
2.) Have not had any luck hitting this error on archive nodes.
3.) It takes a long time to hit this error. Usually at least 250 iterations, some times as many as 370.
4.) It randomly occurs in one act of file export, in a random cell. The object in memory is fine, so if you keep the code going and export again, the wild draw will go away.

I have reproduced the issue once. I set up a while loop that
1.) read in the original file using pandas.read_hdf
2.) wrote out a new file using pandas.to_hdf
3.) read in the new file using pandas.read_hdf
4.) checked if the new file was the same as the original
5a.) if so, deleted the new file and kept going
5b.) if not, raised an error


  Sorry about the RST.  All of my notes are in RST, github and gitlab support RST, bitbucket allegedly supports RST.  When I have actual results to share I'll format them to markdown.

You can always run;

.. code:: sh

    rst2html README.rst readme.html


questions
=========

to ask
^^^^^^
Questions to ask folks

1. How are these environments installed?
    * conda?
    * which compiler is used?
        * one from the OS?
        * intel? Clang
    * do you all use a different libc?

2. Are these deployments automated?
    * can I have be pointed towards the deployment scripts.

3. Are there git repos that house the example code?

to investigate
^^^^^^^^^^^^^^

1. do we get the same results on all hardware?
2. do we get the same results when the runtime environment matches the build environment
    * same kernel?
    * same hardware?
3. same mount options?


process
=======

It may be decided to move 5 further up the list.

1. replicate
2. speed up replication process if possible.
    * see various hypothesis' for potential ways to speed up the process.
3. Identify *exactly* where the data is corrupted
    * is it the file, or the data to be written in the file?
4. Measure the corruption
    * It it the same N bytes corrupted?
        * is it the same bits?
5. run through the matrix of possible combinations


hypothesis
==========

corruption during serialization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Based on the tickets I read, the data field[s] are corrupt, not the entire file. Because of that, I suspect that the corruption is happening in the process of writing, but before the actual `write()` syscall.

::

  structure in memory
  ├── 1. serialize <- as only data within the on-disk structure appears to be corrupt, I suspect corruption happens here
  └───── architecture agnostic representation
    ├──── 2. write <- if the corruption happened here, the file structure iteself would be corrupt (i.e broken b-trees, missing file header/footers)
    └────── file


*IF* this is the case we could have one of the following issues during serialization.


invalid memory access
^^^^^^^^^^^^^^^^^^^^^

The symptom could be explained by a memory access issue.  The data could be written outside of a structure.  The valid data would be read unless something else had overwritten it.
The fact that this has been reported in multiple languages, using multiple file-formats suggests that it could be caused by compilation issues.
If this is the case we should be able to spawn two threads, one perform the serialization and write, the second to fill the box's RAM.  We could speed this up further by limiting the process's ram usage to a cgroup.

compilation incompatibilities
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A compiler could be performing an optimization that has negative effects on different hardware versions.


test
====

So, first thing I needed to do was reproduce the issue.  The users were
reproducing this by generating random data, which took foreveer.  I wrote a
little c program that all it did was take alternating 64 bit words, all bits
on, and all bits off, serialize them, then write it to disk.  After written, we
read it back in, unmarshall, and check every word as we go.  I was able to
reproduce the issue reliably, typically between 20minutes and two hours.

There was a peculiar pattern I noticed as well it was always the first 32 bits
of a word, and it was allways with a word that had all bits 'on'.

Now I had to narrow down the root cause.

We had 3 hardware models currently in play.  And two kernels.  I threw in a third kernel, which was coming into play next patch cycle.

I then compiled the binary on every hardware model with every kernel, so nine binaries all in total.

  * R620
  * R630
  * C6320


  * 3.10 <- archive kernel
  * 5.1 <- current exec kernel
  * 5.5 <- future exec kernel


The basic flow was

.. code:: sh

    for model models; do
      for kernel kernels; do
	    [ -z optimizations ] || for opt in optimizations; do
	      build environment --$opt > t/$model/$kernel
		done;
	   done
	done


We'll then run every environment on every model/kernel combo.  But there are a few more thigns we need to check. We had local disk and nfs.  I needed to narrow it down to which one.

nfs actually has two options that drastically change the write behavior.  You
can open a file with or without O_SYNC, without the O_SYNC, the server is
allowed to reply 'hey, I got that, don't worry' before the data is actually
persisted to disk and the write call is allowed to return control to user space
prematurely.  This is the de-facto standard behavior in our enviornment.

I also wanted to see if O_SYNC would effect the behavior.


So on three servers I going to test.

* local disk and nfs, both sync or async
* multiple file sizes

I was going to run every compiled binary on every server to see if it was a processor optimization issue (we'd hit that with math libraries being handed the wrong compile time flags before)

so the checks to include in the test
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* local disk /vs nfs
* file opened w/ and w/o O_SYNC
* multple data sizes
* write a known pattern to the file it's easier to see exactly where the corruption is


other miscellaneous thoughts
============================

After running through every combinitorial possibility dozens of times, It
actually only showed up on the 5.1 kernel and with async writes.  data size,
hardware model, and compilation environment were irrelevant.


I was going down the rabbit hole of what changed between 5.1 and 5.3 in that
part of the stack, trying to narrow down whether it was in the VFS poriton of
the code or the sunrpc part of the nfs3 stack before my boss pulled me from
that project, saying 'hey, we're just going to upgrade' and told me that I had
bigger fish to fry



nfs commits to check
^^^^^^^^^^^^^^^^^^^^
* I found no bugs in any of the trackers
* there are a few commits to check out
	* I suspect that most of these are nfs4
