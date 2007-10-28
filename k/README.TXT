Since I should document this somewhere, here's the procedure
for building the Slackware kernel package.  I do not patch the official
kernel sources, but it's not exactly a virgin either.

=============================================================
Version specific notes (if any):
=============================================================
  
For a 2.6.x kernel (much easier):

   Untar Linus' source in /usr/src.
   Make all files owned by root:root with reasonable perms.
   Install a suitable .config, or use make menuconfig, etc.

   An example would be to use one of the config files here:
   # cat config-smp-2.6.21.3-smp > /usr/src/linux-2.6.21.3/.config

   Then run the build programs:

   make oldconfig
   make bzImage
   make clean
   rm .version

That's it!  You now have a clean Slackware-configured Linux source
tree.

NOTE TO USERS OF THE NON SMP KERNELS:

Sorry to shout.  :-)

By default, the kernel in Slackware supports SMP.  With as common as
multicore CPUs and SMP boards have become, this seemed like the
obvious choice.  The kernels are probably better for single CPU
machines, too, if they will run them.

If you have to use one of the non SMP kernels (huge.s or generic.s),
then you will need to reconfigure your kernel sources to build any
additional kernel modules.  In order to compile outside kernel
modules and such, you will need to build your kernel once with a
non-SMP .config.  The process is much the same:

cat config-generic-2.6.21.3 > /usr/src/linux-2.6.21.3/.config

   make oldconfig
   make bzImage
   make clean
   rm .version

At this point if you are running huge.s or generic.s, you should have
no problems building kernel modules.
 
Have fun! :-)

Pat

