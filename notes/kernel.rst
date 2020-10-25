======
kernel
======


Kernel is a low level hardware abstraction.  In a monolithic kernel linux, It manages drivers and handles timesharing of resources.

And there are some blurred lines in the drivers portion.  things like infiniband and rdma or smartnics.  where the design is less about application using the kernel as an itermediaray and more along the lines of having a space in memory, and reading and writing data.  Then letting the hardware handle the protocol specific things on an asic.

Even the monlithic lines are blurred as linux has module support.


In other words it's a generalized solution for hardware.  Without it everyone would be 'bare metal' programming handling all of the kernel responsibilities.

* boot
* memory management
* interrupts
* task scheduling
* peripherals
* errors and faults
* debugging all of that

Linux is a monolithic kernel


kernel userspace boundary
=========================

naturally, there are rules and semantics to each of these
system calls
signal handlers
call gates -> a memory address you can write instructoins to.  kernel will verify and execute.
interrupts
memory based queue
bpf which is a really just a combination of a system call and memory based queus

  * honesly I'm suprised that bpf wasn't implemented with a call gate.
    * the current syscalls is rather large.
    * it's probably not portable across all architecturs
  * I assume there are some implementation details I'm unaware of


peter zijlstra, ingo molnar, mel gorman -> scheduler
andrew morton, mm-next
greg kh - > stable and drivers, read write
al viro -> vfs, read rwite
ted ts'o -> ext4 and fileysstem stuff
david howeells -> keyrings
Alexei Starovoitov, wrote bpf
facebook dudes yonghong song and andreii nakryiko manage the libbpf tooling


exciting things
===============

bpf skel is pretty exciting, allowing the symbols to be generic so you're bpf programs are portable across kernel versions. 5.8 is the minimumversion supported

It's only in the discussion phase, but the big player's (linux, greg kg) initial reception on the mailing list was very positive. the rust tooling, not because I'm a rust fanboy, I like things about it like exception types, how it feels like the people developing it borrowed a lot from stack, cabal and opam, taking the good things of the. But, honestly have barely used it. What I'm excited to see some new folks bring new ieas to the table.
