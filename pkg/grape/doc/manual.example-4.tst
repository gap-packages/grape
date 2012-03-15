
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


gap> gamma := JohnsonGraph(4,2);;
gap> GlobalParameters( gamma );
[ [ 0, 0, 4 ], [ 1, 2, 1 ], [ 4, 0, 0 ] ]
gap> GlobalParameters( BipartiteDouble(gamma) );
[ [ 0, 0, 4 ], [ 1, 0, 3 ], [ -1, 0, -1 ], [ 4, 0, 0 ] ]


gap> gamma := JohnsonGraph(4,2);;
gap> IsDistanceRegular( gamma );
true
gap> IsDistanceRegular( BipartiteDouble(gamma) );
false


gap> gamma := JohnsonGraph(4,2);
rec( isGraph := true, order := 6,
  group := Group([ (1,4,6,3)(2,5), (2,4)(3,5) ]),
  schreierVector := [ -1, 2, 1, 1, 1, 1 ], adjacencies := [ [ 2, 3, 4, 5 ] ],
  representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ],
  isSimple := true )
gap> G := Stabilizer( gamma.group, [1,6], OnSets );;
gap> CollapsedAdjacencyMat( G, gamma );
[ [ 0, 4 ], [ 2, 2 ] ]
gap> CollapsedAdjacencyMat( gamma );
[ [ 0, 4, 0 ], [ 1, 2, 1 ], [ 0, 4, 0 ] ]


gap> OrbitalGraphColadjMats( SymmetricGroup(7) );
[ [ [ 1, 0 ], [ 0, 1 ] ], [ [ 0, 6 ], [ 1, 5 ] ] ]


gap> m22:=PrimitiveGroup(22,1);;
gap> syl:=SylowSubgroup(m22,11);;
gap> part:=Set(Orbit(syl,1));;
gap> l211:=Stabilizer(m22,part,OnSets);;
gap> rt:=RightTransversal(m22,l211);;
gap> m22big:=Action(m22,rt,OnRight);;
gap> v:=VertexTransitiveDRGs(m22big);
rec( degree := 672, rank := 6, isPrimitive := true,
  orbitalCombinations := [ [ 2, 3, 4, 5, 6 ], [ 2, 4 ], [ 3, 5, 6 ], [ 3, 6 ]
     ],
  intersectionArrays := [ [ [ 0, 0, 671 ], [ 1, 670, 0 ] ], [ [ 0, 0, 495 ],
          [ 1, 366, 128 ], [ 360, 135, 0 ] ],
      [ [ 0, 0, 176 ], [ 1, 40, 135 ], [ 48, 128, 0 ] ],
      [ [ 0, 0, 110 ], [ 1, 28, 81 ], [ 18, 80, 12 ], [ 90, 20, 0 ] ] ] )

