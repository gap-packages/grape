Main changes from GRAPE 4.9.1 to GRAPE 4.9.2 (11 October 2024)
--------------------------------------------------------------

1. Included new functions ``IsVertexColouring`` and
``GRAPE_ExactSetCover``.

2. Made new documentation chapter ``Auxiliary Functions``,
currently containing documentation for ``SmallestImageSet`` and
``GRAPE_ExactSetCover``.

3. Made a performance improvement for ``CompleteSubgraphsOfGivenSize``
for the case when all weightvectors are (0,1)-vectors of dimension
greater than 1.

Main changes from GRAPE 4.9.0 to GRAPE 4.9.1 (30 August 2024)
-------------------------------------------------------------

1. Made an improvement to the proper vertex-colouring search process.

2. Added documentation and test for Steve Linton's function
``SmallestImageSet``.

3. Added further (small) improvements to the documentation, including
three new references.

Main changes from GRAPE 4.8.5 to GRAPE 4.9.0 (09 December 2022)
---------------------------------------------------------------

1. The included version of nauty is now 2.8.6. You should expect canonical
labellings produced by nauty to change from previous versions of GRAPE.

2. Made function ``GeneralizedOrbitalGraphs`` more flexible, and updated
the documentation.

3. Renamed function ``OrbitalGraphColadjMats`` by
``OrbitalDigraphColadjMats``, but the old name still works.
Also, improved the documentation for this function.

4. Added some tweaks to functions to compute complete subgraphs, which
should hopefully improve overall performance.

Main changes from GRAPE 4.8.4 to GRAPE 4.8.5 (26 March 2021)
------------------------------------------------------------

1. Fixed bug in `EdgeOrbitsGraph`, where previously when given an empty
list of edges, an error occurred and a break loop was entered.

2. Better error checking and more consistent use of streams for
dreadnaut/nauty and bliss I/O. The default now is to use files for
these streams.

3. New boolean global variable `GRAPE_DREADNAUT_INPUT_USE_STRING` which
by default is set to `false`. If set to `true` then a string is used
for the stream for input to dreadnaut/nauty; if set to `false` a file
is used for this stream.  Using a string is faster than using a file,
but may use too much storage. Both possibilities for 
`GRAPE_DREADNAUT_INPUT_USE_STRING` are now tested in the package tests.

4. Since simple graphs are no-longer input as directed graphs to nauty
and bliss, some tests for non-simple graphs with colour classes were
added to the package tests.

Main changes from GRAPE 4.8.3 to GRAPE 4.8.4 (05 March 2021)
------------------------------------------------------------

1. Simple GRAPE graphs are now output to nauty as nauty undirected graphs
and are so treated by nauty.  (You should expect canonical labellings
produced by nauty to change from previous versions of GRAPE and to
be different from those produced by bliss.) Thanks to T. Jenrich for
suggesting this efficiency improvement.

2. Simple GRAPE graphs are now output to bliss as bliss undirected graphs
and are so treated by bliss.  (You should expect canonical labellings
produced by bliss to change from previous versions of GRAPE and to be
different to those produced by nauty.) Thanks to T. Jenrich for suggesting
this efficiency improvement.

3. If the return value (i.e. exit code) of an execution of a bliss or
dreadnaut executable is not zero, then an error message is printed and
a break loop is entered. This is to help protect against an otherwise
undetected program error exit or crash which **could produce wrong
results**. (We had run across one instance of such a problem with bliss
and a particular large graph.)

4. The identity canonical labelling is now correctly returned from an
execution of bliss.  (The previously returned (wrong) value in this
case was the empty list, which should not have led to any wrong results
for a graph isomorphism check, but should have caused a break loop to
be entered.)

5. Correction to the user documentation of 'GeneralizedOrbitalGraphs'
to make clear that the null orbital graph is not included.

6. Improvements made to the user documentation of
'CompleteSubgraphsOfGivenSize'.

7. Improvements made to the program documentation for
'CompleteSubgraphsMain'.

Main changes from GRAPE 4.8.2 to GRAPE 4.8.3 (December 2019)
------------------------------------------------------------

1. Implemented new components maximumClique and minimumVertexColouring
for (simple) GRAPE graphs. These components may be set or used by 
various GRAPE functions. 

2. Function GraphImage documented, and a test added for this function. 

