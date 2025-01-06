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
