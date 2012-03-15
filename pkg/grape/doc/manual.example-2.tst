
gap> A := [[0,1,0],[1,0,0],[0,0,1]];
[ [ 0, 1, 0 ], [ 1, 0, 0 ], [ 0, 0, 1 ] ]
gap> G := Group( (1,2) );
Group([ (1,2) ])
gap> Graph( G, [1..3], OnPoints,
>        function(x,y) return A[x][y]=1; end,
>        true );
rec(
  isGraph := true,
  order := 3,
  group := Group( [ (1,2) ] ),
  schreierVector := [ -1, 1, -2 ],
  adjacencies := [ [ 2 ], [ 3 ] ],
  representatives := [ 1, 3 ],
  names := [ 1, 2, 3 ] )


gap> Petersen := Graph( SymmetricGroup(5), [[1,2]], OnSets,
>                    function(x,y) return Intersection(x,y)=[]; end );
rec(
  isGraph := true,
  order := 10,
  group := Group( [ ( 1, 2, 3, 5, 7)( 4, 6, 8, 9,10), ( 2, 4)( 6, 9)( 7,10)
     ] ),
  schreierVector := [ -1, 1, 1, 2, 1, 1, 1, 1, 2, 2 ],
  adjacencies := [ [ 3, 5, 8 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 1, 3 ], [ 4, 5 ], [ 2, 4 ],
      [ 1, 5 ], [ 3, 5 ], [ 1, 4 ], [ 2, 5 ] ] )


gap> EdgeOrbitsGraph( Group((1,3),(1,2)(3,4)), [[1,2],[4,5]], 5 );
rec(
  isGraph := true,
  order := 5,
  group := Group( [ (1,3), (1,2)(3,4) ] ),
  schreierVector := [ -1, 2, 1, 2, -2 ],
  adjacencies := [ [ 2, 4, 5 ], [  ] ],
  representatives := [ 1, 5 ],
  isSimple := false )


gap> NullGraph( Group( (1,2,3) ), 4 );
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,2,3) ] ),
  schreierVector := [ -1, 1, 1, -2 ],
  adjacencies := [ [  ], [  ] ],
  representatives := [ 1, 4 ],
  isSimple := true )


gap> CompleteGraph( Group( (1,2,3), (1,2) ) );
rec(
  isGraph := true,
  order := 3,
  group := Group( [ (1,2,3), (1,2) ] ),
  schreierVector := [ -1, 1, 1 ],
  adjacencies := [ [ 2, 3 ] ],
  representatives := [ 1 ],
  isSimple := true )


gap> JohnsonGraph(5,3);
rec(
  isGraph := true,
  order := 10,
  group := Group( [ ( 1, 7,10, 6, 3)( 2, 8, 4, 9, 5), ( 4, 7)( 5, 8)( 6, 9)
     ] ),
  schreierVector := [ -1, 1, 1, 2, 1, 1, 1, 2, 1, 1 ],
  adjacencies := [ [ 2, 3, 4, 5, 7, 8 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 2, 5 ], [ 1, 3, 4 ], [ 1, 3, 5 ],
      [ 1, 4, 5 ], [ 2, 3, 4 ], [ 2, 3, 5 ], [ 2, 4, 5 ], [ 3, 4, 5 ] ],
  isSimple := true )


gap> C:=CayleyGraph(SymmetricGroup(4),[(1,2),(2,3),(3,4)]);
rec(
  isGraph := true,
  order := 24,
  group :=
   Group( [ ( 1,10,17,19)( 2, 9,18,20)( 3,12,14,21)( 4,11,13,22)( 5, 7,16,23)
        ( 6, 8,15,24), ( 1, 7)( 2, 8)( 3, 9)( 4,10)( 5,11)( 6,12)(13,15)
        (14,16)(17,18)(19,21)(20,22)(23,24) ] ),
  schreierVector := [ -1, 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 1, 1, 2, 2, 1, 1, 2,
      1, 1, 2, 2, 1, 2 ],
  adjacencies := [ [ 2, 3, 7 ] ],
  representatives := [ 1 ],
  names := [ (), (3,4), (2,3), (2,3,4), (2,4,3), (2,4), (1,2), (1,2)(3,4),
      (1,2,3), (1,2,3,4), (1,2,4,3), (1,2,4), (1,3,2), (1,3,4,2), (1,3),
      (1,3,4), (1,3)(2,4), (1,3,2,4), (1,4,3,2), (1,4,2), (1,4,3), (1,4),
      (1,4,2,3), (1,4)(2,3) ],
  isSimple := true )
gap> Girth(C);
4
gap> Diameter(C);
6


gap> gamma := NullGraph( Group( (1,3), (1,2)(3,4) ) );;
gap> AddEdgeOrbit( gamma, [4,3] );
gap> gamma;
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,3), (1,2)(3,4) ] ),
  schreierVector := [ -1, 2, 1, 2 ],
  adjacencies := [ [ 2, 4 ] ],
  representatives := [ 1 ],
  isSimple := true )
gap> GlobalParameters(gamma);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]


gap> gamma := CompleteGraph( Group( (1,3), (1,2)(3,4) ) );;
gap> RemoveEdgeOrbit( gamma, [1,3] );
gap> gamma;
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,3), (1,2)(3,4) ] ),
  schreierVector := [ -1, 2, 1, 2 ],
  adjacencies := [ [ 2, 4 ] ],
  representatives := [ 1 ],
  isSimple := true )
gap> GlobalParameters(gamma);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]


gap> gamma := NullGraph( Group(()), 3 );
rec(
  isGraph := true,
  order := 3,
  group := Group( [ () ] ),
  schreierVector := [ -1, -2, -3 ],
  adjacencies := [ [  ], [  ], [  ] ],
  representatives := [ 1, 2, 3 ],
  isSimple := true )
gap> AssignVertexNames( gamma, ["a","b","c"] );
gap> gamma;
rec(
  isGraph := true,
  order := 3,
  group := Group( [ () ] ),
  schreierVector := [ -1, -2, -3 ],
  adjacencies := [ [  ], [  ], [  ] ],
  representatives := [ 1, 2, 3 ],
  isSimple := true,
  names := [ "a", "b", "c" ] )

