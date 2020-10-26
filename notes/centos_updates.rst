



Provisioning can a real pain.  Every time the OS is tweaked, the provisioning
process has to be tweaked as well.  Each operating system has their own way of
managing the network, the mountpoints, name resolution, automounts, cronjobs,
etc.  In order to ease future OS migrations we pushed everything that is
distribution specific into the systemd toolset.




containers

On the infra team, we leverage containers.  We use them to deploy software that
would be difficult, has dependency conflicts, or is impossible to install on
the host operating system.  We use them because their generic, they give us a
standard deployment procedure that runs nearly all of our Linux-based core
services.  Which means they run nearly all of our core services.

On CentOS 7 containers run, but they're missing a lot of the functionality.
 It's either not implemented, or broken.  For example, not all of the Linux
namespaces exist, docker's network isolation is as impermeable as a sieve,
virtual interfaces are abandoned, virtual networks stop assigning ip addresses,
singularity is looking for namespacing, etc. In order to make containers work
as they should we had to build custom packages (or find someone else that
already had) for all of the following

systemd, linux-utils, docker, kernel, dbus, initscripts, lua, expat, rpm,
singularity




Not to mention the libc and compiler toolchains that had to be bootstrapped
just to build these.




systemd

CentOS 7 ships with with an absolutely ancient version of systemd, 219.  This
version has so many bugs, and lacks so many features that it actually can't be
used for our dhcp and dns clients.   The timer journaling and crash-dumps have
a bunch of bugs and missing features as well.  CentOS 8 is slightly better,
239.



In order to mitigate this we build a modern version of systemd, 243.  This is
great in the fact that it allows us to leverage the awesome tool-sets that the
systemd project provides. (systemd isn't actually one piece of software, its a
collection of several software projects) However, this can't scale forever.

A little background

In systemd, they have a dbus api which has tight integrations with polkit. 
This allows the developers of these upstream projects to iterate quickly;
writing fast software in a low level language like c, while using a high level
api abstraction layer that handles access control auto magically.  It also
works as a language agnostic bridge between software projects using different
programming languages.  Meaning that your Linux integrations get tighter and
cleaner, allowing new creative feature-rich solutions to be developed.

Here's the catch; the older versions of systemd, the ones that CentOS ship,
speak over the abi (have a C api).  So you have outdated services shipped by
CentOS that try to speak to systemd over an api that no longer exists.  Because
of this, the systemd folks shipped a c -> dbus library that translated the
binary calls to dbus messages. 

If "--enable-compat-libs" is specified while building systemd you will get a
set of compatibility libraries built that simply map the old library calls to
the new library.

However, that was only for a short time, to be used during transition phase. 
They no longer ship that so it's up to us to build and deploy that ourselves,
luckily facebook houses the source code.  We pull that down, build it, and host
it ourselves.

A little more on systemd

Did you know that systemd is actually what manages the bulk of cgroups?
 Upstream k8s and docker use it by default.  Once again, this requires a modern
systemd (and actually a modern kernel as well)

saltstack

Salt while saltsack has a CentOS set of repositories, they use the red-had
software collections.  This is handy in the fact that it allows for slightly
newer versions of software on the operating system, but winds up being very
much a pain.  It's set up with environment variables, similarly to conda, and
often causes conflicts when leveraging multiple services that use the same
package, but different versions.  That paired with the fact that the "modern"
version of python that shipped with the software collection is from 2016 drove
us in a different direction.

In order to mitigate this we opted for a very generic python venv based
deployment.  Which, in order to use a modern python, we had to build our own
and publish it.

a note on salt 2018

for salt 3k we have a really nice deployment strategy, but that isn't the case
with salt 2018.  For that we had to build 30 custom packages.  We're abandoning
them after we finish the 2018 to 3k migration, but it's worth mentioning.




salt backports-abc backports.ssl_match_hostname certifi chardet cython
dbus-python docker docker-pycreds executor futures humanfriendly idna jinja2
markupsafe msgpack-python proc property-manager pycrypto python pyyaml pyzmq
requests setuptools singledispatch six tornado urllib3 verboselogs
websocket_client kernel

