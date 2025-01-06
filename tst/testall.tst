#############################################################################
##
##  testall.tst            GRAPE package                Leonard Soicher
##
##  To create a test file, place GAP prompts, input and output exactly as
##  they must appear in the GAP session. Do not remove lines containing 
##  START_TEST and STOP_TEST statements.
##
##  The first line starts the test. START_TEST reinitializes the caches and 
##  the global random number generator, in order to be independent of the 
##  reading order of several test files. Furthermore, the assertion level 
##  is set to 2 by START_TEST and set back to the previous value in the 
##  subsequent STOP_TEST call.
##
##  The argument of STOP_TEST may be an arbitrary identifier string.
## 
gap> START_TEST("GRAPE package: testall.tst");

# Note that you may use comments in the test file
# and also separate parts of the test by empty lines

# First load the package without banner (the banner must be suppressed to 
# avoid reporting discrepancies in the case when the package is already 
# loaded)
gap> LoadPackage("grape",false);
true
gap> P := Graph( SymmetricGroup(5), [[1,2]], OnSets,
>    function(x,y) return Intersection(x,y)=[]; end );;
gap> Diameter(P);
2
gap> Girth(P);
5
gap> EP := EdgeGraph(P);;
gap> GlobalParameters(EP);
[ [ 0, 0, 4 ], [ 1, 1, 2 ], [ 1, 2, 1 ], [ 4, 0, 0 ] ]
gap> IsDistanceRegular(EP);
true
gap> C:=CayleyGraph(SymmetricGroup(4),[(1,2),(2,3),(3,4)]);;
gap> Girth(C);
4
gap> Diameter(C);
6
gap> gamma := NullGraph( Group( (1,3), (1,2)(3,4) ) );;
gap> AddEdgeOrbit( gamma, [4,3] );
gap> GlobalParameters(gamma);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]
gap> gamma := CompleteGraph( Group( (1,3), (1,2)(3,4) ) );;
gap> RemoveEdgeOrbit( gamma, [1,3] );
gap> GlobalParameters(gamma);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]
gap> gamma := NullGraph( Group(()), 3 );;
gap> AssignVertexNames( gamma, ["a","b","c"] );
gap> VertexNames(gamma);
[ "a", "b", "c" ]
gap> IsGraph( 1 );
false
gap> IsGraph( JohnsonGraph( 3, 2 ) );
true
gap> OrderGraph( JohnsonGraph( 4, 2 ) );
6
gap> gamma := JohnsonGraph( 3, 2 );;
gap> IsVertex( gamma, 1 );
true
gap> IsVertex( gamma, 4 );
false
gap> VertexName( JohnsonGraph(4,2), 6 );
[ 3, 4 ]
gap> VertexNames( JohnsonGraph(4,2) );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ]
gap> Vertices( JohnsonGraph( 4, 2 ) );
[ 1 .. 6 ]
gap> VertexDegree( JohnsonGraph( 3, 2 ), 1 );
2
gap> VertexDegrees( JohnsonGraph( 4, 2 ) );
[ 4 ]
gap> IsLoopy( JohnsonGraph( 4, 2 ) );
false
gap> IsLoopy( CompleteGraph( Group( (1,2,3), (1,2) ), 3 ) );
false
gap> IsLoopy( CompleteGraph( Group( (1,2,3), (1,2) ), 3, true ) );
true
gap> IsSimpleGraph( CompleteGraph( Group( (1,2,3) ), 3 ) );
true
gap> IsSimpleGraph( CompleteGraph( Group( (1,2,3) ), 3, true ) );
false
gap> Adjacency( JohnsonGraph( 4, 2 ), 1 );
[ 2, 3, 4, 5 ]
gap> Adjacency( JohnsonGraph( 4, 2 ), 6 );
[ 2, 3, 4, 5 ]
gap> IsEdge( JohnsonGraph( 4, 2 ), [ 1, 2 ] );
true
gap> IsEdge( JohnsonGraph( 4, 2 ), [ 1, 6 ] );
false
gap> gamma := JohnsonGraph( 4, 3 );;
gap> DirectedEdges( gamma );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 1 ], [ 2, 3 ], [ 2, 4 ], [ 3, 1 ], 
  [ 3, 2 ], [ 3, 4 ], [ 4, 1 ], [ 4, 2 ], [ 4, 3 ] ]