3. Last (accidentally) remaining function call ``Stabiliser`` changed 
to ``Stabilizer``. 

4. More tests added to tst/testall.tst.

5. Removed unused function ``GRAPE_OrbitRepresentatives``. 

6. Committed Max Horn's pull requests to fix problems with 
Windows 64-bit execution of nauty.

7. Central GAP system testing can now run tests using bliss as well
as the version of nauty included with GRAPE. 

Main changes from GRAPE 4.8.1 to GRAPE 4.8.2 (March 2019)
---------------------------------------------------------

1. Bug fixed in MaximumClique.  This bug caused a wrong answer to be
returned for an input complete graph (on more than one vertex) for the
functions MaximumClique, MaximumCompleteSubgraph, and CliqueNumber.

2. Efficiency improvements made to functions Diameter, Girth,
GlobalParameters, and IsDistanceRegular, so that if the automorphism
group of the input graph is already known then it is made use of.

3. All function calls ``Stabiliser`` changed to ``Stabilizer``. 

4. Added function GeneralizedOrbitalGraphs.

5. Documentation upgraded. 

6. Changes info moved from README to new file CHANGES.md.

7. README moved to README.md and updated. 

8. Information in file COPYING moved to README.md, and file COPYING deleted. 

Main changes from GRAPE 4.8 to GRAPE 4.8.1 (October 2018)
---------------------------------------------------------

1. GRAPE package moved on to github.

2. Indexing in GRAPE documentation made to work better.

3. Documentation for CompleteSubgraphsOfGivenSize improved. 

4. Obsolete POST_RESTORE_FUNCS no longer used.
 
Main changes from GRAPE 4.7 to GRAPE 4.8 (June 2018)
----------------------------------------------------

1. New function: HammingGraph

2. New operations: MaximumClique, MinimumVertexColouring 

3. New attributes (which cannot be stored in a GRAPE graph record, but 
are declared as attributes rather than operations so as not to
conflict with the Digraphs package): CliqueNumber, ChromaticNumber 

4. ConnectedComponent and ConnectedComponents are now operations 
rather than functions, to avoid conflicts with other developers.

5. Enhanced functionality for function VertexColouring, which can 
now be used to determine whether a graph has a proper vertex k-colouring,
and if so, to return such a colouring.  

6. Efficiency of the function VertexTransitiveDRGs improved for
transitive permutation groups having some orbitals which are not
self-paired.

7. GRAPE HTML documentation now made with version 4.12 of tth, and
displays correctly on all browsers tested (thanks to Andries Brouwer
for pointing out the problem and to GAP Support for providing a solution). 

8. The GRAPE HTML documentation links to the GAP reference manual now
work (thanks to Jerome Benoit for providing a solution).

9. The default location for a user-installed bliss executable (if used) is 
now  ExternalFilename(DirectoriesSystemPrograms(),"bliss") 
(thank you to Jerome Benoit for suggesting this). 
However, the default location of the dreadnaut executable remains
ExternalFilename(DirectoriesPackagePrograms("grape"),"dreadnautB")
to run the included version in GRAPE of nauty/dreadnaut.

10. Efficiency change to PartialLinearSpaces, to use exact cover
instead of clique search to classify "bundles".

11. Fixed small efficiency bug in CompleteSubgraphsMain. 

Main changes from GRAPE 4.6.1 to GRAPE 4.7 (January 2016)
---------------------------------------------------------

1. The included version of nauty is now the final patched 
version of nauty 2.2.

2. The user may run their own copy of dreadnaut or dreadnautB, 
rather than the included version from nauty 2.2.

3. The user may run their own version of bliss as an alternative
to nauty. 

4. A test file tst/testall.g is now included.

5. Documentation and installation instructions have been revised 
accordingly.

Main changes from GRAPE 4.6 to GRAPE 4.6.1
------------------------------------------

1. Except for nauty 2.2, GRAPE is now licensed under the GPL,
version 2 or higher.

2. Installation instructions revised.

Main changes from GRAPE 4.5 to GRAPE 4.6
----------------------------------------

1. GRAPE revised to work fully under Windows (XP or later), with an
appropriate 32-bit nauty/dreadnaut binary (made by A. Hulpke) included.

2. Installation instructions revised.

Main changes from GRAPE 4.4 to GRAPE 4.5
----------------------------------------