Containers are a slick construct in the Linux ecosystem.  But, they actually
aren't actually a first-class construct.  They are constructed out of
namespaces and cgroups, which are first class objects.  When a process is
spawned, the kernel can be told to isolate it and it's children's networking,
filesystems, cpu, memory, etc.  This is all a container is; 'hey kernel, when I
fork/execv this binary don't let it see other processes, it's root directory is
located here, etc, etc'  This is how all of the container runtime engines
work.  In fact, a s tarball of a filesystem, and a json payload that tells the
runtime how to fork and and setup the namespaces is all an OCI container is.

All of these namespaces though weren't implemented at the same time.  They were
incrementally added to the kernel.  That and all of the cgroups implementations
have been completely re-written with a new interface, v2.  As a result, to
leverage all of the container features and avoid bugs we upgrade the kernel. 
The CentOS 7 version is 3.10, released in 2013.  CentOS 8 is 4.18, released in
2018. We have 5.4 currently installed, with 5.9 queued up for next patch cycle.

but wait, there's more

Namespaces have to be mounted, virtual filesystems have to be interacted with,
user id's have to be mapped or isolated once they exist otherwise they are
useless.  This means we have to upgrade binaries like mount, setsid, in order
to use these new features.  Here's the full list of packages replaced by
util-linux

cal chfn chmem choom chrt chsh col colcrt colrm column cytune dmesg eject
fallocate fincore findmnt flock getopt hardlink hexdump i386 ionice ipcmk ipcrm
ipcs isosize kill lastb linux32 linux64 logger login look lsblk lscpu lsipc
lslocks lslogins lsmem lsns mcookie more mount mountpoint namei nsenter prlimit
raw rename renice rev script scriptreplay setarch setpriv setsid setterm su
tailf taskset ul umount uname26 unshare utmpdump uuidgen uuidparse wdctl
whereis write x86_64 addpart agetty blkdiscard blkid blkzone blockdev cfdisk
chcpu clock ctrlaltdel delpart fdformat fdisk findfs fsck fsck.cramfs
fsck.minix fsfreeze fstrim hwclock ldattach losetup mkfs mkfs.cramfs mkfs.minix
mkswap nologin partx pivot_root readprofile resizepart rfkill rtcwake runuser
sfdisk sulogin swaplabel swapoff swapon switch_root uuidd wipefs zramctl




on automation

Automating all of these package installations is not a trivial task.   The
first set of packages built and automated where the salt and related python
libraries.  The first systemd upgrade was next, then all of the dependencies. 
However, it became apparent in subsequent patch windows that automating these
tasks was completely impossible as the automation had to be changed with every
upgrade.  Rather than moving all of the software versions forward we were
trying to map software moving forward, to software frozen in time.  This is
duplicating a lot of work as all of the upstream software projects ensure some
level of compatibility.  tl'dr the work changed every release so the automation
was a moving target.

CentOS freezes software versions for 10 years.  This means the OS software
package that we are forced to use doesn't support new features or breaks when
old features disappear.  This is especially frustrating given the fact that the
issues are resolved upstream by the software owners, maintainers and authors.

the hidden cost of a 'supported operating system'

So we run a "supported os" with CentOS.  Supported in what way?

Do we get security updates? yes Do we get bug fixes? yes, to an extent Do we
have vendor support? no Does is support the container ecosystems we need? no
Does it support the operating system services we need? no Does it support new
packages? no Is there tooling available to trivially replace arbitrary parts of
the OS to fit our needs? no

Here's an incomplete list of custom RPMs we replace.  Note, well over 75% of
these are built by us, the rest still have to have tooling around them to sync
them from upstream providers.  (This list does not include the standard elrepo
packages that we upgrade)

