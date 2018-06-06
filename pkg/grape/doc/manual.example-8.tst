gap> gamma := JohnsonGraph(4,2);
rec( adjacencies := [ [ 2, 3, 4, 5 ] ],
  group := Group([ (1,4,6,3)(2,5), (2,4)(3,5) ]), isGraph := true,
  isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ],
  order := 6, representatives := [ 1 ],
  schreierVector := [ -1, 2, 1, 1, 1, 1 ] )
gap> Size(AutGroupGraph(gamma));
48
gap> AutGroupGraph( rec(graph:=gamma,colourClasses:=[[1,2,3],[4,5,6]]) );
Group([ (2,3)(4,5), (1,2)(5,6) ])
gap> Size(AutomorphismGroup( rec(graph:=gamma,colourClasses:=[[1,6],[2,3,4,5]]) ));
16
gap> gamma := JohnsonGraph(5,3);
rec( adjacencies := [ [ 2, 3, 4, 5, 7, 8 ] ],
  group := Group([ (1,7,10,6,3)(2,8,4,9,5), (4,7)(5,8)(6,9) ]),
  isGraph := true, isSimple := true,
  names := [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 2, 5 ], [ 1, 3, 4 ], [ 1, 3, 5 ],
      [ 1, 4, 5 ], [ 2, 3, 4 ], [ 2, 3, 5 ], [ 2, 4, 5 ], [ 3, 4, 5 ] ],
  order := 10, representatives := [ 1 ],
  schreierVector := [ -1, 1, 1, 2, 1, 1, 1, 2, 1, 1 ] )
gap> delta := JohnsonGraph(5,2);
rec( adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ],
  group := Group([ (1,5,8,10,4)(2,6,9,3,7), (2,5)(3,6)(4,7) ]),
  isGraph := true, isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], order := 10,
  representatives := [ 1 ], schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1
     ] )
gap> GraphIsomorphism( gamma, delta );
(3,5,6,8,7,4)
gap> GraphIsomorphism(
>       rec(graph:=gamma, colourClasses:=[[7],[1,2,3,4,5,6,8,9,10]]),
>       rec(graph:=delta, colourClasses:=[[10],[1..9]]) );
(1,3)(2,6,5)(4,8)(7,10,9)
gap> GraphIsomorphism(
>       rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>       rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) );
fail
gap> gamma := JohnsonGraph(5,3);
rec( adjacencies := [ [ 2, 3, 4, 5, 7, 8 ] ],
  group := Group([ (1,7,10,6,3)(2,8,4,9,5), (4,7)(5,8)(6,9) ]),
  isGraph := true, isSimple := true,
  names := [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 2, 5 ], [ 1, 3, 4 ], [ 1, 3, 5 ],
      [ 1, 4, 5 ], [ 2, 3, 4 ], [ 2, 3, 5 ], [ 2, 4, 5 ], [ 3, 4, 5 ] ],
  order := 10, representatives := [ 1 ],
  schreierVector := [ -1, 1, 1, 2, 1, 1, 1, 2, 1, 1 ] )
gap> delta := JohnsonGraph(5,2);
rec( adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ],
  group := Group([ (1,5,8,10,4)(2,6,9,3,7), (2,5)(3,6)(4,7) ]),
  isGraph := true, isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], order := 10,
  representatives := [ 1 ], schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1
     ] )
gap> IsIsomorphicGraph( gamma, delta );
true
gap> IsIsomorphicGraph(
>       rec(graph:=gamma, colourClasses:=[[7],[1,2,3,4,5,6,8,9,10]]),
>       rec(graph:=delta, colourClasses:=[[10],[1..9]]) );
true
gap> IsIsomorphicGraph(
>       rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>       rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) );
false
gap> A:=JohnsonGraph(5,3);
rec( adjacencies := [ [ 2, 3, 4, 5, 7, 8 ] ],
  group := Group([ (1,7,10,6,3)(2,8,4,9,5), (4,7)(5,8)(6,9) ]),
  isGraph := true, isSimple := true,
  names := [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 2, 5 ], [ 1, 3, 4 ], [ 1, 3, 5 ],
      [ 1, 4, 5 ], [ 2, 3, 4 ], [ 2, 3, 5 ], [ 2, 4, 5 ], [ 3, 4, 5 ] ],
  order := 10, representatives := [ 1 ],
  schreierVector := [ -1, 1, 1, 2, 1, 1, 1, 2, 1, 1 ] )
gap> B:=JohnsonGraph(5,2);
rec( adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ],
  group := Group([ (1,5,8,10,4)(2,6,9,3,7), (2,5)(3,6)(4,7) ]),
  isGraph := true, isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ], order := 10,
  representatives := [ 1 ], schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1
     ] )
gap> R:=GraphIsomorphismClassRepresentatives([A,B,ComplementGraph(A)]);;
gap> Length(R);
2
gap> List(R,VertexDegrees);
[ [ 6 ], [ 3 ] ]
gap> R:=GraphIsomorphismClassRepresentatives(
>    [ rec(graph:=gamma, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=delta, colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]),
>      rec(graph:=ComplementGraph(gamma), colourClasses:=[[1],[6],[2,3,4,5,7,8,9,10]]) ] );;
gap> Length(R);
3