1. Makefile.in revised.

2. Installation instructions revised.

3. Default banner now used.

Main changes from GRAPE 4.3 to GRAPE 4.4
----------------------------------------

1. With much help from Alexander Hulpke, and using new features in GAP
4.5, the interface between GRAPE and dreadnaut is now done entirely in
GAP code. This means that as long as nauty/dreadnaut can be compiled on
a given computer, then GRAPE should work on that computer, although there
are still problems with Windows machines.

2. Graphs with colour-classes can now be handled by the automorphism group
and graph isomorphism functions. 

3. The functions Graph, Diameter, Girth, IsBipartite, IsConnectedGraph,
IsDistanceRegular, IsVertex, and IsEdge are now operations to avoid
possible name conflicts with GAP, GAP users, or other packages.

4. The internal functions OrbitRepresentatives, RepWord,
OrbitNumbers, NumbersToSets, and IntransitiveGroupGenerators renamed
GRAPE_OrbitRepresentatives, GRAPE_RepWord, GRAPE_OrbitNumbers,
GRAPE_NumbersToSets, and GRAPE_IntransitiveGroupGenerators, respectively,
to avoid possible name conflicts with GAP, GAP users, or other packages.

5. Documentation upgraded.

6. GAP code and standalone programs for the undocumented functions Enum
and EnumColadj removed.  It appears no one uses them now, and their
functionality can largely be handled by current documented GAP/GRAPE
functions.

Main changes from GRAPE 4.2 to GRAPE 4.3
----------------------------------------

1. GRAPE can now be installed via ``/bin/sh configure ../..; make``.

2. The version of nauty now used is 2.2 final, rather than 2.0beta5,
and canonical labellings may have changed.  Moreover, dreadnautB is now
used instead of dreadnaut, so there is no practical upper bound on the
number of vertices when using nauty.  All graphs stored from previous
versions of GRAPE should have their canonicalLabelling component
unbound before use with this version.

3. Added function GraphIsomorphismClassRepresentatives, which should be
used for efficient pairwise isomorphism testing of three or more graphs.

4. Function CompleteSubgraphsOfGivenSize now fully documented to include
the functionality of finding cliques with given vertex vector-weight sum.

5. Function GraphIsomorphism now documented, and for safety,
GraphIsomorphism now has a third parameter, firstunbindcanon, behaving
as in the function IsIsomorphicGraph.

6. For safety, (possibly old) canonical labellings are no longer copied
over to a graph returned by CopyGraph, GraphImage, or NewGroupGraph.

7. Changed call to StabChainBaseStrongGenerators to have three
parameters to conform with the changed functionality in this function
from GAP 4.4.5.

8. Fixed minor problem in Makefile.in (reported by A.E. Brouwer).

9. The standard archive format is now tar.gz, rather than zoo.

10. grape.bib moved to manual.bib.

Main changes from GRAPE 4.1 to GRAPE 4.2
----------------------------------------

1. Including Steve Linton's SmallestImageSet function, and using
this function for faster isomorph rejection in functions CompleteSubgraphs,
CompleteSubgraphsOfGivenSize, and PartialLinearSpaces.

2. Further improvements to CompleteSubgraphs and
CompleteSubgraphsOfGivenSize, including functionality in the latter
which will be required by the DESIGN package.

3. All global function names are now read-only.
 
4. OrbitalGraphIntersectionMatrices is no longer an 
alternative name for OrbitalGraphColadjMats.
This change is *not* backward compatible.

5. The function Vertices is now an operation, so as not to
conflict with the xgap package. 

6. The default value for GRAPE_NRANGRENS has been increased to 18.

7. Output streams are now used in AutGroupGraph and
SetAutGroupCanonicalLabelling.

Main changes from GRAPE 4.0 to GRAPE 4.1
----------------------------------------

1. Extended functionality of CompleteSubgraphsOfGivenSize so that a 
user can request only *maximal* complete subgraphs of a given size to
be returned.
 
2. Extended functionality of CompleteSubgraphs and
CompleteSubgraphsOfGivenSize so that the required complete subgraphs
can be classified up to equivalence under the permutation group associated
with the input graph.

3. Improvements to CompleteSubgraphs and CompleteSubgraphsOfGivenSize
which sometimes result in significant speed-ups.