dbus-1.13.12-1.ihme.el7.x86_64.rpm dbus-debuginfo-1.13.12-1.ihme.el7.x86_64.rpm
expat-2.2.9-1.ihme.el7.x86_64.rpm expat-debuginfo-2.2.9-1.ihme.el7.x86_64.rpm
initscripts-10.02-1.ihme.el7.x86_64.rpm
initscripts-debuginfo-10.02-1.ihme.el7.x86_64.rpm
lua-5.3.5-1.ihme.el7.x86_64.rpm lua-debuginfo-5.3.5-1.ihme.el7.x86_64.rpm
microdnf-3.0.1-1.ihme.el7.x86_64.rpm
microdnf-debuginfo-3.0.1-1.ihme.el7.x86_64.rpm rpm-4.15.1-1.ihme.el7.x86_64.rpm
rpm-debuginfo-4.15.1-1.ihme.el7.x86_64.rpm
rpm-plugin-systemd-inhibit-4.15.1-1.ihme.el7.x86_64.rpm
systemd-243-1.ihme.el7.x86_64.rpm systemd-compat-libs-243-1.ihme.el7.x86_64.rpm
systemd-compat-libs-debuginfo-243-1.ihme.el7.x86_64.rpm
systemd-debuginfo-243-1.ihme.el7.x86_64.rpm
systemd-debuginfo-244-1.ihme.el7.x86_64.rpm
util-linux-2.34-1.ihme.el7.x86_64.rpm
util-linux-debuginfo-2.34-1.ihme.el7.x86_64.rpm
ihme-nss-pam-ldapd-0.9.8-1.el7.x86_64.rpm
ihme-nss-pam-ldapd-debuginfo-0.9.8-1.el7.x86_64.rpm
infra-python-3.8.1-1.ihme.el7.x86_64.rpm
infra-python-debuginfo-3.8.1-1.ihme.el7.x86_64.rpm
infra-python-systemd-234-1.x86_64.rpm lldpd-0.9.7-2.1.x86_64.rpm
lldpd-debuginfo-0.9.7-2.1.x86_64.rpm lldpd-devel-0.9.7-2.1.x86_64.rpm
parallel-20150522-1.el7.cern.noarch.rpm percona-toolkit-3.1.0-2.el7.x86_64.rpm
singularity-3.5.3-1.el7.x86_64.rpm
singularity-debuginfo-3.2.0-rc2.el7.x86_64.rpm
singularity-debuginfo-3.2.1-1.el7.x86_64.rpm
stata15-15.0-20190812_29.x86_64.rpm telegraf-1.6.4-1.x86_64.rpm
containerd.io-1.3.7-3.1.el7.x86_64.rpm docker-ce-19.03.9-3.el7.x86_64.rpm
docker-ce-cli-19.03.9-3.el7.x86_64.rpm
docker-ce-selinux-17.03.3.ce-1.el7.noarch.rpm ihme-salt-2018.3.1-1.x86_64.rpm
ihme-salt-backports-abc-0.5-1.x86_64.rpm
ihme-salt-backports.ssl_match_hostname-3.7.0.1-1.x86_64.rpm
ihme-salt-certifi-2018.11.29-1.x86_64.rpm ihme-salt-chardet-3.0.4-1.x86_64.rpm
ihme-salt-cython-0.23.3-1.x86_64.rpm ihme-salt-dbus-python-1.2.8-1.x86_64.rpm
ihme-salt-docker-3.7.0-1.x86_64.rpm ihme-salt-docker-pycreds-0.4.0-1.x86_64.rpm
ihme-salt-executor-20.0-1.x86_64.rpm ihme-salt-futures-3.2.0-1.x86_64.rpm
ihme-salt-humanfriendly-4.12.1-1.x86_64.rpm ihme-salt-idna-2.8-1.x86_64.rpm
ihme-salt-jinja2-2.10-1.x86_64.rpm ihme-salt-markupsafe-1.0-1.x86_64.rpm
ihme-salt-msgpack-python-0.5.6-1.x86_64.rpm ihme-salt-proc-0.14-1.x86_64.rpm
ihme-salt-property-manager-2.3.1-1.x86_64.rpm
ihme-salt-pycrypto-2.6.1-1.x86_64.rpm ihme-salt-python-2.7.15-1.x86_64.rpm
ihme-salt-pyyaml-3.12-1.x86_64.rpm ihme-salt-pyzmq-16.0.4-1.x86_64.rpm
ihme-salt-requests-2.21.0-1.x86_64.rpm ihme-salt-setuptools-39.0.1-1.x86_64.rpm
ihme-salt-singledispatch-3.4.0.3-1.x86_64.rpm ihme-salt-six-1.11.0-1.x86_64.rpm
ihme-salt-tornado-4.5.3-1.x86_64.rpm ihme-salt-urllib3-1.24.1-1.x86_64.rpm
ihme-salt-verboselogs-1.7-1.x86_64.rpm
ihme-salt-websocket_client-0.54.0-1.x86_64.rpm
kernel-ml-5.9.0-1.el7.elrepo.x86_64.rpm
kernel-ml-devel-5.9.0-1.el7.elrepo.x86_64.rpm
kernel-ml-doc-5.9.0-1.el7.elrepo.noarch.rpm
kernel-ml-headers-5.9.0-1.el7.elrepo.x86_64.rpm
kernel-ml-tools-5.9.0-1.el7.elrepo.x86_64.rpm
kernel-ml-tools-libs-5.9.0-1.el7.elrepo.x86_64.rpm
kernel-ml-tools-libs-devel-5.9.0-1.el7.elrepo.x86_64.rpm
git-2.8.0-1.WANdisco.308.x86_64.rpm




