==========
networking
==========


So we more our less had one huge monstrosity of a broadcast domain.  I wound up
saying, "hey this really sucks".  My partener bill said lets rip it out then.

Rather than go the whole three tier way, we opted for l3 at top of rack.  I
didn't want to do three tier because you can only buy switches so big on a
research budget.   We wound up going with a clos architecture, so every lower
tier switch is connected to each top tier in a mesh fashion.  This means that
if we don't oversubscrbe the lower switches, we get non-blocking traffic.  This
allowed us to get the throughput that bigger badder gear would have brought,
with more cheaper units, while providing extra fault tolerance.  Now, we do
actually oversubscribe at the more-or less industry rule of thumb 3 to 1.  But
I have librenms watching polling the link saturation over snmp so we can watch
it carefully.

I was toying around with the idea of going completely layer 3, but decided it
didn't make much sense for our use case.  We wouldn't be eliminating ARP, even
if we were, we aren't that latency sensitive anyway.  Why install frrouting,
and build tooling to manage the ip addresses and dns entires for the boxes when
we can just trunk vlans to top of rack, overlay vxlan for things like vmware,
fire it up and let dhcp handle the rest.   There was also the security
implication of other teams have root on a box, I wasn't too keen on having bgp
configuration on the box where folks could mess with it.

* every first hop switch tracks the ip address switch creates a route for every
* attached host hosts routes are spoken over a routing protocol like bgp

Now you the networking gear still has to handle the arp request because the
servers still think in layer two terms. But some people have solved that
problem.  I've heard through the rumour mill that google actually strips all of
the ethernet frames out of their traffic in the datacenter.

We don't do a route for every host.  I, just drop a vlan tagged subnet
on each rack and let dhcp handle the rest.


vxlan
=====

virtual extensible lan.

It's nothing fancy, source device sends layer two traffic', source switch
catches is it, knows the destination device is in a separate location,
literally shoves the  layer2 frames into layer 4 datagrams, and passes along to
the destination switch, destination switch unpacks the datagram and passes the
ethernet frame along to the destination device.

To sum it up, it lets you have broadcast domains span multiple physical
locations.

This can lend itself to sub-optimal traffic coming into the vxlan, i.e routed
to a switch, that has to then encapsulate the traffic and pass it along to the
correct switch.  But is not a large issue if you keep your vxlan's limited to a
few devices.  Outbound traffic and inter-vxlan traffic is still pretty close to
optimal.



types of networking
===================
ethernet
infiniband
fc
fcoe
mpls -> mult-protocol label switching
