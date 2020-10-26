When I first got hired on things were a wreck.  We had people on the team that were making arbitrary changes without review, lying about what they did, or where they were at. 

As a result. 

1, my boss got hired on and cleaned house execpt for me.  Oh man, that sucked.
2. nobody had any confidence in our team.

We do a lot of HPC.  Which uses nfs **everywhere** and if you didn't know
already, network filesystems are an abomination.

We were having mountpoints that intermittenly would throw 'too many symlink'
errors frequently, but what appeared to be at random.  And I wound up tracking
down the root cause of it.

In nfs you a client and a server with a network in between.  In real life not
all traffic makes it from end to end, so nfs has the concept of retransmit's
and retries.

retransmits are the number of times it will try to re-transmit remote procedure
call.  retires are the number of times it will go through a series of
retransmits before 'giving up'.

There are two behaviors when you hit the number of retries.  You have hard, or
soft mounts.  hard mounts will simply mark the number of tries back to zero and
block i/o indefinitely, soft mounts will raise an error to the application.

Personally,I when you're dealing with jobs you need to let them handle errors, but that's just me, I digress.

I had been trying to replicate this by setting up a VM, and simply toggling the
nic on and off.  It was trivial to reproduce.  

1. our networking, which my and partner in crime ripped out and replaced shortly after this was unstable.
2. our retransmit times were set to be super short so you'd loop pretty agressivly.


I can't remember the exact numbers, but I could start interacting with a
filesystem, start a timer, toggle off the nic, wait for the failure case, and
then do the arithmetic.  I turned out that as soon as we hit the number of
reries wher we were supposed to loop, since we were hard mounted afterall, the
'too many levels of symbolic links issue' would arise.

This lent itself to a super simple work around.  Increase the time for
retransmits to about a minute, and then increase the number of retries to
something insane.  The idea being that a mount point isn't going to disappear
for a day, you'll see it at some point and the number of retries will never hit
the max.

Now, if these were regular mount points, we could change the fstab, force
unmount the broken ones, and remount them everywhere.  But these were autofs
moutnpoints.

So if the mountpoint was stale, and a process had an open file descriptor to a
file that no longer exists, or a user had an interactive shell and was standing
in the 'bad' mountpoint.  It would not remount it. So it stayed broken forever.

This is where the trust building part came in.  I had the workaround, but
couldn't implement it live.  Our job success rate was under the 50% range.

I went to my boss, I report right to the director.  'I have the fix' let me
rebuild everything tonight.  And since we're research and everything is always
11th hour he was really hesitant.

the teams automation for rebuilding was historically broken, nobody trusted us.
He barely knew me. But  still I pressed him.  I said it will work, I've
re-written all of the automation for rebuilding the infrastrucutre from
scratch, I have the fix.  This will work.  Trust me, I've got you.   Tell
everyone we have a hotfix and we're taking everything down.  He asked how long
I needed.  I told him it would take 2 hours to rebuild everything, and to give
me four hours so we didn't go over.

And he did it, he went to bat, trusted me and I delivered.  I had everything
rebuilt within an hour and within an hour and a half all the automated tests
had ran.

Not only did I gain his trust, he gained the trust of the organization which
opened up a bunch of possiblites for us including ripping out the aformentioned
network and building a new one from the ground up.