4. The default UNIX file permissions for GRAPE files now include write
permission for the owner. This is to make default file permissions more 
in line with those of GAP.

5. The naming convention for the vertices of the graphs output (in a
list) by PartialLinearSpaces has changed to be more consistent with
vertex-naming conventions in GRAPE.  The point-vertices of such a graph
delta are 1,...,ptgraph.order, with the name of point-vertex i
being the name of vertex i of ptgraph. A line-vertex of delta
is named by a list (not necessarily ordered) of the point-vertex names
for the points on that line.  
Warning: This change is *not* backward compatible.

6. For non-simple input graphs, different nauty parameters than
previously are set by AutGroupGraph and SetAutGroupCanonicalLabelling
(which is called by IsIsomorphicGraph). This is in order to avoid a
performance problem with certain sparse directed graphs.
Warning: canonical labellings may be different than before.

7. Input graph to CollapsedIndependentOrbitsGraph must be simple.
(The function did not always produce correct output for non-simple graphs.)

8. Bug fixed so that AutGroupGraph and SetAutGroupCanonicalLabelling
always output ranges as full lists for processing as input to
nauty/dreadnaut.

9. Bug fixed in function Girth. This bug could cause wrong answers to
be returned. 

10. Improved documentation, including an example of research using GRAPE.

11. Better file management for the non-GAP part of GRAPE.

12. A p2c translation of tcfrontend4.p is now supplied and used.

Main changes from GRAPE 2.31 to GRAPE 4.0
-----------------------------------------

1. GRAPE 4.0 is compatible with GAP4, but not with GAP3.

2. The version of nauty now used is 2.0beta5, rather than 1.7, and
canonical labellings may have changed.  All graphs stored from previous
versions of GRAPE should have their canonicalLabelling component unbound
before use with this version.

3. IsIsomorphicGraph by default now unbinds any canonicalLabelling
components of the input graphs. This is always safe, but will downgrade
performance if testing pairwise isomorphism for many graphs. See the 
GRAPE manual documentation on changing the default.             

4. The no longer needed functions  MakeStabChainGivenLimit  and
NextSizeCompleteSubgraphs  were removed.  

5. The  names  component of a graph (if present) is immutable
(unless explicitly stored otherwise by the user, which is *not* recommended).
Also the  representatives  and  schreierVector  components of a graph
are immutable (and these should *never* be changed by a user).
 
6. The names of an EdgeGraph or a QuotientGraph are lists, but need
no longer be sets (strictly sorted lists).  This also applies to 
a CollapsedIndependentOrbitsGraph and a CollapsedCompleteOrbitsGraph.
The reason for this is that GAP4 does not support a total order on
all possible GAP4 objects. 

7. ConnectedComponents  returns a strictly sorted list.

8. The function  GraphIsomorphism  returns  fail  (instead of false)
if the input graphs are not isomorphic.

9. GraphImage(gamma)  has appropriate names even when gamma.names is
unbound.

10. The preferred name for  OrbitalGraphIntersectionMatrices  is 
OrbitalGraphColadjMats.

11. CompleteSubgraphs  and  CompleteSubgraphsOfGivenSize  improved.
The default for  arg[5]  is now  true  in  CompleteSubgraphsOfGivenSize.
Cliques  is now another name for  CompleteSubgraphs,  and  
CliquesOfGivenSize  is another name for  CompleteSubgraphsOfGivenSize.

12. The documentation has been expanded and improved.

Main changes from GRAPE 2.2 to GRAPE 2.31
-----------------------------------------

1. The new  CompleteSubgraphsOfGivenSize,  which allows for searching in
a vertex-weighted graph for cliques with a given vertex-weight sum.

2. The new function  PartialLinearSpaces,  which classifies partial linear
spaces with given point graph and parameters  s,t.  

3. The new function  VertexTransitiveDRGs,  which determines the 
distance-regular generalized orbital graphs for a given transitive 
permutation group.

4. New functions  CayleyGraph  and  SwitchedGraph.

5. A one-vertex graph is now considered to be bipartite, 
with bicomponents = [[],[1]] (to be consistent with considering a 
zero-vertex graph to be bipartite, with bicomponents = [[],[]]). 

6. A bug fixed in the function UnderlyingGraph. That bug had
the effect that if the returned graph had loops, then it 
might have had its isSimple component erroneously set to true.

