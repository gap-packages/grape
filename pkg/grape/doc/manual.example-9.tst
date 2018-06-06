gap> K7:=CompleteGraph(SymmetricGroup(7));;
gap> P:=PartialLinearSpaces(K7,2,2);
[ rec( isGraph := true, order := 14,
      group := Group([ ( 1, 2)( 5, 6)( 9,11)(10,12),
          ( 1, 2, 3)( 5, 6, 7)( 9,11,13)(10,12,14),
          ( 1, 2, 3)( 4, 7, 6)( 9,12,14)(10,11,13),
          ( 1, 4, 7, 6, 2, 5, 3)( 8, 9,13,10,11,12,14) ]),
      schreierVector := [ -1, 1, 2, 4, 4, 1, 3, -2, 4, 1, 1, 3, 4, 2 ],
      adjacencies := [ [ 8, 9, 10 ], [ 1, 2, 3 ] ],
      representatives := [ 1, 8 ],
      names := [ 1, 2, 3, 4, 5, 6, 7, [ 1, 2, 3 ], [ 1, 4, 5 ], [ 1, 6, 7 ],
          [ 2, 4, 6 ], [ 2, 5, 7 ], [ 3, 4, 7 ], [ 3, 5, 6 ] ],
      isSimple := true ) ]
gap> Size(P[1].group);
168
gap> T:=ComplementGraph(JohnsonGraph(10,2));;
gap> P:=PartialLinearSpaces(T,4,6);;
gap> List(P,x->Size(x.group));
[ 216, 1512 ]
gap> LoadPackage("grape");
true
gap>
gap> OnSetsRecursive:=function(x,g)
> if not IsList(x) then
>   return x^g;
> else
>   return Set(List(x, y->OnSetsRecursive(y,g)));
> fi;
> end;;
gap>
gap> HofSingAdjacency := function(x,y)
> #
> # This boolean function returns  true  iff  x  and  y  are
> # adjacent in the Hoffman-Singleton graph, in Peter Cameron's
> # construction.
> #
> if Size(x)=3 then                  # x is a 3-set
>    if Size(y)=3 then               # y is a 3-set
>       return Intersection(x,y)=[]; # join iff disjoint
>    else                            # y is a projective plane
>       return x in y;               # join iff x is a line of y
>    fi;
> else                               # x is a projective plane
>    if Size(y)=3 then               # y is a 3-set
>       return y in x;               # join iff y is a line of x
>    else                            # y is a projective plane
>       return false;                # don't join
>    fi;
> fi;
> end;;
gap>
gap> projectiveplane:=
>    Set([[1,2,4],[2,3,5],[3,4,6],[4,5,7],[1,5,6],[2,6,7],[1,3,7]]);;
gap>
gap> HofSingGraph:=Graph(AlternatingGroup(7),
>                     [[1,2,3], projectiveplane], OnSetsRecursive,
>                     HofSingAdjacency);;
gap> GlobalParameters(HofSingGraph);
[ [ 0, 0, 7 ], [ 1, 0, 6 ], [ 1, 6, 0 ] ]
gap> autgrp := AutGroupGraph(HofSingGraph);;
gap> Size(autgrp);
252000
gap> HofSingGraph := NewGroupGraph(autgrp,HofSingGraph);;
gap> pointgraph:=DistanceGraph( EdgeGraph(HofSingGraph), 2);;
gap> GlobalParameters(pointgraph);
[ [ 0, 0, 72 ], [ 1, 20, 51 ], [ 36, 36, 0 ] ]
gap> spaces:=PartialLinearSpaces(pointgraph,4,17);;
gap> Length(spaces);
1
gap> haemers:=spaces[1];;
gap> DisplayCompositionSeries(haemers.group);
G (3 gens, size 2520)
 \ A(7)
1 (0 gens, size 1)
gap> linegraph:=PointGraph(haemers, Adjacency(haemers,1)[1]);;
gap> spaces:=PartialLinearSpaces(linegraph,17,4);;
gap> Length(spaces);
1
gap> dualhaemers:=spaces[1];;
gap> DisplayCompositionSeries(dualhaemers.group);
G (4 gens, size 2520)
 \ A(7)
1 (0 gens, size 1)