gap> UndirectedEdges( gamma );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ]
gap> Distance( JohnsonGraph(4,2), 1, 6 );
2
gap> Distance( JohnsonGraph(4,2), 1, 5 );
1
gap> Distance( JohnsonGraph(4,2), [1], [5,6] );
1
gap> Diameter( JohnsonGraph( 5, 3 ) );
2
gap> Diameter( JohnsonGraph( 5, 4 ) );
1
gap> Girth( JohnsonGraph( 4, 2 ) );
3
gap> IsConnectedGraph( JohnsonGraph(4,2) );
true
gap> IsConnectedGraph( NullGraph(SymmetricGroup(4)) );
false
gap> gamma := JohnsonGraph(4,2);;
gap> IsBipartite(gamma);
false
gap> delta := BipartiteDouble(gamma);;
gap> IsBipartite(delta);
true
gap> IsNullGraph( CompleteGraph( Group(()), 3 ) );
false
gap> IsNullGraph( CompleteGraph( Group(()), 1 ) );
true
gap> IsCompleteGraph( NullGraph( Group(()), 3 ) );
false
gap> IsCompleteGraph( NullGraph( Group(()), 1 ) );
true
gap> IsCompleteGraph( CompleteGraph(SymmetricGroup(3)), true );
false
gap> IsRegularGraph( JohnsonGraph(4,2) );
true
gap> IsRegularGraph( EdgeOrbitsGraph(Group(()),[[1,2]],2) );
false
gap> gamma := JohnsonGraph(4,2);;
gap> LocalParameters( gamma, 1 );
[ [ 0, 0, 4 ], [ 1, 2, 1 ], [ 4, 0, 0 ] ]
gap> LocalParameters( gamma, [1,6] );
[ [ 0, 0, 4 ], [ 2, 2, 0 ] ]
gap> LocalParameters( gamma, [1,2] );
[ [ 0, 1, 3 ], [ -1, -1, 0 ] ]
gap> GlobalParameters( gamma );
[ [ 0, 0, 4 ], [ 1, 2, 1 ], [ 4, 0, 0 ] ]
gap> GlobalParameters( BipartiteDouble(gamma) );
[ [ 0, 0, 4 ], [ 1, 0, 3 ], [ -1, 0, -1 ], [ 4, 0, 0 ] ]
gap> IsDistanceRegular( gamma );
true
gap> IsDistanceRegular( BipartiteDouble(gamma) );
false
gap> G := Stabilizer( gamma.group, [1,6], OnSets );;
gap> CollapsedAdjacencyMat( G, gamma );
[ [ 0, 4 ], [ 2, 2 ] ]
gap> CollapsedAdjacencyMat( gamma );
[ [ 0, 4, 0 ], [ 1, 2, 1 ], [ 0, 4, 0 ] ]
gap> OrbitalGraphColadjMats( SymmetricGroup(7) );
[ [ [ 1, 0 ], [ 0, 1 ] ], [ [ 0, 6 ], [ 1, 5 ] ] ]
gap> G:=JohnsonGraph(5,3).group;;
gap> OrbitalDigraphColadjMats(G);
[ [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ], 
  [ [ 0, 6, 0 ], [ 1, 3, 2 ], [ 0, 4, 2 ] ], 
  [ [ 0, 0, 3 ], [ 0, 2, 1 ], [ 1, 2, 0 ] ] ]
gap> C:=CyclicGroup(IsPermGroup,5);
Group([ (1,2,3,4,5) ])
gap> OrbitalDigraphColadjMats(C);
[ [ [ 1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], 
      [ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ] ], 
  [ [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ], 
      [ 0, 0, 0, 0, 1 ], [ 1, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ], 
      [ 1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ], [ 1, 0, 0, 0, 0 ], 
      [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 1 ], [ 1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], 
      [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ] ] ]
