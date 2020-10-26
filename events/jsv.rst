
So we have a scheduler.  This scheduler takes arbitrary descriptions of work
from end users, and generates jobs from them.  Jobs are then ran on an
arbitrary server and are broken down into unix tasks (processes / threads)

Users are supposed to describe the the need of the Linux tasks that get derived
from a job.  The thing is, users don't always think in terms of processes or
threads.   So at submit time, some checks need to happen.

Did you request memory? How about hardware threads? is the runtime limit in
bounds?  etc, etc.  Grid engine has an interface for this, and it's called the
job submission validator.  It even allows you to modify a job description,
which is incredibly useful.

Univa, the company that sells a closed source version of grid engine, is even
nice enough to ship some bash functions you can source that have little baked
in functions like `accept_job`, `reject_job` etc.

There is a big kicker though.  We all know that bash is abysmally, crushingly
slow.  Like just sourceing the file and accepting a job with no checks, just
blindly saying 'OK' takes over 500ms.  Adding some basic checks pushes you into
the 750ms range.  Thats' less than 120k jobs per day.  On an average day we
have well over 500k jobs.   And yes, while the scheduler does run several jsv
processes concurrently, this still means that users jobs are going to block
before submission, which makes for unhappy users.

I'm going to side bar here for a second. I don't know about you, but I hate how
folks use the term customer,  I know your customer centric over there so bear
with me.  I feel like often it's used as ane excuse to disassociate oneself
from the end user.  The whole my team vs everyone else is so impersonal.  When
I got hired, there were only 250 people or so, we're probably around 700 now.
That's like a high school graduating class. I **know** most of these people
submitting jobs.  And even if I didn't, I want people to be able to go about
their day with as few painpoints as possible.  If it's something in my control,
I'm going to make anyone's day a little better whether it's someone at work, a
neighbor, or some stranger at a gas station.


Well anyway, I needed to make this thing go.  I picked apart the bash script
and realized that the interface was standard in based. parsing strings for
newlines with a simple dispatcher for the various commands.  The scheduler
seemed to  be creating fifo, calling dup or dup2, and attaching the jsv
processes standard in.

So I wrote a little dumy shell program that simply save the commands recieved
and sumbmitted every type of job, there's only 3 or 4.

Once I had those I wrote my own fake scheduler that set up some fifo's, forked,
modified the file descriptors properly, then called execv and got to work.


I learned a few things early on.  the most important being that grid engine
does **not** sanitize it's inputs and this thing is the best that the mid 90's
had to offer.  Meaning that it was around before fuzzing.  Fun things like
sending two back to back newlines would cause it to segfault.


In order to make it go as fast as it can I squeezed every bit of performance I
could think of.  No using the string standard libraries, keep track of lengths
and pass a size.

Finding the common denominator between commands and checking the fewest
characters possible, or since you're only using a subset of functionality you
get one of those few chances to roll your own string to double, or implement
pow with a switch / fallthrough and bit-shifts.

It's really fun to see functions you write out perform the standard ones, by a
factor of two or more.

Though rather than roll my own key value store, I used howard chu's lmdb which
is a memory mapped key value store.  Since each each jsv is single threaded and
the scheduler handles parallelization at the process level, I was able to run
everything with it's own memory mapped store and write async.   At job
acceptance, though  I then sync force data to disk, so if the scheduler
implodes on user input, I can retroactively examine the raw user input.  I also
syslog a lot of the base metrics, including the time it took for each part of
the validation, time to read input, time to store it, time to write any
modifications and accept the job, so I can then parse it later in elastic
search.

So, if you remember before bash was taking 750ms, I got it down to under 40k
nanoseconds.

I also got metrics logging and info for any future root cause analysis of
scheduler implosion.
