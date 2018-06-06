gap> gamma := JohnsonGraph(4,2);;
gap> S := [2,3,4,5];;
gap> square := InducedSubgraph( gamma, S, Stabilizer(gamma.group,S,OnSets) );
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,4), (1,3)(2,4), (1,2)(3,4) ] ),
  schreierVector := [ -1, 3, 2, 1 ],
  adjacencies := [ [ 2, 3 ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ] ] )
gap> GlobalParameters(square);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]
gap> DistanceSetInduced( JohnsonGraph(4,2), [0,1], [1] );
rec(
  isGraph := true,
  order := 5,
  group := Group( [ (2,3)(4,5), (2,5)(3,4) ] ),
  schreierVector := [ -1, -2, 1, 2, 2 ],
  adjacencies := [ [ 2, 3, 4, 5 ], [ 1, 3, 4 ] ],
  representatives := [ 1, 2 ],
  isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ] ] )
gap> DistanceGraph( JohnsonGraph(4,2), [2] );
rec(
  isGraph := true,
  order := 6,
  group := Group( [ (1,4,6,3)(2,5), (2,4)(3,5) ] ),
  schreierVector := [ -1, 2, 1, 1, 1, 1 ],
  adjacencies := [ [ 6 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ],
  isSimple := true )
gap> ConnectedComponents(last);
[ [ 1, 6 ], [ 2, 5 ], [ 3, 4 ] ]
gap> ComplementGraph( NullGraph(SymmetricGroup(3)) );
rec(
  isGraph := true,
  order := 3,
  group := SymmetricGroup( [ 1 .. 3 ] ),
  schreierVector := [ -1, 1, 1 ],
  adjacencies := [ [ 2, 3 ] ],
  representatives := [ 1 ],
  isSimple := true )
gap> IsLoopy(last);
false
gap> IsLoopy(ComplementGraph(NullGraph(SymmetricGroup(3)),true));
true
gap> BipartiteDouble( CompleteGraph(SymmetricGroup(4)) );;
gap> PointGraph(last);
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,2), (1,2,3,4) ] ),
  schreierVector := [ -1, 1, 2, 2 ],
  adjacencies := [ [ 2, 3, 4 ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ 1, "+" ], [ 2, "+" ], [ 3, "+" ], [ 4, "+" ] ] )
gap> IsCompleteGraph(last);
true
gap> EdgeGraph( CompleteGraph(SymmetricGroup(5)) );
rec(
  isGraph := true,
  order := 10,
  group := Group( [ ( 1, 5, 8,10, 4)( 2, 6, 9, 3, 7), ( 2, 5)( 3, 6)( 4, 7)
     ] ),
  schreierVector := [ -1, 2, 2, 1, 1, 1, 2, 1, 1, 1 ],
  adjacencies := [ [ 2, 3, 4, 5, 6, 7 ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 3 ], [ 2, 4 ],
      [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ] ] )
gap> GlobalParameters(last);
[ [ 0, 0, 6 ], [ 1, 3, 2 ], [ 4, 2, 0 ] ]
gap> J:=JohnsonGraph(4,2);
rec(
  isGraph := true,
  order := 6,
  group := Group( [ (1,4,6,3)(2,5), (2,4)(3,5) ] ),
  schreierVector := [ -1, 2, 1, 1, 1, 1 ],
  adjacencies := [ [ 2, 3, 4, 5 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ],
  isSimple := true )
gap> S:=SwitchedGraph(J,[1,6]);
rec(
  isGraph := true,
  order := 6,
  group := Group( () ),
  schreierVector := [ -1, -2, -3, -4, -5, -6 ],
  adjacencies := [ [  ], [ 3, 4 ], [ 2, 5 ], [ 2, 5 ], [ 3, 4 ], [  ] ],
  representatives := [ 1, 2, 3, 4, 5, 6 ],
  isSimple := true,
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ] )
gap> ConnectedComponents(S);
[ [ 1 ], [ 2, 3, 4, 5 ], [ 6 ] ]
gap> gamma := EdgeOrbitsGraph( Group((1,2,3,4)), [1,2] );
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,2,3,4) ] ),
  schreierVector := [ -1, 1, 1, 1 ],
  adjacencies := [ [ 2 ] ],
  representatives := [ 1 ],
  isSimple := false )