gap> ConnectedComponent( NullGraph( Group((1,2)) ), 2 );
[ 2 ]
gap> ConnectedComponent( JohnsonGraph(4,2), 2 );
[ 1, 2, 3, 4, 5, 6 ]
gap> ConnectedComponents( NullGraph( Group((1,2,3,4)) ) );
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]
gap> ConnectedComponents( JohnsonGraph(4,2) );
[ [ 1, 2, 3, 4, 5, 6 ] ]
gap> Bicomponents( NullGraph(SymmetricGroup(4)) );
[ [ 1 .. 3 ], [ 4 ] ]
gap> Bicomponents( JohnsonGraph(4,2) );
[  ]
gap> Bicomponents( BipartiteDouble( JohnsonGraph(4,2) ) );
[ [ 1, 2, 3, 4, 5, 6 ], [ 7, 8, 9, 10, 11, 12 ] ]
gap> DistanceSet( JohnsonGraph(4,2), 1, [1,6] );
[ 2, 3, 4, 5 ]
gap> Layers( JohnsonGraph(4,2), 6 );
[ [ 6 ], [ 2, 3, 4, 5 ], [ 1 ] ]
gap> IndependentSet( JohnsonGraph(4,2), [3] );
[ 3, 4 ]
gap> gamma := JohnsonGraph(4,2);;
gap> S := [2,3,4,5];;
gap> square := InducedSubgraph( gamma, S, Stabilizer(gamma.group,S,OnSets) );;
gap> GlobalParameters(square);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]
gap> gamma:=DistanceGraph( JohnsonGraph(4,2), [2] );;
gap> ConnectedComponents(gamma);
[ [ 1, 6 ], [ 2, 5 ], [ 3, 4 ] ]
gap> IsLoopy(ComplementGraph(NullGraph(SymmetricGroup(3)),true));
true
gap> gamma:=PointGraph(BipartiteDouble( CompleteGraph(SymmetricGroup(4)) ));;
gap> IsCompleteGraph(gamma);
true
gap> gamma:=EdgeGraph( CompleteGraph(SymmetricGroup(5)) );;
gap> GlobalParameters(gamma);
[ [ 0, 0, 6 ], [ 1, 3, 2 ], [ 4, 2, 0 ] ]
gap> J:=JohnsonGraph(4,2);;
gap> S:=SwitchedGraph(J,[1,6]);;
gap> ConnectedComponents(S);
[ [ 1 ], [ 2, 3, 4, 5 ], [ 6 ] ]
gap> gamma := JohnsonGraph(4,2);;
gap> gamma:=QuotientGraph( gamma, [[1,6]] );;
gap> IsCompleteGraph(gamma);
true
gap> gamma := JohnsonGraph(4,2);;
gap> IsBipartite(gamma);
false
gap> delta := BipartiteDouble(gamma);;
gap> IsBipartite(delta);
true
gap> gamma:=GeodesicsGraph( JohnsonGraph(4,2), 1, 6 );;
gap> GlobalParameters(gamma);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]
gap> gamma := JohnsonGraph(4,2);;
gap> aut := AutGroupGraph(gamma);;
gap> Size(gamma.group);
24
gap> Size(aut);
48
gap> delta := NewGroupGraph( aut, gamma );;
gap> Size(delta.group);
48
gap> IsIsomorphicGraph( gamma, delta );
true
gap> Length(Set(VertexColouring( JohnsonGraph(4,2) )));
3
gap> gamma:=JohnsonGraph(6,2);;
gap> CompleteSubgraphsOfGivenSize(gamma,4,1,true);
[  ]
gap> Length(CompleteSubgraphsOfGivenSize(gamma,5,2,true));
1
gap> delta:=NewGroupGraph(Group(()),gamma);;
gap> CompleteSubgraphsOfGivenSize(delta,5,2,true);
[ [ 1, 2, 3, 4, 5 ], [ 1, 6, 7, 8, 9 ], [ 2, 6, 10, 11, 12 ], 
  [ 3, 7, 10, 13, 14 ], [ 4, 8, 11, 13, 15 ], [ 5, 9, 12, 14, 15 ] ]
