
config management
=================

problem: multiple operating systems, 4.  They were all handled different ways,
networking, systemd, etc.  It was a real mess.  So to take networking for an
example,  you have /etc/network/interfaces, /etc/sysconfig/network,
/etc/systemd/networkd.  Each with thier own syntax to define the end state,
configuration file, and each with their own logic to operate over the
definition and set the end state.  The same thing goes with services, upstart,
sysvinit, systemd.  Same with automount points. I look at this and recognize a
two.

* inconsitent descriptions of work, the data, how it's represented in the
* configuration managment inconsitent work, what operations are performed on
* the box to take the description and set the end state.

Now, saltstack has facilities for this, baked in.  You use the network state
module or the service state module, it will auto detect the operating system,
and automaticall set the correct config files, and execute the correct commands
for **most situations**.  As soon as you deviate from the basic cookie-cutter,
you're forced into writing your own modules, modifying theirs, or writing a ton
of one off logic.

I thought there was a simpler way.  

Systemd handled services, timers (what a cron job wants to be when it grows
up), network interfaces **and the routing / rule tables!**, mountpoints,
automountpoints.  All with the exact same ini syntax, all with the exact same
set of tcommands.  The only thing that differs between the two is the file
extension and the path where the file is located.

Are you all familiar with the ML family of languages, or haskell?

Well with those languages they have this construct that's called a functor and
a functor is an abstraction mechanism.  It's used in cases where the logic
between types is the same across the board.  Think of a binary tree, whether
you have a character, a string, an integer, a float, or some more abstract
datatype.  The operation is the same.  You walk the tree, comparing values as
you go.  The rules stay the same, the only difference is the comparison
operation.

I thought that if I were writing a program, this situation would call for a
functor.  So rather than write duplciate states of identical logic for
networking, mounts, services, timers, automounts.  I wrote one general systemd
state that performed the same process for each.  Then just like in ML, all you
wind up doing is importing the module,  or jinja template in this case, and
handing it a and I'm finger quoting this, 'signature', which is just the
extenstion service.

This means I write one generic module, that turns each subsequent state
implementation into two import statements and two lines of code.

With that in mind this problem looks just like a functor.

I was pretty comforable that systemd wasn't going anywhere anytime soon. So I
decided we were going to kill off all of our operating systems that didn't have
first class systemd support, which left only centos7.  Once I justified all of
the above, I got unanimous buy in and was green lighted.

Now, that cut down on the work, and standardized on the input data format for
most base configuration on a given server.  But still left a lot of duplicate
data.

Say for example we want mountpoint A to be on all boxes, but mountpoint A and
B to be on all B boxes, but only mountpoint B to be on a subset of B boxes,
we'll call B'.

typically you'd have three definitions of that data, one for each role.  But
rather than do that I cooked up a taxonomy based on items that describe the
box.  so name, operating system, etc. Salt has baked in facilities for this
sort of thing in pillar stack.  If you were to do this in puppet you'd use hiera.

you now have a tree that lookes like this.

mount
├── default.file  <- this has the descripton of everything related to all mounts
└── roles
    └── b
        ├── data.file <- this has only the description of things related to B mount, it's the union of default and B
        └── roles
            └── b'
                └── data.file <- this has only an override option for A mount, it's the (union of default and B) - the A mount description




no in order to make use of this I came up with a naming convention that doesn't suck.  so you  could use the name of a box to drive the roles applied


	* several roles are assigned by names
	* states are assigned to roles
	* states are composed of other states. (We call them meta states in house)

draw name -> roles -> states -> data

	* broke down states to their components.  Lots of common patterns.
	* docker containers
	* mountpoints/automounts
	* pam
	* secrets/pki
	* services
	* timers

rather than having each state that handles pam, secrets, docker_containers, I cooked up an idea of meta states.  Which are states composed of states.  This prevents states performing conflicting operations, and lets one audit things way more efficiently.  I just had to hand over data to auditors on thursday,  It's really nice to be able to 



* you wind up with a directory hierarchy containg data.  again, using packages as an example you'd have

└── packages
    └── states
        ├── docker
        │   └── roles
        │       ├── compute
        │       │   └── os
        │       │       └── ostype
        │       ├── etc
        │       │   └── os
        │       │       └── ostype
        │       └── network
        │           └── os
        │               └── ostype
        ├── ldap
        │   └── roles
        │       ├── compute
        │       │   └── os
        │       │       └── ostype
        │       ├── etc
        │       │   └── os
        │       │       └── ostype
        │       └── network
        │           └── os
        │               └── ostype
        └── pam
            └── roles
                ├── compute
                │   └── os
                │       └── ostype
                ├── etc
                │   └── os
                │       └── ostype
                └── network
                    └── os
                        └── ostype

* and they go deeper than that. It's set it up with one big outer loop that
  iterates over states states within that we iterate over states once more and
  roles twice, allowing os and oteher hardware specific overrides in every
  loop.


* This strategy also allows for *a lot* of code reuse. for example


* arguably more importantly I taught salt how to speak to timescale for job returns and the master job cache.
  * this gives live and historic metrics on states, commands and errors encountered,
  * IT's a tsdb, which is just postgres under the hood.
    * the upstream salt postgres returner was pretty terrible performance wise both in terms of space and time.
      * storing integers as text
      * it stored dictionary's as postgres json instead of parsing the fields
      * I parsed all of the python dicts, and had salt cast them as the proper types, threw indexes on the columns that matteredA
      * I had to teach it how to generate a new job id format as a result, but that was straightforward and now our timeseries queries are highly performant.

To sum it all up.  I was able to take a wildly sprawling codebase, if you can
all yaml code.  And cut down on the space considerably.  I took it from O(N*K),
to O(log n).  This helps tremendously when we have new engineers and they ahve
to come into our environment and get trained up.

They hardly ever have to touch the os logic, they simply have to describe the
end state.

We also gained a lot of insight into the salt jobs, and have an audit record of
when chagnes failed, when folks ran arbitrary commands.
