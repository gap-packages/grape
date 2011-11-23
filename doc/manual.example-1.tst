
gap> LoadPackage("grape");
true
gap> P := Graph( SymmetricGroup(5), [[1,2]], OnSets,
>             function(x,y) return Intersection(x,y)=[]; end );
rec( isGraph := true, order := 10,
  group := Group([ ( 1, 2, 3, 5, 7)( 4, 6, 8, 9,10), ( 2, 4)( 6, 9)( 7,10) ]),
  schreierVector := [ -1, 1, 1, 2, 1, 1, 1, 1, 2, 2 ],
  adjacencies := [ [ 3, 5, 8 ] ], representatives := [ 1 ],
  names := [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 1, 3 ], [ 4, 5 ], [ 2, 4 ],
      [ 1, 5 ], [ 3, 5 ], [ 1, 4 ], [ 2, 5 ] ] )
gap> Diameter(P);
2
gap> Girth(P);
5
gap> EP := EdgeGraph(P);
rec( isGraph := true, order := 15,
  group := Group([ ( 1, 4, 7, 2, 5)( 3, 6, 8, 9,12)(10,13,14,15,11),
      ( 4, 9)( 5,11)( 6,10)( 7, 8)(12,15)(13,14) ]),
  schreierVector := [ -1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 2, 1, 1, 1, 2 ],
  adjacencies := [ [ 2, 3, 7, 8 ] ], representatives := [ 1 ],
  isSimple := true,
  names := [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 1, 2 ], [ 4, 5 ] ],
      [ [ 1, 2 ], [ 3, 5 ] ], [ [ 2, 3 ], [ 4, 5 ] ], [ [ 2, 3 ], [ 1, 5 ] ],
      [ [ 2, 3 ], [ 1, 4 ] ], [ [ 3, 4 ], [ 1, 5 ] ], [ [ 3, 4 ], [ 2, 5 ] ],
      [ [ 1, 3 ], [ 4, 5 ] ], [ [ 1, 3 ], [ 2, 4 ] ], [ [ 1, 3 ], [ 2, 5 ] ],
      [ [ 2, 4 ], [ 1, 5 ] ], [ [ 2, 4 ], [ 3, 5 ] ], [ [ 3, 5 ], [ 1, 4 ] ],
      [ [ 1, 4 ], [ 2, 5 ] ] ] )
gap> GlobalParameters(EP);
[ [ 0, 0, 4 ], [ 1, 1, 2 ], [ 1, 2, 1 ], [ 4, 0, 0 ] ]