gap> Length(CompleteSubgraphsOfGivenSize(delta,5,0));
1
gap> CompleteSubgraphsOfGivenSize(delta,5,1,false,true,
>    [1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]);
[ [ 1, 4 ], [ 2, 3 ], [ 3, 14 ], [ 4, 15 ], [ 5 ], [ 11 ], [ 12, 15 ], 
  [ 13, 14 ] ]
gap> CompleteSubgraphsOfGivenSize(delta,5,2,false,false,
>    [1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]);
[ [ 1, 4 ], [ 2, 3 ], [ 3, 14 ], [ 4, 15 ], [ 5 ], [ 11 ], [ 12, 15 ], 
  [ 13, 14 ] ]
gap> IsIsomorphicGraph(JohnsonGraph(7,3),JohnsonGraph(7,4));
true
gap> gamma:=JohnsonGraph(4,2);;
gap> Size(AutomorphismGroup( rec(graph:=gamma,
>    colourClasses:=[[1,6],[2,3,4,5]]) ));
16
gap> gamma := JohnsonGraph(5,3);;
gap> delta := JohnsonGraph(5,2);;
gap> IsIsomorphicGraph( gamma, delta );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[7],[1,2,3,4,5,6,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[10],[1..9]]) );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) );
false
gap> R:=GraphIsomorphismClassRepresentatives([gamma,delta,
>    ComplementGraph(gamma)]);;
gap> Length(R);
2
gap> R:=GraphIsomorphismClassRepresentatives(
>    [ rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=ComplementGraph(gamma), 
>         colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) ] );;
gap> Length(R);
3
gap> T:=ComplementGraph(JohnsonGraph(10,2));;
gap> P:=PartialLinearSpaces(T,4,6);;
gap> Set(List(P,x->Size(x.group)));
[ 216, 1512 ]
gap> ChromaticNumber(JohnsonGraph(5,2));
5
gap> ChromaticNumber(JohnsonGraph(6,2));
5
gap> ChromaticNumber(JohnsonGraph(7,2));
7
gap> CliqueNumber(JohnsonGraph(5,2));
4
gap> CliqueNumber(JohnsonGraph(6,2));
5
gap> CliqueNumber(JohnsonGraph(7,2));
6
gap> gamma:=EdgeOrbitsGraph(Group((1,2,3,4,5,6,7)),[3,4]);;
gap> Size(AutomorphismGroup(gamma));
7
gap> gamma:=NewGroupGraph(Group(()),gamma);;
gap> AddEdgeOrbit(gamma,[5,5]);
gap> Size(AutomorphismGroup(gamma));
1
gap> gamma:=UnderlyingGraph(EdgeOrbitsGraph(Group((1,2,3,4,5,6,7)),[3,4]));;
gap> Size(AutomorphismGroup(gamma));
14
gap> gamma:=NewGroupGraph(Group(()),gamma);;
gap> AddEdgeOrbit(gamma,[5,5]);
gap> Size(AutomorphismGroup(gamma));
2
gap> G:=JohnsonGraph(7,3).group;;
gap> L:=GeneralizedOrbitalGraphs(G);;
gap> List(L,VertexDegrees);
[ [ 12 ], [ 30 ], [ 34 ], [ 16 ], [ 18 ], [ 22 ], [ 4 ] ]
gap> List(L,Diameter);
[ 3, 2, 1, 2, 2, 2, 3 ]
gap> C:=CyclicGroup(IsPermGroup,6);
Group([ (1,2,3,4,5,6) ])
gap> GeneralizedOrbitalGraphs(C,1);
[ rec( adjacencies := [ [ 2, 6 ] ], group := Group([ (1,2,3,4,5,6) ]), 
      isGraph := true, order := 6, representatives := [ 1 ], 
      schreierVector := [ -1, 1, 1, 1, 1, 1 ] ), 
  rec( adjacencies := [ [ 3, 5 ] ], group := Group([ (1,2,3,4,5,6) ]), 
      isGraph := true, order := 6, representatives := [ 1 ], 
      schreierVector := [ -1, 1, 1, 1, 1, 1 ] ), 
  rec( adjacencies := [ [ 4 ] ], group := Group([ (1,2,3,4,5,6) ]), 
      isGraph := true, isSimple := true, order := 6, representatives := [ 1 ],
      schreierVector := [ -1, 1, 1, 1, 1, 1 ] ) ]
