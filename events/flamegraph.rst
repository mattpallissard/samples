

Had an openafs filesystem.  That was experiencing intermittent latency issues.  I had an nfs filesystem on identical hardware to compare to.  I had written a bash script that reproduced the issue, write a series of large files, small files, open, read, seek, stat, etc.  I was able to reproduce the issue on openafs, but not on nfs.

Run through the whole reasou

I couldn't immediately rule out disk because afs stores files in a binary format whereas the linux nfs stores file on each end.  testing that would be doable, but a bit tricker.

Which was able to rule out the network to some extent.
