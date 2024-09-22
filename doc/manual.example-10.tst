gap> J:=JohnsonGraph(12,5);;
gap> OrderGraph(J);
792
gap> G:=J.group;;
gap> Size(G);
479001600
gap> S:=[67,93,100,204,677];;
gap> SmallestImageSet(G,S);
[ 1, 2, 22, 220, 453 ]
gap> n:=10;;
gap> G:=PSL(2,5);
Group([ (3,5)(4,6), (1,2,5)(3,4,6) ])
gap> GRAPE_ExactSetCover(G,[[1,2,3]],6);
fail
gap> G:=PGL(2,5);
Group([ (3,6,5,4), (1,2,5)(3,4,6) ])
gap> GRAPE_ExactSetCover(G,[[1,2,3]],6);
[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
gap> n:=280;;
gap> L:=AllPrimitiveGroups(NrMovedPoints,n,Size,604800*2);
[ J_2.2 ]
gap> G:=L[1];;
gap> L:=Filtered(GeneralizedOrbitalGraphs(G),x->VertexDegrees(x)=[135]);;
gap> Length(L);
1
gap> gamma:=L[1];;
gap> omega:=CliqueNumber(gamma);
28
gap> H:=SylowSubgroup(G,7);;
gap> blocks:=CompleteSubgraphsOfGivenSize(ComplementGraph(gamma),n/omega,2);
[ [ 1, 2, 3, 28, 108, 119, 155, 198, 216, 226 ],
  [ 1, 2, 3, 118, 119, 140, 193, 213, 218, 226 ] ]
gap> partition:=GRAPE_ExactSetCover(G,blocks,n,H);;
gap> Length(partition);
28
gap> colouring:=List([1..n],
>    x->First([1..Length(partition)],y->x in partition[y]));;
gap> IsVertexColouring(gamma,colouring,omega);
true