what we can do about it

Using an operating system that keeps closer to mainline completely removes all
of the work listed above.

Now, there is a catch.  Porting things from operating system to operating
system is a tedious, time consuming process. We still have Ubuntu 14.04 hosts.
 We chose CentOS as they have a longer support cycle, 10 years.  This was to
cut down on the amount of engineering hours spent migrating from OS to os.
 Things that follow mainline more closely typically have shorter lifecycles,
freezing packages 2 to 4 years instead of 10.

let it roll

But there is another paradigm to operating systems.  Instead of managing
version pinned software back-porting bug fixes for a few years, then performing
big fork-lift moves to a newer disto version you simply pull newer software
from upstream.  This eliminates the idea of distribution versions.  There is
only one version, the latest.  As an OS distribution maintainer why try to fix
old software yourself when you can let the owner of the software fix it for
you?  This has a lot of benefits

This is called rolling-release.  It is a paradigm that has been followed in
software development for years.  You may have heard the phrase of release
early, release often.   It is formally called continuous delivery.  This can be
applied to operating systems as well.

it allows your os to have new software softare it cuts down on distribution
introduced bugs these are very common did you know that the CentOS kernel
package has a series of over 500 manually generated patches that are applied to
every kernel release?  did you know that many of the severe CentOS tls related
regressions were caused by incorrect back-porting of patches?  you no longer
have to map new software the business needs to old software the OS forces you
to have Upstream developers do the work for you!  you no longer have to fork
lift migrate operating systems myths on stability

But the latest software is unstable!

No, it's not.  The fixes for the software originate upstream already.  Rolling
release doesn't mean 'get rid of all testing during your patch cycle'.  You
still version freeze your repos, promote repos after testing, and hang on to a
few historical versions so you can roll back.  (Although, upgrading again is
typically the fix in rolling release!).

We already are installing the latest software.  Whether we use rolling or point
release methods, the versioning argument is irrelevant.  What is relevant is
that moving to a rolling release operating system that ships new packages is
less work.  This is due to the fact we don't have to rebuild and repackage all
of our tooling.

But we'd have to learn all new tooling for these rolling release distros!

No, no you wouldn't.  We already have all of the core services on a box in
containers or in systemd.  The deployments and automation stay the same.

But managing a rolling release distro is more work!

If we were to upgrade to the "newer" CentOS 8 we would actually have older
packages than those we have on CentOS 7.  We would have to rebuild and
repackage all of the current software we have in order to prevent a downgrade. 
Managing a point-release operating system requires a lot of work upfront as
well as a big fork-lift operation every few years.