gap> G:=OnePrimitiveGroup(DegreeOperation,[275],Size,[898128000],IsSimple,[true]);;
gap> gamma:=EdgeOrbitsGraph(G,[1,2]);;
gap> if VertexDegrees(gamma)[1]>(gamma.order-1)/2 then
>    McL:=ComplementGraph(gamma);
> else
>    McL:=gamma;
> fi;
gap> Size(AutomorphismGroup(McL))/Size(McL.group); 
2
gap> GlobalParameters(McL); 
[ [ 0, 0, 112 ], [ 1, 30, 81 ], [ 56, 56, 0 ] ]
gap> gamma:=CompleteGraph(Group(()),0);; 
gap> MaximumClique(gamma);
[  ]
gap> CliqueNumber(gamma);
0
gap> ChromaticNumber(gamma);
0
gap> gamma:=CompleteGraph(Group(()),20);; 
gap> MaximumClique(gamma);
[ 1 .. 20 ]
gap> CliqueNumber(gamma);
20
gap> ChromaticNumber(gamma);
20
gap> gamma:=BipartiteDouble(gamma);; 
gap> MaximumClique(gamma);
[ 1, 22 ]
gap> CliqueNumber(gamma);
2
gap> ChromaticNumber(gamma);
2
gap> gamma:=NullGraph(Group(()),20);; 
gap> MaximumClique(gamma);
[ 1 ]
gap> CliqueNumber(gamma);
1
gap> ChromaticNumber(gamma);
1
gap> gamma:=DistanceSetInduced(McL,1,1);; 
gap> CliqueNumber(gamma);
4
gap> ChromaticNumber(gamma);
8
gap> gamma:=DistanceSetInduced(gamma,1,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
3
gap> gamma:=DistanceSetInduced(DistanceSetInduced(McL,1,1),2,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
7
gap> gamma:=DistanceSetInduced(McL,2,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
10
gap> CliqueNumber(ComplementGraph(gamma));
21
gap> gamma:=DistanceSetInduced(gamma,1,1);; 
gap> CliqueNumber(gamma);
2
gap> ChromaticNumber(gamma);
4
gap> gamma:=DistanceSetInduced(DistanceSetInduced(McL,2,1),2,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
6
gap> gamma:=DistanceSetInduced(gamma,2,1);; 
gap> ConnectedComponents(gamma); 
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
      39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
      57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72 ] ]
gap> OrderGraph(gamma);
72
gap> VertexDegrees(gamma); 
[ 20 ]
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
5
gap> ChromaticNumber(ComplementGraph(gamma));
24
gap> J:=JohnsonGraph(4,2);;
gap> JIm:=GraphImage(J,(1,2,3,4,5));;
gap> IsIsomorphicGraph(J,JIm);
true
gap> gamma := JohnsonGraph(5,3);;
gap> AddEdgeOrbit(gamma,[1,1]); # so gamma is non-simple
gap> delta := JohnsonGraph(5,2);;
gap> AddEdgeOrbit(delta,[1,1]); # so delta is non-simple
gap> IsIsomorphicGraph( gamma, delta );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[7],[1,2,3,4,5,6,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[10],[1..9]]) );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) );
false
gap> R:=GraphIsomorphismClassRepresentatives([gamma,delta,
>    ComplementGraph(gamma)]);;
gap> Length(R);
2
gap> R:=GraphIsomorphismClassRepresentatives(
>    [ rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=ComplementGraph(gamma), 
>         colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) ] );;
gap> Length(R);
3
gap> J:=JohnsonGraph(12,5);;
gap> OrderGraph(J);
792
gap> G:=J.group;;
gap> Size(G);
479001600
gap> S:=[67,93,100,204,677,750];;
gap> SmallestImageSet(G,S);
[ 1, 2, 22, 212, 242, 446 ]
gap> G:=PSL(2,5);;
gap> GRAPE_ExactSetCover(G,[[1,2,3]],6);
fail
gap> G:=PGL(2,5);;
gap> GRAPE_ExactSetCover(G,[[1,2,3]],6);
[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
gap> n:=280;;
gap> G:=OnePrimitiveGroup(NrMovedPoints,n,Size,604800*2);
J_2.2
gap> gamma:=First(GeneralizedOrbitalGraphs(G),x->VertexDegrees(x)=[135]);;
gap> omega:=CliqueNumber(gamma);
28
gap> blocks:=CompleteSubgraphsOfGivenSize(ComplementGraph(gamma),n/omega,2);;
gap> Collected(List(blocks,Length));
[ [ 10, 2 ] ]
gap> H:=SylowSubgroup(G,7);;
gap> partition:=GRAPE_ExactSetCover(G,blocks,n,H);;
gap> Collected(List(partition,Length));
[ [ 10, 28 ] ]
gap> Union(partition)=[1..n];
true
gap> gamma:=JohnsonGraph(7,3);;
gap> C:=VertexColouring(gamma,6);;
gap> IsVertexColouring(gamma,C);
true
gap> IsVertexColouring(gamma,C,7);
true
gap> IsVertexColouring(gamma,C,6);
true
gap> IsVertexColouring(gamma,C,5);
false
gap> GRAPE_DREADNAUT_INPUT_USE_STRING:=not GRAPE_DREADNAUT_INPUT_USE_STRING;; 
gap> #
gap> # Now repeat certain tests. 
gap> # 
gap> gamma := JohnsonGraph(4,2);;
gap> aut := AutGroupGraph(gamma);;
gap> Size(gamma.group);
24
gap> Size(aut);
48
gap> delta := NewGroupGraph( aut, gamma );;
gap> Size(delta.group);
48
gap> IsIsomorphicGraph( gamma, delta );
true
gap> IsIsomorphicGraph(JohnsonGraph(7,3),JohnsonGraph(7,4));
true
gap> gamma:=JohnsonGraph(4,2);;
gap> Size(AutomorphismGroup( rec(graph:=gamma,
>    colourClasses:=[[1,6],[2,3,4,5]]) ));
16
gap> gamma := JohnsonGraph(5,3);;
gap> delta := JohnsonGraph(5,2);;
gap> IsIsomorphicGraph( gamma, delta );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[7],[1,2,3,4,5,6,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[10],[1..9]]) );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) );
false
gap> R:=GraphIsomorphismClassRepresentatives([gamma,delta,
>    ComplementGraph(gamma)]);;
gap> Length(R);
2
gap> R:=GraphIsomorphismClassRepresentatives(
>    [ rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=ComplementGraph(gamma), 
>         colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) ] );;
gap> Length(R);
3
gap> T:=ComplementGraph(JohnsonGraph(10,2));;
gap> P:=PartialLinearSpaces(T,4,6);;
gap> Set(List(P,x->Size(x.group)));
[ 216, 1512 ]
gap> ChromaticNumber(JohnsonGraph(5,2));
5
gap> ChromaticNumber(JohnsonGraph(6,2));
5
gap> ChromaticNumber(JohnsonGraph(7,2));
7
gap> CliqueNumber(JohnsonGraph(5,2));
4
gap> CliqueNumber(JohnsonGraph(6,2));
5
gap> CliqueNumber(JohnsonGraph(7,2));
6
gap> gamma:=EdgeOrbitsGraph(Group((1,2,3,4,5,6,7)),[3,4]);;
gap> Size(AutomorphismGroup(gamma));
7
gap> gamma:=NewGroupGraph(Group(()),gamma);;
gap> AddEdgeOrbit(gamma,[5,5]);
gap> Size(AutomorphismGroup(gamma));
1
gap> gamma:=UnderlyingGraph(EdgeOrbitsGraph(Group((1,2,3,4,5,6,7)),[3,4]));;
gap> Size(AutomorphismGroup(gamma));
14
gap> gamma:=NewGroupGraph(Group(()),gamma);;
gap> AddEdgeOrbit(gamma,[5,5]);
gap> Size(AutomorphismGroup(gamma));
2
gap> G:=OnePrimitiveGroup(DegreeOperation,[275],Size,[898128000],IsSimple,[true]);;
gap> gamma:=EdgeOrbitsGraph(G,[1,2]);;
gap> if VertexDegrees(gamma)[1]>(gamma.order-1)/2 then
>    McL:=ComplementGraph(gamma);
> else
>    McL:=gamma;
> fi;
gap> Size(AutomorphismGroup(McL))/Size(McL.group); 
2
gap> GlobalParameters(McL); 
[ [ 0, 0, 112 ], [ 1, 30, 81 ], [ 56, 56, 0 ] ]
gap> gamma:=CompleteGraph(Group(()),0);; 
gap> MaximumClique(gamma);
[  ]
gap> CliqueNumber(gamma);
0
gap> ChromaticNumber(gamma);
0
gap> gamma:=CompleteGraph(Group(()),20);; 
gap> MaximumClique(gamma);
[ 1 .. 20 ]
gap> CliqueNumber(gamma);
20
gap> ChromaticNumber(gamma);
20
gap> gamma:=BipartiteDouble(gamma);; 
gap> MaximumClique(gamma);
[ 1, 22 ]
gap> CliqueNumber(gamma);
2
gap> ChromaticNumber(gamma);
2
gap> gamma:=NullGraph(Group(()),20);; 
gap> MaximumClique(gamma);
[ 1 ]
gap> CliqueNumber(gamma);
1
gap> ChromaticNumber(gamma);
1
gap> gamma:=DistanceSetInduced(McL,1,1);; 
gap> CliqueNumber(gamma);
4
gap> ChromaticNumber(gamma);
8
gap> gamma:=DistanceSetInduced(gamma,1,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
3
gap> gamma:=DistanceSetInduced(DistanceSetInduced(McL,1,1),2,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
7
gap> gamma:=DistanceSetInduced(McL,2,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
10
gap> CliqueNumber(ComplementGraph(gamma));
21
gap> gamma:=DistanceSetInduced(gamma,1,1);; 
gap> CliqueNumber(gamma);
2
gap> ChromaticNumber(gamma);
4
gap> gamma:=DistanceSetInduced(DistanceSetInduced(McL,2,1),2,1);; 
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
6
gap> gamma:=DistanceSetInduced(gamma,2,1);; 
gap> ConnectedComponents(gamma); 
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
      39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
      57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72 ] ]
gap> OrderGraph(gamma);
72
gap> VertexDegrees(gamma); 
[ 20 ]
gap> CliqueNumber(gamma);
3
gap> ChromaticNumber(gamma);
5
gap> ChromaticNumber(ComplementGraph(gamma));
24
gap> J:=JohnsonGraph(4,2);;
gap> JIm:=GraphImage(J,(1,2,3,4,5));;
gap> IsIsomorphicGraph(J,JIm);
true
gap> gamma := JohnsonGraph(5,3);;
gap> AddEdgeOrbit(gamma,[1,1]); # so gamma is non-simple
gap> delta := JohnsonGraph(5,2);;
gap> AddEdgeOrbit(delta,[1,1]); # so delta is non-simple
gap> IsIsomorphicGraph( gamma, delta );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[7],[1,2,3,4,5,6,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[10],[1..9]]) );
true
gap> IsIsomorphicGraph(
>    rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>    rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) );
false
gap> R:=GraphIsomorphismClassRepresentatives([gamma,delta,
>    ComplementGraph(gamma)]);;
gap> Length(R);
2
gap> R:=GraphIsomorphismClassRepresentatives(
>    [ rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=ComplementGraph(gamma), 
>         colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) ] );;
gap> Length(R);
3
gap> GRAPE_DREADNAUT_INPUT_USE_STRING:=not GRAPE_DREADNAUT_INPUT_USE_STRING;; 
gap> STOP_TEST( "testall.tst", 10000 );
## The first argument of STOP_TEST should be the name of the test file.
## The number is a proportionality factor that is used to output a 
## "GAPstone" speed ranking after the file has been completely processed.
## For the files provided with the distribution this scaling is roughly 
## equalized to yield the same numbers as produced by the test file 
## tst/combinat.tst. For package tests, you may leave it unchanged. 

#############################################################################
