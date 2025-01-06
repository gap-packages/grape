
The GRAPE 4.9.2 Package for GAP
===============================

GRAPE is a GAP package for computing with graphs and groups, by 
Leonard Soicher, with contributions from Steve Linton, Alexander
Hulpke, Jerry James and Max Horn, and including Brendan McKay's nauty
(Version 2.8.6) package.

The GRAPE package and the source included with this distribution are
copyright (C) Leonard Soicher 1992-2024, except for the following:

- the nauty 2.8.6 package; see the copyright notice in the file
nauty2_8_6/COPYRIGHT
- Steve Linton's SmallestImageSet function in lib/smallestimage.g

Except for the nauty 2.8.6 package, which is licensed under the Apache
License 2.0, GRAPE is licensed under the terms of the GNU General Public
License as published by the Free Software Foundation; either version
2 of the License, or (at your option) any later version. For details,
see <https://www.gnu.org/licenses/gpl.html>.

Referencing GRAPE
-----------------

Please reference your use of the GRAPE package in a published work
as follows:

L.H. Soicher, The GRAPE package for GAP, Version 4.9.2, 2024,
<https://gap-packages.github.io/grape>.

Questions, remarks, suggestions, and issues
-------------------------------------------

For questions, remarks, suggestions, and issues, please use the 
issue tracker at <https://github.com/gap-packages/grape/issues>.

Installing GRAPE
----------------

The official GAP Windows distribution includes the GRAPE package
fully installed.  Thus, GRAPE normally requires no further installation
for Windows users of GAP. What follows is for Unix users of GRAPE.

You do not need to download and unpack an archive for GRAPE
unless you want to install the package separately from your main
GAP installation or are installing an upgrade of GRAPE to an
existing installation of GAP. 

If you do need to download GRAPE, you can find the latest archive
.tar.gz file for the package at <https://gap-packages.github.io/grape>.
The archive file should be downloaded and unpacked in the `pkg`
subdirectory of an appropriate GAP root directory.

If your GRAPE installation does not already have a compiled binary of
the nauty/dreadnaut programs included with GRAPE and you do not want
to use an already installed version of nauty or bliss, you will need to
perform compilation of the nauty/dreadnaut programs included with GRAPE,
and to do this in a Unix environment, you should proceed as follows. After
installing GAP, go to the GRAPE home directory (usually the directory
`pkg/grape` of the GAP home directory), and run `./configure <path>`,
where `path` is the path of the GAP home directory. So for example, if
you install GRAPE in the `pkg` directory of the GAP home directory, run
`./configure ../..` Then run `make` to complete the installation of GRAPE.

Testing instructions for the GRAPE package can be found in Chapter 1 of
the GRAPE manual, available from <https://gap-packages.github.io/grape>.

