gap> J:=JohnsonGraph(12,5);;
gap> OrderGraph(J);
792
gap> G:=J.group;;
gap> Size(G);
479001600
gap> S:=[67,93,100,204,677];;
gap> SmallestImageSet(G,S);
[ 1, 2, 22, 220, 453 ]