gap> UnderlyingGraph(gamma);
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,2,3,4) ] ),
  schreierVector := [ -1, 1, 1, 1 ],
  adjacencies := [ [ 2, 4 ] ],
  representatives := [ 1 ],
  isSimple := true )
gap> gamma := JohnsonGraph(4,2);;
gap> QuotientGraph( gamma, [[1,6]] );
rec(
  isGraph := true,
  order := 3,
  group := Group( [ (1,3), (2,3) ] ),
  schreierVector := [ -1, 2, 1 ],
  adjacencies := [ [ 2, 3 ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 1, 3 ], [ 2, 4 ] ],
      [ [ 1, 4 ], [ 2, 3 ] ] ] )
gap> IsCompleteGraph(last);
true
gap> gamma := JohnsonGraph(4,2);;
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
gap> GeodesicsGraph( JohnsonGraph(4,2), 1, 6 );
rec(
  isGraph := true,
  order := 4,
  group := Group( [ (1,3)(2,4), (1,4)(2,3), (2,3) ] ),
  schreierVector := [ -1, 2, 1, 2 ],
  adjacencies := [ [ 2, 3 ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ] ] )
gap> GlobalParameters(last);
[ [ 0, 0, 2 ], [ 1, 0, 1 ], [ 2, 0, 0 ] ]
gap> G := Group( (1,2) );;
gap> gamma := NullGraph( SymmetricGroup(3) );;
gap> CollapsedIndependentOrbitsGraph( G, gamma );
rec(
  isGraph := true,
  order := 2,
  group := Group( [ () ] ),
  schreierVector := [ -1, -2 ],
  adjacencies := [ [  ], [  ] ],
  representatives := [ 1, 2 ],
  isSimple := true,
  names := [ [ 1, 2 ], [ 3 ] ] )
gap> gamma := CompleteGraph( SymmetricGroup(3) );;
gap> CollapsedIndependentOrbitsGraph( G, gamma );
rec(
  isGraph := true,
  order := 1,
  group := Group( [ () ] ),
  schreierVector := [ -1 ],
  adjacencies := [ [  ] ],
  representatives := [ 1 ],
  isSimple := true,
  names := [ [ 3 ] ] )
gap> G := Group( (1,2) );;
gap> gamma := NullGraph( SymmetricGroup(3) );;
gap> CollapsedCompleteOrbitsGraph( G, gamma );
rec(
  isGraph := true,
  order := 1,
  group := Group( [ () ] ),
  schreierVector := [ -1 ],
  adjacencies := [ [  ] ],
  representatives := [ 1 ],
  names := [ [ 3 ] ],
  isSimple := true )
gap> gamma := CompleteGraph( SymmetricGroup(3) );;
gap> CollapsedCompleteOrbitsGraph( G, gamma );
rec(
  isGraph := true,
  order := 2,
  group := Group( [ () ] ),
  schreierVector := [ -1, -2 ],
  adjacencies := [ [ 2 ], [ 1 ] ],
  representatives := [ 1, 2 ],
  names := [ [ 1, 2 ], [ 3 ] ],
  isSimple := true )
gap> gamma := JohnsonGraph(4,2);;
gap> aut := AutGroupGraph(gamma);
Group([ (3,4), (2,3)(4,5), (1,2)(5,6) ])
gap> Size(gamma.group);
24
gap> Size(aut);
48
gap> delta := NewGroupGraph( aut, gamma );;
gap> Size(delta.group);
48
gap> IsIsomorphicGraph( gamma, delta );
true
