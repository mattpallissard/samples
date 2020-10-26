Users were having jobs hit OOM conditions, which is super common.  We have users that are fresh out of college with no tech background, for some of them this is their first time programming.  They have a hard enough time getting code to work, let along profiling it properly.  Usually someone on the operations half of my team fields these.  But we wound up getting a pair of engineers reporing this that that I know well, and they are top-notch.  There was something wrong.


The kernel logs print the stracktrace of the process that summons OOM.  The thread of the triggering task was in the middle of nfs_write_begin on the kernel side of things.  IT also didn't have a cgroup associated with it, meaning that it was a global OOM situation.  Which is bizaare that we'd hit a global OOM situation to begin with, I've taken great pains to ensure that jobs can't escape cgroups or behave badly in unforseen ways.  It was even more bizarre that we hadn't had any memory alerts trigger as far back as we had data.

[Wed Sep  2 14:09:49 2020]  grab_cache_page_write_begin+0x20/0x40
[Wed Sep  2 14:09:49 2020]  nfs_write_begin+0x61/0x330 [nfs]

Looking at the stack trace it showed that most of the memory was in slab_unreclaimable 1, which would explain the lack of alert, that would have showed up as buff/cache memory, and we only fire on used.

[Wed Sep  2 14:09:49 2020] active_anon:18676592 inactive_anon:440 isolated_anon:0
                            active_file:12800 inactive_file:14493 isolated_file:80
                            unevictable:0 dirty:412 writeback:241 unstable:12
                            slab_reclaimable:38432545 slab_unreclaimable:130610617
                            mapped:15645 shmem:692 pagetables:54017 bounce:0
                            free:415411 free_pcp:719 free_cma:0

There was nearly 700G of ram used in used by buffers or cache.  And going by the numbers in the stack trace the math was weird, there was nearly 500G of memory that couldn't be freed.

pages are 4096 bytes so 130610617*4096/1024^3=~`498G` of kernel owned memory that can't be freed. It's listed as buffers and cache in the free -h command.

[root@gen-uge-exec-p080 sys]# free -h
              total        used        free      shared  buff/cache   available
Mem:           754G         98G         10G        2.7M        645G        153G
Swap:            0B          0B          0B

Now it could be a lot of open files, or a lot of processes as we have most ulimits disabled for our HPC environment.

Because of the stacktrace and the fact that the used memory was in slabs, I incorrectly thought that it was a buffer /memory accounting issue, although that would have been reclaimable.  That was confirmed by dropping page cache, no change in free -h

echo 1 > /proc/sys/vm/drop_caches

same with inode dentry page cache

echo 2 > /proc/sys/vm/drop_caches

It wasn't number of processes either, there were less than 1k


root@gen-uge-exec-p080:/root  ps aux | tail -n +2 | wc -l
865

I then looked at the slab space, which is where I should have started.
Looking at the what's using the slab space, shows the biggest offenders being generic kernel memory, not any dentry or task structs.

root@gen-uge-exec-p080:/root  slabtop -o | head
 Active / Total Objects (% used)    : -2101500660 / -2064134785 (98.3%)
 Active / Total Slabs (% used)      : 5816507 / 5816507 (100.0%)
 Active / Total Caches (% used)     : 113 / 174 (64.9%)
 Active / Total Size (% used)       : 24868427.80K / 28531678.80K (87.2%)
 Minimum / Average / Maximum Object : 0.01K / 0.01K / 16.62K  OBJS     ACTIVE      USE OBJ SIZE  SLABS  OBJ/SLAB CACHE SIZE NAME
1888069632 1872720499  99%    0.01K 3687636    512  14750544K kmalloc-8
260719872  257649556   98%    0.02K 1018437    256   4073748K kmalloc-16
44675840   41713358    93%    0.03K 349030     128   1396120K kmalloc-32



I started trying to think of things that we periodically had to clean up on the box, stuff like temp and shared memory.  And the only thing that we didn't clean up on the box, that I can think of, are the cgroup directories, which don't live on disk, they're kernel data structures represented as files.  This is the longest these nodes have gone as a whole without a reboot, and evidently 0.01K can add up over time.

root@gen-uge-exec-p080:/root  rmdir /sys/fs/cgroup/memory/UGE/* /sys/fs/cgroup/cpuacct/UGE/* 2>/dev/null
# you can rmdir cgroup directories that are in use, the kernel won't let you if any processes belonging to them are alive
root@gen-uge-exec-p080:/root  free -h
              total        used        free      shared  buff/cache   available
Mem:           754G         94G        632G        2.7M         27G        630G
Swap:            0B          0B          0B


tl'dr We were relying on reboots to clean up the cgroup directory.  We're nearly constantly taking down nodes, running hardware tests and rebuilding them. With the pandemic on we hadn't been doing that because datacenter access was supposed to be in emergencies only. Without that, the cgroup directories had been growing without bounds, slowly eating up memory. (edited) 
