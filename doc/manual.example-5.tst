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
