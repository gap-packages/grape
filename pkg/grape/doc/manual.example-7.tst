gap> J:=JohnsonGraph(5,2);
rec( adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ], group := Group([ (1,5,8,10,4)
  (2,6,9,3,7), (2,5)(3,6)(4,7) ]), isGraph := true, isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], order := 10,
  representatives := [ 1 ], schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1
     ] )
gap> VertexColouring(J);
[ 1, 3, 5, 4, 2, 3, 6, 1, 5, 2 ]
gap> VertexColouring(J,5);
[ 1, 2, 3, 4, 5, 4, 2, 1, 3, 5 ]
gap> VertexColouring(J,4);
fail
gap> J:=JohnsonGraph(5,2);
rec( adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ], group := Group([ (1,5,8,10,4)
  (2,6,9,3,7), (2,5)(3,6)(4,7) ]), isGraph := true, isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], order := 10,
  representatives := [ 1 ], schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1
     ] )
gap> MinimumVertexColouring(J);
[ 1, 2, 3, 4, 5, 4, 2, 1, 3, 5 ]
gap> ChromaticNumber(JohnsonGraph(5,2));
5
gap> ChromaticNumber(JohnsonGraph(6,2));
5
gap> ChromaticNumber(JohnsonGraph(7,2));
7
gap> gamma := JohnsonGraph(5,2);
rec( isGraph := true, order := 10,
  group := Group([ ( 1, 5, 8,10, 4)( 2, 6, 9, 3, 7), ( 2, 5)( 3, 6)( 4, 7) ]),
  schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1 ],
  adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ], representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], isSimple := true )
gap> CompleteSubgraphs(gamma);
[ [ 1, 2, 3, 4 ], [ 1, 2, 5 ] ]
gap>  CompleteSubgraphs(gamma,3,2);
[ [ 1, 2, 3 ], [ 1, 2, 5 ] ]
gap> CompleteSubgraphs(gamma,-1,0);
[ [ 1, 2, 5 ] ]
gap> gamma:=JohnsonGraph(6,2);
rec( isGraph := true, order := 15,
  group := Group([ ( 1, 6,10,13,15, 5)( 2, 7,11,14, 4, 9)( 3, 8,12),
      ( 2, 6)( 3, 7)( 4, 8)( 5, 9) ]),
  schreierVector := [ -1, 2, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1 ],
  adjacencies := [ [ 2, 3, 4, 5, 6, 7, 8, 9 ] ], representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 1, 6 ], [ 2, 3 ],
      [ 2, 4 ], [ 2, 5 ], [ 2, 6 ], [ 3, 4 ], [ 3, 5 ], [ 3, 6 ], [ 4, 5 ],
      [ 4, 6 ], [ 5, 6 ] ], isSimple := true )
gap> CompleteSubgraphsOfGivenSize(gamma,4);
[ [ 1, 2, 3, 4 ] ]
gap> CompleteSubgraphsOfGivenSize(gamma,4,1,true);
[  ]
gap> CompleteSubgraphsOfGivenSize(gamma,5,2,true);
[ [ 1, 2, 3, 4, 5 ] ]
gap> delta:=NewGroupGraph(Group(()),gamma);;
gap> CompleteSubgraphsOfGivenSize(delta,5,2,true);
[ [ 1, 2, 3, 4, 5 ], [ 1, 6, 7, 8, 9 ], [ 2, 6, 10, 11, 12 ],
  [ 3, 7, 10, 13, 14 ], [ 4, 8, 11, 13, 15 ], [ 5, 9, 12, 14, 15 ] ]
gap> CompleteSubgraphsOfGivenSize(delta,5,0);
[ [ 1, 2, 3, 4, 5 ] ]
gap> CompleteSubgraphsOfGivenSize(delta,5,1,false,true,
>       [1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]);
[ [ 1, 4 ], [ 2, 3 ], [ 3, 14 ], [ 4, 15 ], [ 5 ], [ 11 ], [ 12, 15 ],
  [ 13, 14 ] ]
gap> J:=JohnsonGraph(5,2);
rec( adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ], group := Group([ (1,5,8,10,4)
  (2,6,9,3,7), (2,5)(3,6)(4,7) ]), isGraph := true, isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], order := 10,
  representatives := [ 1 ], schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1
     ] )
gap> MaximumClique(J);
[ 1, 2, 3, 4 ]
gap> CliqueNumber(JohnsonGraph(5,2));
4
gap> CliqueNumber(JohnsonGraph(6,2));
5
gap> CliqueNumber(JohnsonGraph(7,2));
6
