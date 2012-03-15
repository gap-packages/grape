
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


gap> gamma := JohnsonGraph( 4, 3 );
rec( isGraph := true, order := 4, group := Group([ (1,4,3,2), (3,4) ]),
  schreierVector := [ -1, 1, 1, 1 ], adjacencies := [ [ 2, 3, 4 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ] ],
  isSimple := true )
gap> DirectedEdges( gamma );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 1 ], [ 2, 3 ], [ 2, 4 ], [ 3, 1 ],
  [ 3, 2 ], [ 3, 4 ], [ 4, 1 ], [ 4, 2 ], [ 4, 3 ] ]
gap> UndirectedEdges( gamma );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ]


gap> gamma := JohnsonGraph( 4, 3 );
rec( isGraph := true, order := 4, group := Group([ (1,4,3,2), (3,4) ]),
  schreierVector := [ -1, 1, 1, 1 ], adjacencies := [ [ 2, 3, 4 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ] ],
  isSimple := true )
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


gap> gamma := JohnsonGraph(4,2);
rec(
  isGraph := true,
  order := 6,
  group := Group( [ (1,4,6,3)(2,5), (2,4)(3,5) ] ),
  schreierVector := [ -1, 2, 1, 1, 1, 1 ],
  adjacencies := [ [ 2, 3, 4, 5 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ],
  isSimple := true )
gap> IsBipartite(gamma);
false
gap> delta := BipartiteDouble(gamma);
rec(
  isGraph := true,
  order := 12,
  group := Group( [ ( 1, 4, 6, 3)( 2, 5)( 7,10,12, 9)( 8,11),
      ( 2, 4)( 3, 5)( 8,10)( 9,11), ( 1, 7)( 2, 8)( 3, 9)( 4,10)( 5,11)
        ( 6,12) ] ),
  schreierVector := [ -1, 2, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3 ],
  adjacencies := [ [ 8, 9, 10, 11 ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ [ 1, 2 ], "+" ], [ [ 1, 3 ], "+" ], [ [ 1, 4 ], "+" ],
      [ [ 2, 3 ], "+" ], [ [ 2, 4 ], "+" ], [ [ 3, 4 ], "+" ],
      [ [ 1, 2 ], "-" ], [ [ 1, 3 ], "-" ], [ [ 1, 4 ], "-" ],
      [ [ 2, 3 ], "-" ], [ [ 2, 4 ], "-" ], [ [ 3, 4 ], "-" ] ] )
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

