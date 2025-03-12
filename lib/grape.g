##############################################################################
##
##  grape.g (Version 4.9.2)    GRAPE Library     Leonard Soicher
##
##  Copyright (C) 1992-2024 Leonard Soicher, School of Mathematical Sciences, 
##                      Queen Mary University of London, London E1 4NS, U.K.
##
# This version includes code by Jerry James (debugged by LS) 
# which allows a user to use bliss instead of nauty for computing 
# automorphism groups and canonical labellings of graphs.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see https://www.gnu.org/licenses/gpl.html
#

GRAPE_RANDOM := false; # Determines if certain random methods are to be used
                       # in  GRAPE  functions.
                       # The default is that these random methods are not
                       # used (GRAPE_RANDOM=false).
                       # If these random methods are used (GRAPE_RANDOM=true),
                       # this does not affect the correctness of the results,
                       # as documented, returned by GRAPE functions, but may
                       # influence the time taken and the actual (correct)
                       # values returned.  Due to improvements
                       # in GRAPE and in permutation group methods in GAP4,
                       # the use of random methods is rarely necessary,
                       # and should only be employed by GRAPE experts.

GRAPE_NRANGENS := 18;  # The number of random generators taken for a subgroup
		       # when  GRAPE_RANDOM=true.

GRAPE_NAUTY := true;   # Use nauty when true, else use bliss.

GRAPE_DREADNAUT_EXE := 
   ExternalFilename(DirectoriesPackagePrograms("grape"),"dreadnaut"); 
   # filename of dreadnaut or dreadnautB executable

GRAPE_BLISS_EXE := ExternalFilename(DirectoriesSystemPrograms(),"bliss"); 
   # filename of bliss executable

GRAPE_DREADNAUT_INPUT_USE_STRING := false;
   # If true then use a string for the stream used for input
   # to dreadnaut/nauty, if false use a file for this. 
   # Using a string is faster than using a file, but may use
   # too much storage.

# The following variant of GAP's Exec is more flexible, and does not require a
# shell. That makes it more reliable on Windows resp. with Cygwin. Moreover,
# it allows to redirect input and output.
BindGlobal("GRAPE_Exec", function(cmd, args, instream, outstream)
  local dir, status;

  if not IsString(cmd) then
    Error("<cmd> must be a file path");
  fi;

  if not IsInputStream(instream) then
    Error("<instream> must be an input stream");
  fi;

  if not IsOutputStream(outstream) then
    Error("<outstream> must be an output stream");
  fi;

  # execute in the current directory
  dir := DirectoryCurrent();

  # execute the command
  status := Process(dir, cmd, instream, outstream, args);

  return status;
end);

BindGlobal("GRAPE_OrbitNumbers",function(G,n)
#
# Returns the orbits of  G  on  [1..n]  in the form of a record 
# containing the orbit representatives and a length  n  list 
# orbitNumbers,  such that  orbitNumbers[j]=i  means that point 
# j  is in the orbit of the i-th representative.
#
local i,j,orbnum,reps,im,norb,g,orb;
if not IsPermGroup(G) or not IsInt(n) then 
   Error("usage: GRAPE_OrbitNumbers( <PermGroup>, <Int> )");
fi;
orbnum:=[];
for i in [1..n] do
   orbnum[i]:=0;
od;
reps:=[];
norb:=0;
for i in [1..n] do
   if orbnum[i]=0 then      # new orbit
      Add(reps,i);
      norb:=norb+1;
      orbnum[i]:=norb;
      orb:=[i];
      for j in orb do 
	 for g in GeneratorsOfGroup(G) do
	    im:=j^g;
	    if orbnum[im]=0 then 
	       orbnum[im]:=norb;
	       Add(orb,im); 
	    fi; 
	 od; 
      od; 
   fi;
od;
return rec(representatives:=reps,orbitNumbers:=orbnum);
end);

BindGlobal("GRAPE_NumbersToSets",function(vec)
#
# Returns a list of sets as described by the numbers in vec, i.e.
# i is in the j-th set iff vec[i]=j>0.
#
local list,i,j;
if not IsList(vec) then 
   Error("usage: GRAPE_NumbersToSets( <List> )");
fi;
if Length(vec)=0 then
   return [];
fi;
list:=[];
for i in [1..Maximum(vec)] do
   list[i]:=[];
od;
for i in [1..Length(vec)] do
   j:=vec[i];
   if j>0 then 
      Add(list[j],i);
   fi;
od;
for i in [1..Length(list)] do
   IsSSortedList(list[i]);
od;
return list;
end);

BindGlobal("GRAPE_IntransitiveGroupGenerators",function(arg)
local conjperm,i,newgens,gens1,gens2,max1,max2;
gens1:=arg[1];
gens2:=arg[2];
if IsBound(arg[3]) then
   max1:=arg[3];
else
   max1:=LargestMovedPoint(gens1);
fi;
if IsBound(arg[4]) then
   max2:=arg[4];
else
   max2:=LargestMovedPoint(gens2);
fi;
if not (IsList(gens1) and IsList(gens2) and IsInt(max1) and IsInt(max2)) then 
   Error(
   "usage: GRAPE_IntransitiveGroupGenerators( <List>, <List> [,<Int> [,<Int> ]] )");
fi;
if Length(gens1)<>Length(gens2) then
   Error("Length(<gens1>) <> Length(<gens2>)");
fi;
conjperm:=PermList(Concatenation(List([1..max2],x->x+max1),[1..max1]));
newgens:=[];
for i in [1..Length(gens1)] do
   newgens[i]:=gens1[i]*(gens2[i]^conjperm);
od;
return newgens;
end);

BindGlobal("ProbablyStabilizer",function(G,pt)
#
# Returns a subgroup of  Stabilizer(G,pt),  which is very often 
# the full stabilizer. In fact, if GRAPE_RANDOM=false, then it
# is guaranteed to be the full stabilizer.
#
local sch,orb,x,y,im,k,gens,g,stabgens,i;
if not IsPermGroup(G) or not IsInt(pt) then
   Error("usage: ProbablyStabilizer( <PermGroup>, <Int> )");
fi;
if not GRAPE_RANDOM or HasSize(G) or HasStabChainMutable(G) or IsAbelian(G) then
   return Stabilizer(G,pt);
fi;
#
# At this point we know that  G  is non-abelian.  In particular,
# G  has at least two generators.
#
# First, we make a Schreier vector of permutations for the orbit  pt^G.
#
gens:=GeneratorsOfGroup(G);
sch:=[];
orb:=[pt];
sch[pt]:=();
for x in orb do
   for g in gens do
      im:=x^g;
      if not IsBound(sch[im]) then
	 sch[im]:=g;
	 Add(orb,im);
      fi;
   od;
od; 
# Now make  gens  into a new randomish generating sequence for  G.
gens:=ShallowCopy(GeneratorsOfGroup(G));
k:=Length(gens);
for i in [k+1..GRAPE_NRANGENS] do
   gens[i]:=gens[Random([1..k])];
od;
for i in [1..Length(gens)] do
   gens[i]:=Product(gens);
od;
# Now make a list  stabgens  of random elements of the stabilizer of  pt.
x:=();
stabgens:=[];
for i in [1..GRAPE_NRANGENS] do
   x:=x*Random(gens);
   im:=pt^x;
   while im<>pt do
      x:=x/sch[im];
      im:=im/sch[im];
   od;
   if x<>() then
      Add(stabgens,x);
   fi;
od;
return Group(stabgens,());
end);

BindGlobal("ProbablyStabilizerOrbitNumbers",function(G,pt,n)
#
# Returns the "orbit numbers" record for a subgroup of  Stabilizer(G,pt), 
# in its action on  [1..n].  
# This subgroup is very often the full stabilizer, and in fact, 
# if  GRAPE_RANDOM=false,  then it is guaranteed to be the full stabilizer. 
#
if not IsPermGroup(G) or not IsInt(pt) or not IsInt(n) then
   Error(
   "usage: ProbablyStabilizerOrbitNumbers( <PermGroup>, <Int>, <Int>  )");
fi;
return GRAPE_OrbitNumbers(ProbablyStabilizer(G,pt),n);
end);

BindGlobal("GRAPE_RepWord",function(gens,sch,r)
#
# Given a sequence  gens  of group generators, and a  (word type)
# schreier vector  sch  made using  gens,  this function returns a 
# record containing the orbit representative for  r  (wrt  sch),  and
# a word in  gens  taking this representative to  r. 
# (We assume  sch  includes the orbit of  r.)
#
local word,w;
word:=[]; 
w:=sch[r];
while w > 0 do
   Add(word,w); 
   r:=r/gens[w]; 
   w:=sch[r];
od;
return rec(word:=Reversed(word),representative:=r);
end);
   
BindGlobal("NullGraph",function(arg)
#
# Returns a null graph with  n  vertices and group  G=arg[1].
# If  arg[2]  is bound then  n=arg[2],  otherwise  n  is the maximum 
# largest moved point of the generators of  G.
# The  names,  autGroup,  maximumClique,  minimumVertexColouring,
# and  canonicalLabelling  components of the 
# returned null graph are left unbound; however, the  isSimple  
# component is set (to true).
#
local G,n,gamma,nadj,sch,orb,i,j,k,im,gens;
G:=arg[1];
if not IsPermGroup(G) or (IsBound(arg[2]) and not IsInt(arg[2])) then
   Error("usage: NullGraph( <PermGroup>, [, <Int> ] )");
fi;
n:=LargestMovedPoint(GeneratorsOfGroup(G)); 
if IsBound(arg[2]) then
   if arg[2] < n  then
      Error("<arg[2]> too small");
   fi;
   n:=arg[2];
fi;
gamma:=rec(isGraph:=true,order:=n,group:=G,schreierVector:=[],
	   adjacencies:=[],representatives:=[],isSimple:=true);
#
# Calculate  gamma.representatives,  gamma.schreierVector,  and
# gamma.adjacencies.
#
sch:=gamma.schreierVector; 
gens:=GeneratorsOfGroup(gamma.group); 
nadj:=0;
for i in [1..n] do 
   sch[i]:=0; 
od;
for i in [1..n] do
   if sch[i]=0 then      # new orbit
      Add(gamma.representatives,i);
      nadj:=nadj+1;
      sch[i]:=-nadj;     # tells where to find the adjacency set.
      gamma.adjacencies[nadj]:=[];
      orb:=[i];
      for j in orb do 
         for k in [1..Length(gens)] do
            im:=j^gens[k];
            if sch[im]=0 then 
               sch[im]:=k; 
               Add(orb,im); 
	    fi; 
	 od; 
      od; 
   fi;
od;
gamma.representatives:=Immutable(gamma.representatives);
gamma.schreierVector:=Immutable(gamma.schreierVector);
return gamma;
end);

BindGlobal("CompleteGraph",function(arg)
#
# Returns a complete graph with  n  vertices and group  G=arg[1].
# If  arg[2]  is bound then  n=arg[2],  otherwise  n  is the maximum 
# largest moved point of the generators of the permutation group  G.
# If the boolean argument  arg[3]  is bound and has 
# value true then the complete graph will have all possible loops, 
# otherwise it will have no loops (the default).
#
# The  names,  autGroup,  maximumClique,  minimumVertexColouring,
# and  canonicalLabelling  components of the 
# returned complete graph are left unbound; however, the  isSimple  
# component is set (appropriately).
#
local G,n,gamma,i,mustloops;
G:=arg[1];
if not IsPermGroup(G) or (IsBound(arg[2]) and not IsInt(arg[2]))
		      or (IsBound(arg[3]) and not IsBool(arg[3])) then
   Error("usage: CompleteGraph( <PermGroup>, [, <Int> [, <Bool> ]] )");
fi;
n:=LargestMovedPoint(GeneratorsOfGroup(G)); 
if IsBound(arg[2]) then
   if arg[2] < n  then
      Error("<arg[2]> too small");
   fi;
   n:=arg[2];
fi;
if IsBound(arg[3]) then
   mustloops:=arg[3];
else 
   mustloops:=false;
fi;
gamma:=NullGraph(G,n);
if gamma.order=0 then
   return gamma;
fi;
if mustloops then 
   gamma.isSimple:=false;
fi;
for i in [1..Length(gamma.adjacencies)] do
   gamma.adjacencies[i]:=[1..n];
   if not mustloops then
      RemoveSet(gamma.adjacencies[i],gamma.representatives[i]);
   fi;
od;
return gamma;
end);

BindGlobal("GRAPE_Graph",function(arg)
#
# First suppose that  arg[5]  is unbound or has value  false.
# Then  L=arg[2]  is a list of elements of a set  S  on which 
# G=arg[1]  acts with action  act=arg[3].  Also  rel=arg[4]  is a boolean
# function defining a  G-invariant relation on  S  (so that 
# for  g in G,  rel(x,y)  iff  rel(act(x,g),act(y,g)) ). 
# Then function  GRAPE_Graph  returns the graph  gamma  with vertex-names
# Immutable(Concatenation(Orbits(G,L,act))),  and  x  is joined to  y
# in  gamma  iff  rel(VertexName(gamma,x),VertexName(gamma,y)).
#
# If  arg[5]  has value  true  then it is assumed that  L=arg[2] 
# is invariant under  G=arg[1]  with action  act=arg[3]. Then
# the function  GRAPE_Graph  behaves as above, except that  gamma.names
# becomes an immutable copy of  L.
#
local G,L,act,rel,invt,gamma,vertexnames,i,reps,H,orb,x,y,adj;
G:=arg[1];
L:=arg[2];
act:=arg[3];
rel:=arg[4];
if IsBound(arg[5]) then
   invt:=arg[5];
else
   invt:=false;
fi;
if not (IsGroup(G) and IsList(L) and IsFunction(act) and IsFunction(rel) 
	and IsBool(invt)) then
   Error("usage: GRAPE_Graph( <Group>, <List>, <Function>, <Function> [, <Bool> ] )");
fi;
if invt then
   vertexnames:=Immutable(L);
else
   vertexnames:=Immutable(Concatenation(Orbits(G,L,act)));
fi;
gamma:=NullGraph(Action(G,vertexnames,act),Length(vertexnames));
Unbind(gamma.isSimple);
gamma.names:=vertexnames;
if not GRAPE_RANDOM then
   if (HasSize(G) and Size(G)<>infinity) or 
      (IsPermGroup(G) and HasStabChainMutable(G)) or
      (HasIsNaturalSymmetricGroup(G) and IsNaturalSymmetricGroup(G)) then
      StabChainOp(gamma.group,rec(limit:=Size(G)));
   fi;
fi;
reps:=gamma.representatives;
for i in [1..Length(reps)] do
   H:=ProbablyStabilizer(gamma.group,reps[i]);
   x:=vertexnames[reps[i]];
   if IsTrivial(H) then  
      gamma.adjacencies[i]:=Filtered([1..gamma.order],j->rel(x,vertexnames[j]));
   else
      adj:=[];
      for orb in OrbitsDomain(H,[1..gamma.order]) do
	 y:=vertexnames[orb[1]];
	 if rel(x,y) then
	    Append(adj,orb);
	 fi;
      od;
      Sort(adj);
      gamma.adjacencies[i]:=adj;
   fi;
   IsSSortedList(gamma.adjacencies[i]);
od;
return gamma;
end);

DeclareOperation("Graph",[IsGroup,IsList,IsFunction,IsFunction]);
InstallMethod(Graph,"for use in GRAPE with 4 parameters",
   [IsGroup,IsList,IsFunction,IsFunction],0,GRAPE_Graph);
DeclareOperation("Graph",[IsGroup,IsList,IsFunction,IsFunction,IsBool]);
InstallMethod(Graph,"for use in GRAPE with 5 parameters",
   [IsGroup,IsList,IsFunction,IsFunction,IsBool],0,GRAPE_Graph);

BindGlobal("JohnsonGraph",function(n,e)
#
# Returns the Johnson graph, whose vertices are the e-subsets
# of {1,...,n},  with x joined to y iff  Intersection(x,y)
# has size  e-1.
#
local rel,J;
if not IsInt(n) or not IsInt(e) then 
   Error("usage: JohnsonGraph( <Int>, <Int> )");
fi;
if e<0 or n<e then
   Error("must have 0 <= <e> <= <n>");
fi;
rel := function(x,y)
   return Length(Intersection(x,y))=e-1; 
end;
J:=Graph(SymmetricGroup(n),Combinations([1..n],e),OnSets,rel,true);
J.isSimple:=true;
return J;
end);

BindGlobal("HammingGraph",function(d,q)
#
# Where d and q are positive integers, this function returns the
# Hamming graph H(d,q), defined as follows. The set of vertices
# (actually vertex-names) is the set of all d-tuples of elements
# of [1..q], with vertices v and w joined by an edge iff their
# Hamming distance is 1. The group associated with the returned
# graph is  S_q wr S_d  in its product action on the vertices.
#
local W,projection,embedding,moved,act,rel;
if not IsPosInt(d) or not IsPosInt(q) then 
   Error("usage: HammingGraph( <PosInt>, <PosInt> )"); 
fi;
if q=1 then
   # special trivial case
   return Graph(Group(()),[ListWithIdenticalEntries(d,1)],
      function(x,g) return x; end,function(x,y) return false; end,true);
fi;
W:=WreathProductImprimitiveAction(SymmetricGroup([1..q]),SymmetricGroup([1..d]));
projection:=Projection(W);
embedding:=Embedding(W,d+1);
moved:=List([1..d],i->MovedPoints(Image(Embedding(W,i))));
act := function(x,g)
# Product action of  g  on d-tuple  x.
local bb,b,a,y,i;
bb:=g^projection;
b:=bb^embedding;
a:=g*b^(-1); # so g factorises as a*b in W
y:=[];
for i in [1..d] do
   y[i^bb]:=PositionSorted(moved[i],moved[i][x[i]]^a);
od;
return y;
end;
rel := function(x,y)
# boolean function returning true iff the d-tuples  x  and  y
# are at Hamming distance 1. 
local i,count;
count:=0; 
for i in [1..d] do
   if x[i]<>y[i] then
      count:=count+1;
      if count>1 then 
         return false;
      fi;
   fi;
od; 
return count=1;
end;
# Now construct and return the Hamming graph.
return Graph(W,Tuples([1..q],d),act,rel,true);
end); 

BindGlobal("IsGraph",function(obj)
#
# Returns  true  iff  obj  is a (GRAPE) graph.
#
return IsRecord(obj) and IsBound(obj.isGraph) and obj.isGraph=true
   and IsBound(obj.group) and IsBound(obj.schreierVector); 
end);

BindGlobal("CopyGraph",function(gamma)
#
# Returns a "structural" copy  delta  of the graph  gamma,  and
# also ensures that the appropriate components of  delta  are immutable. 
# 
local delta;
if not IsGraph(gamma) then
   Error("usage: CopyGraph( <Graph> )");
fi;
delta:=ShallowCopy(gamma);
delta.adjacencies:=StructuralCopy(delta.adjacencies);
delta.representatives:=Immutable(delta.representatives);
delta.schreierVector:=Immutable(delta.schreierVector);
if IsBound(delta.names) then
   delta.names:=Immutable(delta.names);
fi;
if IsBound(delta.maximumClique) then
   delta.maximumClique:=Immutable(delta.maximumClique);
fi;
if IsBound(delta.minimumVertexColouring) then
   delta.minimumVertexColouring:=Immutable(delta.minimumVertexColouring);
fi;
Unbind(delta.canonicalLabelling); # for safety
return delta;
end);

BindGlobal("OrderGraph",function(gamma)
#
# returns the order of  gamma.
#
if not IsGraph(gamma) then
   Error("usage: OrderGraph( <Graph> )");
fi;
return gamma.order;
end);

DeclareOperation("Vertices",[IsRecord]);
# to avoid the clash with `Vertices' defined in the xgap package
InstallMethod(Vertices,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns the vertex-set of graph  gamma.
#
if not IsGraph(gamma) then
   TryNextMethod();
fi;
return [1..gamma.order];
end);

DeclareOperation("IsVertex",[IsRecord,IsObject]);
InstallMethod(IsVertex,"for GRAPE graph",[IsRecord,IsObject],0, 
function(gamma,v)
#
# Returns  true  iff  v  is vertex of  gamma.
#
if not IsGraph(gamma) then
   TryNextMethod();
fi;
return IsInt(v) and v >= 1 and v <= gamma.order;
end);

BindGlobal("AssignVertexNames",function(gamma,names)
#
# Assign vertex names for  gamma,  so that the (external) name of 
# vertex  i  becomes  names[i],  by making  gamma.names  an immutable 
# copy of  names.
#
if not IsGraph(gamma) or not IsList(names) then
   Error("usage: AssignVertexNames( <Graph>, <List> )");
fi;
if Length(names)<>gamma.order then 
   Error("Length(<names>) <> gamma.order");
fi;
gamma.names:=Immutable(names);
end);

BindGlobal("VertexName",function(gamma,v)
#
# Returns the (external) name of the vertex  v  of  gamma.
#
if not IsGraph(gamma) or not IsInt(v) then
   Error("usage: VertexName( <Graph>, <Int> )");
fi;
if IsBound(gamma.names) then 
   return Immutable(gamma.names[v]);
else 
   return v;
fi;
end);

BindGlobal("VertexNames",function(gamma)
#
# Returns the list of (external) names of the vertices of  gamma. 
#
if not IsGraph(gamma) then
   Error("usage: VertexNames( <Graph> )");
fi;
if IsBound(gamma.names) then 
   return Immutable(gamma.names);
else 
   return Immutable([1..gamma.order]);
fi;
end);

BindGlobal("VertexDegree",function(gamma,v)
#
# Returns the vertex (out)degree of vertex  v  in the graph  gamma.
#
local rw,sch;
if not IsGraph(gamma) or not IsInt(v) then
   Error("usage: VertexDegree( <Graph>, <Int> )");
fi;
if v<1 or v>gamma.order then
   Error("<v> is not a vertex of <gamma>");
fi;
sch:=gamma.schreierVector;
rw:=GRAPE_RepWord(GeneratorsOfGroup(gamma.group),sch,v);
return Length(gamma.adjacencies[-sch[rw.representative]]); 
end);

BindGlobal("VertexDegrees",function(gamma)
#
# Returns the set of vertex (out)degrees for the graph  gamma.
#
local adj,degs;
if not IsGraph(gamma) then
   Error("usage: VertexDegrees( <Graph> )");
fi;
degs:=[];
for adj in gamma.adjacencies do
   AddSet(degs,Length(adj));
od;
return degs;
end);

BindGlobal("IsVertexPairEdge",function(gamma,x,y)
#
# Assuming that  x,y  are vertices of  gamma,  returns true
# iff  [x,y]  is an edge of  gamma.
#
local w,sch,gens;
sch:=gamma.schreierVector;
gens:=GeneratorsOfGroup(gamma.group);
w:=sch[x];
while w > 0 do
   x:=x/gens[w];
   y:=y/gens[w];
   w:=sch[x];
od;
return y in gamma.adjacencies[-w];
end);

DeclareOperation("IsEdge",[IsRecord,IsObject]);
InstallMethod(IsEdge,"for GRAPE graph",[IsRecord,IsObject],0, 
function(gamma,e)
#
# Returns  true  iff  e  is an edge of  gamma.
#
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if not IsList(e) or Length(e)<>2 or not IsVertex(gamma,e[1])
		 or not IsVertex(gamma,e[2]) then
   return false;
fi;
return IsVertexPairEdge(gamma,e[1],e[2]);
end);

BindGlobal("Adjacency",function(gamma,v)
#
# Returns (a copy of) the set of vertices of  gamma  adjacent to vertex  v.
#
local w,adj,rw,gens,sch;
sch:=gamma.schreierVector;
if sch[v] < 0 then 
   return ShallowCopy(gamma.adjacencies[-sch[v]]);
fi;
gens:=GeneratorsOfGroup(gamma.group);
rw:=GRAPE_RepWord(gens,sch,v);
adj:=gamma.adjacencies[-sch[rw.representative]]; 
for w in rw.word do 
   adj:=OnTuples(adj,gens[w]); 
od;
return SSortedList(adj);
end);

BindGlobal("IsSimpleGraph",function(gamma)
#
# Returns  true  iff graph  gamma  is simple (i.e. has no loops and 
# if [x,y] is an edge then so is [y,x]).  Also sets the isSimple 
# field of  gamma  if this field was not already bound.
#
local adj,i,x,H,orb;
if not IsGraph(gamma) then 
   Error("usage: IsSimpleGraph( <Graph> )");
fi;
if IsBound(gamma.isSimple) then
   return gamma.isSimple;
fi;
for i in [1..Length(gamma.adjacencies)] do
   adj:=gamma.adjacencies[i];
   x:=gamma.representatives[i];
   if x in adj then    # a loop exists
      gamma.isSimple:=false;
      return false;
   fi;
   H:=ProbablyStabilizer(gamma.group,x);
   for orb in OrbitsDomain(H,adj) do
      if not IsVertexPairEdge(gamma,orb[1],x) then
	 gamma.isSimple:=false;
	 return false;
      fi;
   od;
od;
gamma.isSimple:=true;
return true;
end);

BindGlobal("DirectedEdges",function(gamma)
#
# Returns the set of directed (ordered) edges of  gamma.
#
local i,j,edges;
if not IsGraph(gamma) then 
   Error("usage: DirectedEdges( <Graph> )");
fi;
edges:=[];
for i in [1..gamma.order] do
   for j in Adjacency(gamma,i) do
      Add(edges,[i,j]);
   od;
od;
IsSSortedList(edges);  # edges is a set.
return edges;
end);

BindGlobal("UndirectedEdges",function(gamma)
#
# Returns the set of undirected edges of  gamma,  which must be 
# a simple graph.
#
local i,j,edges;
if not IsGraph(gamma) then 
   Error("usage: UndirectedEdges( <Graph> )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
edges:=[];
for i in [1..gamma.order-1] do
   for j in Adjacency(gamma,i) do
      if i<j then 
	 Add(edges,[i,j]);
      fi;
   od;
od;
IsSSortedList(edges);  # edges is a set.
return edges;
end);

BindGlobal("AddEdgeOrbit",function(arg) 
#
# Let  gamma=arg[1]  and  e=arg[2].
# If  arg[3]  is bound then it is assumed to be  Stabilizer(gamma.group,e[1]).
# This procedure adds edge orbit  e^gamma.group  to the edge-set of  gamma.
#
local w,word,sch,gens,gamma,e,x,y,orb,u,v;
gamma:=arg[1]; 
e:=arg[2];
if not IsGraph(gamma) or not IsList(e) 
    or (IsBound(arg[3]) and not IsPermGroup(arg[3])) then
   Error("usage: AddEdgeOrbit( <Graph>, <List>, [, <PermGroup> ] )");
fi;
if Length(e)<>2 or not IsVertex(gamma,e[1]) or not IsVertex(gamma,e[2]) then
   Error("invalid <e>");
fi;
sch:=gamma.schreierVector;
gens:=GeneratorsOfGroup(gamma.group);
x:=e[1];
y:=e[2];
w:=sch[x];
word:=[];
while w > 0 do
   Add(word,w);
   x:=x/gens[w];
   y:=y/gens[w];
   w:=sch[x];
od;
if not(y in gamma.adjacencies[-sch[x]]) then
   #  e  is not an edge of  gamma
   if not IsBound(arg[3]) then
      orb:=Orbit(Stabilizer(gamma.group,x),y);
   else
      if ForAny(GeneratorsOfGroup(arg[3]),x->e[1]^x<>e[1]) then
	 Error("<arg[3]>  not equal to  Stabilizer(<gamma.group>,<e[1]>)");
      fi;
      orb:=[];
      for u in Orbit(arg[3],e[2]) do
	 v:=u;
	 for w in word do
	    v:=v/gens[w];
	 od;
	 Add(orb,v);
      od;
   fi;
   UniteSet(gamma.adjacencies[-sch[x]],orb);
   if e[1]=e[2] then
      gamma.isSimple:=false;
   elif IsBound(gamma.isSimple) and gamma.isSimple then
      if not IsVertexPairEdge(gamma,e[2],e[1]) then 
	 gamma.isSimple:=false; 
      fi;
   else 
      Unbind(gamma.isSimple);
   fi;
   Unbind(gamma.autGroup);
   Unbind(gamma.canonicalLabelling);
   Unbind(gamma.maximumClique);
   Unbind(gamma.minimumVertexColouring);
fi;   
end);

BindGlobal("RemoveEdgeOrbit",function(arg) 
#
# Let  gamma=arg[1]  and  e=arg[2].
# If  arg[3]  is bound then it is assumed to be  Stabilizer(gamma.group,e[1]).
# This procedure removes the edge orbit  e^gamma.group  from the edge-set 
# of  gamma, if this orbit exists, and otherwise does nothing.
#
local w,word,sch,gens,gamma,e,x,y,orb,u,v;
gamma:=arg[1]; 
e:=arg[2];
if not IsGraph(gamma) or not IsList(e) 
    or (IsBound(arg[3]) and not IsPermGroup(arg[3])) then
   Error("usage: RemoveEdgeOrbit( <Graph>, <List>, [, <PermGroup> ] )");
fi;
if Length(e)<>2 or not IsVertex(gamma,e[1]) or not IsVertex(gamma,e[2]) then
   Error("invalid <e>");
fi;
sch:=gamma.schreierVector;
gens:=GeneratorsOfGroup(gamma.group);
x:=e[1];
y:=e[2];
w:=sch[x];
word:=[];
while w > 0 do
   Add(word,w);
   x:=x/gens[w];
   y:=y/gens[w];
   w:=sch[x];
od;
if y in gamma.adjacencies[-sch[x]] then
   #  e  is an edge of  gamma
   if not IsBound(arg[3]) then
      orb:=Orbit(Stabilizer(gamma.group,x),y);
   else
      if ForAny(GeneratorsOfGroup(arg[3]),x->e[1]^x<>e[1]) then
	 Error("<arg[3]>  not equal to  Stabilizer(<gamma.group>,<e[1]>)");
      fi;
      orb:=[];
      for u in Orbit(arg[3],e[2]) do
	 v:=u;
	 for w in word do
	    v:=v/gens[w];
	 od;
	 Add(orb,v);
      od;
   fi;
   SubtractSet(gamma.adjacencies[-sch[x]],orb);
   if IsBound(gamma.isSimple) and gamma.isSimple then
      if IsVertexPairEdge(gamma,e[2],e[1]) then 
	 gamma.isSimple:=false; 
      fi;
   else 
      Unbind(gamma.isSimple);
   fi;
   Unbind(gamma.autGroup);
   Unbind(gamma.canonicalLabelling);
   Unbind(gamma.maximumClique);
   Unbind(gamma.minimumVertexColouring);
fi;   
end);

BindGlobal("EdgeOrbitsGraph",function(arg)
#
# Let  G=arg[1],  E=arg[2].
# Returns the (directed) graph with vertex-set {1,...,n} and edge-set 
# the union over  e in E  of  e^G,  where  n=arg[3]  if  arg[3]  is bound,
# and  n=LargestMovedPoint(GeneratorsOfGroup(G))  otherwise.
# (E can consist of just a singleton edge.)
#
local G,E,n,gamma,e;
G:=arg[1];
E:=arg[2];
if IsBound(E[1]) and IsInt(E[1]) then 
   # assume  E  consists of a single edge.
   E:=[E];
fi;
if IsBound(arg[3]) then 
   n:=arg[3];
else
   n:=LargestMovedPoint(GeneratorsOfGroup(G));
fi;
if not IsPermGroup(G) or not IsList(E) or not IsInt(n) then
   Error("usage: EdgeOrbitsGraph( <PermGroup>, <List> [, <Int> ] )");
fi;
gamma:=NullGraph(G,n);
for e in E do 
   AddEdgeOrbit(gamma,e); 
od;
return gamma;
end);

BindGlobal("GeneralizedOrbitalGraphs",function(arg)
#
# Let  G=arg[1]. Then  G  must be a non-trivial permutation group,
# acting transitively on  [1..n],  where n:=LargestMovedPoint(G).
#
# The optional second parameter  k=arg[2]  (default: false)  must
# be true or false or a non-negative integer. 
#
# Then this function returns a list of distinct generalized orbital
# graphs for  G  (where a *generalized orbital graph* for  G  is a 
# (simple) graph with vertex set [1..n] and edge-set a union of 
# zero or more G-orbits of 2-subsets of  [1..n]).
#
# If  k=true  then *all*  the generalized orbital graphs 
# for  G  are in the list,  if  k=false  (the default)  then all
# the non-null generalized orbital graphs for  G  are in the list,
# and if  k  is a non-negative integer then the list consists of
# all the generalized orbital graphs for  G  whose edge-set is the
# union of exactly  k  G-orbits of 2-subsets of  [1..n].
#
# The group associated with each returned graph in the list is  G. 
#
local G,k,comb,combinations,n,H,result,reps,i,L,M,mm;
if not (Length(arg) in [1,2]) then
   Error("must have 1 or 2 arguments");
fi;
G:=arg[1];
if IsBound(arg[2]) then
   k:=arg[2];
else
   k:=false;
fi;
if not (IsPermGroup(G) and (IsBool(k) or IsInt(k))) then
   Error("usage: GeneralizedOrbitalGraphs( <PermGroup> [, <Bool> or <Int> ] )");
fi;
n:=LargestMovedPoint(G);
if n=0 or not IsTransitive(G,[1..n]) then
   Error("<G> must be a non-trivial transitive group on [1..LargestMovedPoint( <G> )]");
fi;
if not ((k in [false,true]) or (IsInt(k) and k>=0)) then 
   Error("<k> must be in  [false,true]  or be a non-negative integer");
fi;
H:=Stabilizer(G,1);
reps:=Set(List(OrbitsDomain(H,[2..n]),Minimum));
#
# Now make a duplicate-free list  L  of the graphs
# with vertex-set  [1..n]  and edge-set the union
# of a nondiagonal G-orbital and its paired orbital.
# At the same time, make a list  M  whose i-th element is
# a list of edges of  L[i],  such that the union of the
# G-orbits of the edges in  M[i]  is the edge-set of  L[i].
#
L:=[];
M:=[];
for i in [1..Length(reps)] do
   if ForAll(L,x->not IsEdge(x,[1,reps[i]])) then
      mm:=[[1,reps[i]],[reps[i],1]];
      Add(L,EdgeOrbitsGraph(G,mm));
      Add(M,mm);
   fi;
od;
result:=[];
if k in [false,true] then
   combinations:=Combinations(M);
else  
   # k is a non-negative integer
   combinations:=Combinations(M,k);
fi;
for comb in combinations do
   if k<>false or comb<>[] then
      Add(result,EdgeOrbitsGraph(G,Concatenation(comb)));
   fi;
od;
return result;
end);

BindGlobal("CollapsedAdjacencyMat",function(arg)
#
# Returns the collapsed adjacency matrix  A  for  gamma=arg[2]  wrt  
# group  G=arg[1],  assuming  G <= Aut(gamma). 
# The rows and columns of  A  are indexed by the orbits 
# orbs[1],...,orbs[n], say, of  G  on the vertices of  
# gamma, and the entry  A[i][j]  of  A  is defined as follows:
#    Let  reps[i]  be a representative of the  i-th  G-orbit  orbs[i].
#    Then  A[i][j] equals the number of neighbours (in  gamma)
#    of  reps[i]  in  orbs[j]. 
# Note that this definition does not depend on the choice of 
# representative  reps[i].
#
# *** New for Grape 2.3: In the special case where this function 
# is given just one argument, then we must have  gamma=arg[1], 
# we must have  gamma.group  transitive on the vertices of  gamma,
# and then the returned collapsed adjacency matrix for  gamma  is 
# w.r.t. the stabilizer in  gamma.group  of  1.  Additionally 
# [1]=orbs[1].  This feature is to 
# conform with the definition of collapsed adjacency matrix in 
# Praeger and Soicher, "Low Rank Representations and Graphs for 
# Sporadic Groups", CUP, Cambridge, 1997.  (In GRAPE we allow a collapsed
# adjacency matrix to be more general, as we can collapse w.r.t. to
# an arbitrary subgroup of  Aut(gamma),  and  gamma  need not 
# even be vertex-transitive.)  
#
local G,gamma,orbs,i,j,n,A,orbnum,reps;
if Length(arg)=1 then
   gamma:=arg[1];
   if not IsGraph(gamma) then
      Error("usage: CollapsedAdjacencyMat( [<PermGroup>,] <Graph>)");
   fi;
   if gamma.order=0 then 
      return []; 
   fi; 
   if not IsTransitive(gamma.group,[1..gamma.order]) then
      Error(
       "<gamma.group> not transitive on vertices of single argument <gamma>"); 
   fi;
   G := Stabilizer(gamma.group,1);
else   
   G := arg[1];
   gamma := arg[2];
   if not IsPermGroup(G) or not IsGraph(gamma) then
      Error("usage: CollapsedAdjacencyMat( [<PermGroup>,] <Graph> )");
   fi;
   if gamma.order=0 then
      return [];
   fi;
fi;
orbs:=GRAPE_OrbitNumbers(G,gamma.order);
orbnum:=orbs.orbitNumbers;
reps:=orbs.representatives;
n:=Length(reps);
A:=NullMat(n,n);
for i in [1..n] do 
   for j in Adjacency(gamma,reps[i]) do
      A[i][orbnum[j]]:=A[i][orbnum[j]]+1;
   od;
od;
return A;
end);

BindGlobal("OrbitalDigraphColadjMats",function(arg)
#
# This function returns a sequence of collapsed adjacency 
# matrices for the the orbital digraphs of the (assumed) transitive  
# G=arg[1].  The matrices are collapsed w.r.t.  Stabilizer(G,1),  so
# that these are collapsed adjacency matrices in the sense of 
# Praeger and Soicher, "Low Rank Representations and Graphs for 
# Sporadic Groups", CUP, Cambridge, 1997. 
# The matrices are collapsed w.r.t. a fixed ordering of the G-suborbits,
# with the trivial suborbit  [1]  coming first.
#
# If  arg[2]  is bound, then it is assumed to be  Stabilizer(G,1).
#
local G,H,orbs,deg,i,j,k,n,coladjmats,A,orbnum,reps,gamma;
G:=arg[1];
if not IsPermGroup(G) or (IsBound(arg[2]) and not IsPermGroup(arg[2])) then
   Error("usage: OrbitalDigraphColadjMats( <PermGroup> [, <PermGroup> ] )");
fi;
if IsBound(arg[2]) then
   H:=arg[2];
   if ForAny(GeneratorsOfGroup(H),x->1^x<>1) then
      Error("<H> does not fix the point 1");
   fi;
else
   H:=Stabilizer(G,1);
fi;
deg:=Maximum(LargestMovedPoint(GeneratorsOfGroup(G)),1);
if not IsTransitive(G,[1..deg]) then
   Error("<G> not transitive");
fi;
gamma:=NullGraph(G,deg);
orbs:=GRAPE_OrbitNumbers(H,gamma.order);
orbnum:=orbs.orbitNumbers;
reps:=orbs.representatives;
if reps[1]<>1 then # this cannot happen!
   Error("internal error");
fi;
n:=Length(reps);
coladjmats:=[];
for i in [1..n] do
   AddEdgeOrbit(gamma,[1,reps[i]],H);
   A:=NullMat(n,n);
   for j in [1..n] do 
      for k in Adjacency(gamma,reps[j]) do
	 A[j][orbnum[k]]:=A[j][orbnum[k]]+1;
      od;
   od;
   coladjmats[i]:=A;
   if i < n then
      RemoveEdgeOrbit(gamma,[1,reps[i]],H);
   fi;
od;
return coladjmats;
end);

BindGlobal("OrbitalGraphColadjMats",OrbitalDigraphColadjMats);
# for backward compatibility

BindGlobal("LocalInfo",function(arg)
#
# Calculates  "local info"  for  gamma=arg[1]  from point of view of vertex  
# set (or list or singleton vertex)  V=arg[2].
#
# Returns record containing the  "layer numbers"  for gamma w.r.t.
# V,  as well as the the local diameter and local girth of gamma w.r.t.  V.
# ( layerNumbers[i]=j>0 if vertex  i  is in layer[j]  (i.e. at distance
# j-1  from  V),  layerNumbers[i]=0  if vertex  i
# is not joined by a (directed) path from some element of  V.)
# Also, if a local parameter  ci[V], ai[V], or bi[V]  exists then
# this information is recorded in  localParameters[i+1][1], 
# localParameters[i+1][2], or localParameters[i+1][3], 
# respectively (otherwise a -1 is recorded). 
#
# *** If  gamma  is not simple then local girth and the local parameters
# may not be what you think. The local girth has no real meaning if 
# |V| > 1.
#
# *** But note: If arg[3] is bound and arg[3] > 0
# then the procedure stops after  layers[arg[3]]  has been determined.
#
# If  arg[4]  is bound (a set or list or singleton vertex), then the
# procedure stops when the first layer containing a vertex in  arg[4]  is 
# complete.  Moreover, if  arg[4]  is bound then the local info record 
# contains a  distance  field, whose value (if  arg[3]=0)  is  
# min{ d(v,w) | v in V, w in arg[4] }.
#
# If  arg[5]  is bound then it is assumed to be a subgroup of Aut(gamma)
# stabilising  V  setwise.
#
local gamma,V,layers,localDiameter,localGirth,localParameters,i,j,x,y,next,
      nprev,nhere,nnext,sum,orbs,orbnum,laynum,lnum,
      stoplayer,stopvertices,distance,loc,reps,layerNumbers;
gamma:=arg[1];
V:=arg[2];
if IsInt(V) then 
   V:=[V];
fi;
if not IsGraph(gamma) or not IsList(V) then 
   Error("usage: LocalInfo( <Graph>, <Int> or <List>, ... )");
fi;
if not IsSSortedList(V) then
   V:=SSortedList(V);
fi;
if V=[] or not IsSubset([1..gamma.order],V) then 
   Error("<V> must be non-empty set of vertices of <gamma>");
fi;
if IsBound(arg[3]) then 
   stoplayer:=arg[3]; 
   if not IsInt(stoplayer) or stoplayer < 0 then
      Error("<stoplayer> must be integer >= 0");
   fi;
else 
   stoplayer:=0; 
fi;
if IsBound(arg[4]) then 
   stopvertices:=arg[4]; 
   if IsInt(stopvertices) then
      stopvertices:=[stopvertices];
   fi;
   if not IsSSortedList(stopvertices) then
      stopvertices:=SSortedList(stopvertices);
   fi;
   if not IsSubset([1..gamma.order],stopvertices) 
      then
	 Error("<stopvertices> must be a set of vertices of <gamma>");
   fi;
else 
   stopvertices:=[]; 
fi;
if IsBound(arg[5]) then 
   if not IsPermGroup(arg[5]) then 
      Error("<arg[5]> must be a permutation group (<= Stab(<V>)");
   fi;
   orbs:=GRAPE_OrbitNumbers(arg[5],gamma.order);
else
   if Length(V)=1 then
      if IsBound(gamma.autGroup) then
	 orbs:=ProbablyStabilizerOrbitNumbers(gamma.autGroup,V[1],gamma.order);
      else
	 orbs:=ProbablyStabilizerOrbitNumbers(gamma.group,V[1],gamma.order);
      fi;
   else
      orbs:=rec(representatives:=[1..gamma.order],
		orbitNumbers:=[1..gamma.order]); 
   fi;
fi;
orbnum:=orbs.orbitNumbers;
reps:=orbs.representatives;
laynum:=[];
for i in [1..Length(reps)] do 
   laynum[i]:=0;
od;
localGirth:=-1; 
distance:=-1;
localParameters:=[]; 
next:=[];
for i in V do
   AddSet(next,orbnum[i]);
od;
sum:=Length(next);
for i in next do 
   laynum[i]:=1;
od;
layers:=[]; 
layers[1]:=next; 
i:=1; 
if Length(Intersection(V,stopvertices)) > 0 then
   stoplayer:=1; 
   distance:=0;
fi;
while stoplayer<>i and Length(next)>0 do
   next:=[];
   for x in layers[i] do 
      nprev:=0; 
      nhere:=0; 
      nnext:=0;
      for y in Adjacency(gamma,reps[x]) do
	 lnum:=laynum[orbnum[y]];
	 if i>1 and lnum=i-1 then 
	    nprev:=nprev+1;
	 elif lnum=i then 
	    nhere:=nhere+1;
	 elif lnum=i+1 then
	    nnext:=nnext+1;
	 elif lnum=0 then
	    AddSet(next,orbnum[y]); 
	    nnext:=nnext+1;
	    laynum[orbnum[y]]:=i+1;
	 fi;
      od;
      if (localGirth=-1 or localGirth=2*i-1) and nprev>1 then 
	 localGirth:=2*(i-1); 
      fi;
      if localGirth=-1 and nhere>0 then 
	 localGirth:=2*i-1; 
      fi;
      if not IsBound(localParameters[i]) then 
	 localParameters[i]:=[nprev,nhere,nnext];
      else
	 if nprev<>localParameters[i][1] then 
	    localParameters[i][1]:=-1; 
	 fi;
	 if nhere<>localParameters[i][2] then 
	    localParameters[i][2]:=-1; 
	 fi;
	 if nnext<>localParameters[i][3] then 
	    localParameters[i][3]:=-1; 
	 fi;
      fi;
   od;
   if Length(next)>0 then 
      i:=i+1; 
      layers[i]:=next; 
      for j in stopvertices do 
	 if laynum[orbnum[j]]=i then 
	    stoplayer:=i; 
	    distance:=i-1;
            break;
	 fi;
      od;
      sum:=sum+Length(next); 
   fi;
od;
if sum=Length(reps) then 
   localDiameter:=Length(layers)-1; 
else 
   localDiameter:=-1; 
fi;
# now change  orbnum  to give the layer numbers instead of orbit numbers.
layerNumbers:=orbnum;
for i in [1..gamma.order] do
   layerNumbers[i]:=laynum[orbnum[i]];
od;
loc:=rec(layerNumbers:=layerNumbers,localDiameter:=localDiameter,
	 localGirth:=localGirth,localParameters:=localParameters);
if Length(stopvertices) > 0 then 
   loc.distance:=distance;
fi;
return loc;
end);

BindGlobal("LocalInfoMat",function(A,rows)
#
# Calculates local info on a graph using a collapsed adjacency matrix 
#  A  for that graph.
# This local info is from the point of view of the set of vertices
# represented by the set  rows  of row indices of  A.
# The elements of  layers[i]  will be the row indices representing 
# the vertices of the i-th layer.  
# No  distance  field will be calculated.
#
# *** If  A  is not the collapsed adjacency matrix for a simple graph 
# then  localGirth  and localParameters may not be what you think.
# If  rows  does not represent a single vertex then  localGirth  has 
# no real meaning. 
#
local layers,localDiameter,localGirth,localParameters,i,j,x,y,next,
      nprev,nhere,nnext,sum,laynum,lnum,n;
if IsInt(rows) then 
   rows:=[rows];
fi;
if not IsMatrix(A) or not IsList(rows) then 
   Error("usage: LocalInfoMat( <Matrix>, <Int> or <List> )");
fi;
if not IsSSortedList(rows) then
   rows:=SSortedList(rows);
fi;
n:=Length(A);
if rows=[] or not IsSubset([1..n],rows) then 
   Error("<rows> must be non-empty set of row indices");
fi;
laynum:=ListWithIdenticalEntries(n,0);
localGirth:=-1; 
localParameters:=[]; 
next:=ShallowCopy(rows); 
for i in next do 
   laynum[i]:=1;
od;
layers:=[]; 
layers[1]:=next; 
i:=1; 
sum:=Length(rows);
while Length(next)>0 do
   next:=[];
   for x in layers[i] do 
      nprev:=0; 
      nhere:=0; 
      nnext:=0;
      for y in [1..n] do
	 j:=A[x][y];
	 if j>0 then
	    lnum:=laynum[y];
	    if i>1 and lnum=i-1 then 
	       nprev:=nprev+j;
	    elif lnum=i then 
	       nhere:=nhere+j;
	    elif lnum=i+1 then
	       nnext:=nnext+j;
	    elif lnum=0 then
	       AddSet(next,y); 
	       nnext:=nnext+j;
	       laynum[y]:=i+1;
	    fi;
	 fi;
      od;
      if (localGirth=-1 or localGirth=2*i-1) and nprev>1 then 
	 localGirth:=2*(i-1); 
      fi;
      if localGirth=-1 and nhere>0 then 
	 localGirth:=2*i-1; 
      fi;
      if not IsBound(localParameters[i]) then 
	 localParameters[i]:=[nprev,nhere,nnext];
      else
	 if nprev<>localParameters[i][1] then 
	    localParameters[i][1]:=-1; 
	 fi;
	 if nhere<>localParameters[i][2] then 
	    localParameters[i][2]:=-1; 
	 fi;
	 if nnext<>localParameters[i][3] then 
	    localParameters[i][3]:=-1; 
	 fi;
      fi;
   od;
   if Length(next)>0 then 
      i:=i+1; 
      layers[i]:=next; 
      sum:=sum+Length(next); 
   fi;
od;
if sum=n then 
   localDiameter:=Length(layers)-1; 
else 
   localDiameter:=-1; 
fi;
return rec(layerNumbers:=laynum,localDiameter:=localDiameter,
	   localGirth:=localGirth,localParameters:=localParameters);
end);

BindGlobal("InducedSubgraph",function(arg) 
#
# Returns the subgraph of  gamma=arg[1]  induced on the list  V=arg[2]  of
# distinct vertices of  gamma. 
# If  arg[3]  is unbound, then the trivial group is the group associated 
# with the returned induced subgraph. 
# If  arg[3]  is bound, this function assumes that  G=arg[3]   fixes  
# V  setwise, and is a group of automorphisms of the induced subgraph 
# when restricted to  V.  In this case, the image of  G  acting on  V  is 
# the group associated with the returned induced subgraph. 
#
# The i-th vertex of the induced subgraph corresponds to vertex V[i] of
# gamma,  with the i-th vertex-name of the induced subgraph being the 
# vertex-name in  gamma  of V[i].
#
local gamma,V,G,Ggens,gens,indu,i,j,W,VV,X;
gamma:=arg[1];
V:=arg[2];
if not IsGraph(gamma) or not IsList(V) 
    or (IsBound(arg[3]) and not IsPermGroup(arg[3])) then
   Error("usage: InducedSubgraph( <Graph>, <List>, [, <PermGroup> ] )");
fi;
VV:=SSortedList(V);
if Length(V)<>Length(VV) then
   Error("<V> must not contain repeated elements");
fi;
if not IsSubset([1..gamma.order],VV) then
   Error("<V> must be a list of vertices of <gamma>");
fi;
if IsBound(arg[3]) then 
   G:=arg[3];
else
   G:=Group([],());
fi;
W:=[];
for i in [1..Length(V)] do 
   W[V[i]]:=i; 
od;
Ggens:=GeneratorsOfGroup(G);
gens:=[]; 
for i in [1..Length(Ggens)] do 
   gens[i]:=[];
   for j in V do 
      gens[i][W[j]]:=W[j^Ggens[i]]; 
   od;
   gens[i]:=PermList(gens[i]);
od;
indu:=NullGraph(Group(gens,()),Length(V));
if IsBound(gamma.isSimple) and gamma.isSimple then 
   indu.isSimple:=true;
else 
   Unbind(indu.isSimple); 
fi;
for i in [1..Length(indu.representatives)] do
   X:=W{Intersection(VV,Adjacency(gamma,V[indu.representatives[i]]))};
   Sort(X);
   indu.adjacencies[i]:=X;
od;
if not IsBound(gamma.names) then
   indu.names:=Immutable(V);
else
   indu.names:=Immutable(gamma.names{V});
fi;
return indu;
end);

BindGlobal("Distance",function(arg)
#
# Let  gamma=arg[1],  X=arg[2],  Y=arg[3].
# Returns the distance  d(X,Y)  in the graph  gamma, where  X,Y 
# are singleton vertices or lists of vertices.
# (Returns  -1  if no (directed) path joins  X  to  Y  in  gamma.)
# If  arg[4]  is bound, then it is assumed to be a subgroup
# of  Aut(gamma)  stabilizing  X  setwise.
#
local gamma,X,Y;
gamma:=arg[1];
X:=arg[2];
if IsInt(X) then 
   X:=[X];
fi;
Y:=arg[3];
if IsInt(Y) then
   Y:=[Y];
fi;
if not (IsGraph(gamma) and IsList(X) and IsList(Y)) then 
   Error("usage: Distance( <Graph>, <Int> or <List>, ",
			     "<Int> or <List> [, <PermGroup> ] )");
fi;
if IsBound(arg[4]) then 
   return LocalInfo(gamma,X,0,Y,arg[4]).distance;
else
   return LocalInfo(gamma,X,0,Y).distance;
fi;
end);

DeclareOperation("Diameter",[IsRecord]);
# to avoid the clash with `Diameter' defined in gap4r5
InstallMethod(Diameter,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns the diameter of  gamma. 
# A diameter of  -1  means that gamma is not (strongly) connected.  
#
local r,d,loc,reps;
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if gamma.order=0 then
   Error("<gamma> has no vertices");
fi;
d:=-1;
if IsBound(gamma.autGroup) then
   reps:=GRAPE_OrbitNumbers(gamma.autGroup,gamma.order).representatives;
else 
   reps:=gamma.representatives;
fi;
for r in reps do 
   loc:=LocalInfo(gamma,r);
   if loc.localDiameter=-1 then
      return -1; 
   fi;
   if loc.localDiameter > d then
      d:=loc.localDiameter;
   fi;
od;
return d;
end);

DeclareOperation("Girth",[IsRecord]);
InstallMethod(Girth,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns the girth of  gamma,  which must be a simple graph. 
# A girth of  -1  means that gamma is a forest.  
#
local r,g,locgirth,stoplayer,adj,reps;
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if gamma.order=0 then
   return -1;
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
adj:=gamma.adjacencies[1];
if adj<>[] and Intersection(adj,Adjacency(gamma,adj[1]))<>[] then
   return 3;
fi;
g:=-1;
stoplayer:=0;
if IsBound(gamma.autGroup) then
   reps:=GRAPE_OrbitNumbers(gamma.autGroup,gamma.order).representatives;
else 
   reps:=gamma.representatives;
fi;
for r in reps do 
   locgirth:=LocalInfo(gamma,r,stoplayer).localGirth;
   if locgirth=3 then 
      return 3;
   fi;
   if locgirth<>-1 then
      if g=-1 or locgirth<g then
	  g:=locgirth;
	  stoplayer:=Int((g+1)/2)+1; # now no need for  LocalInfo  to create a 
                                     # layer beyond the  stoplayer-th  one.
      fi;
   fi;
od;
return g;
end);

BindGlobal("IsRegularGraph",function(gamma)
#
# Returns  true  iff the graph  gamma  is (out)regular.
#
local deg,i;
if not IsGraph(gamma) then 
   Error("usage: IsRegularGraph( <Graph> )");
fi;
if gamma.order=0 then 
   return true;
fi;
deg:=Length(gamma.adjacencies[1]);
for i in [2..Length(gamma.adjacencies)] do
   if deg <> Length(gamma.adjacencies[i]) then 
      return false;
   fi;
od;
return true;
end);

BindGlobal("IsNullGraph",function(gamma)
#
# Returns  true  iff the graph  gamma  has no edges.
#
local i;
if not IsGraph(gamma) then 
   Error("usage: IsNullGraph( <Graph> )");
fi;
for i in [1..Length(gamma.adjacencies)] do
   if Length(gamma.adjacencies[i])<>0 then 
      return false;
   fi;
od;
return true;
end);

BindGlobal("IsCompleteGraph",function(arg)
#
# Returns  true  iff the graph  gamma=arg[1]  is a complete graph.
# The optional boolean parameter  arg[2]  
# is true iff all loops must exist for  gamma  to be considered
# a complete graph (default: false); otherwise loops are ignored 
# (except to possibly set  gamma.isSimple). 
#
local deg,i,notnecsimple,gamma,mustloops;
gamma:=arg[1];
if IsBound(arg[2]) then 
   mustloops := arg[2];
else
   mustloops := false;
fi;
if not IsGraph(gamma) or not IsBool(mustloops) then 
   Error("usage: IsCompleteGraph( <Graph> [, <Bool> ] )");
fi;
notnecsimple := not IsBound(gamma.isSimple) or not gamma.isSimple;
for i in [1..Length(gamma.adjacencies)] do
   deg := Length(gamma.adjacencies[i]);
   if deg < gamma.order-1 then 
      return false;
   fi;
   if deg=gamma.order-1 then
      if mustloops then
	 return false;
      fi;
      if notnecsimple and 
       (gamma.representatives[i] in gamma.adjacencies[i]) then
	 gamma.isSimple := false;
	 return false;
      fi;
   fi;
od;
return true;
end);

BindGlobal("IsLoopy",function(gamma)
#
# Returns  true  iff graph  gamma  has a loop.
#
local i;
if not IsGraph(gamma) then 
   Error("usage: IsLoopy( <Graph> )");
fi;
for i in [1..Length(gamma.adjacencies)] do
   if gamma.representatives[i] in gamma.adjacencies[i] then
      gamma.isSimple := false;
      return true;
   fi;
od;
return false;
end);

DeclareOperation("IsConnectedGraph",[IsRecord]);
InstallMethod(IsConnectedGraph,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns true iff  gamma  is (strongly) connected.
#
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if gamma.order=0 then
   return true;
fi;
if IsSimpleGraph(gamma) then
   return LocalInfo(gamma,1).localDiameter > -1;
else
   return Diameter(gamma) > -1;
fi;
end);

DeclareOperation("ConnectedComponent",[IsRecord,IsPosInt]);
InstallMethod(ConnectedComponent,"for GRAPE graph",[IsRecord,IsPosInt],0, 
function(gamma,v)
#
# Returns the set of all vertices in  gamma  which can be reached by 
# a path starting at vertex  v.  The graph  gamma  must be simple.
#
local comp,laynum;
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
if not IsVertex(gamma,v) then
   Error("<v> is not a vertex of <gamma>");
fi;
laynum:=LocalInfo(gamma,v).layerNumbers;
comp:=Filtered([1..gamma.order],j->laynum[j]>0);
IsSSortedList(comp);
return comp;
end);

DeclareOperation("ConnectedComponents",[IsRecord]);
InstallMethod(ConnectedComponents,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns the set of the vertex-sets of the connected components
# of  gamma,  which must be a simple graph.
#
local comp,used,i,j,x,cmp,laynum;
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
comp:=[]; 
used:=BlistList([1..gamma.order],[]);
for i in [1..gamma.order] do 
   # Loop invariant: used[j]=true for all j<i. 
   if not used[i] then   # new component
      laynum:=LocalInfo(gamma,i).layerNumbers;
      cmp:=Filtered([i..gamma.order],j->laynum[j]>0);
      IsSSortedList(cmp);
      for x in Orbit(gamma.group,cmp,OnSets) do
	 Add(comp,x);
	 for j in x do 
	    used[j]:=true;
	 od;
      od;
   fi; 
od;
return SSortedList(comp);
end);

BindGlobal("ComponentLocalInfos",function(gamma)
#
# Returns a sequence of localinfos for the connected components of  
# gamma  (w.r.t. some vertex in each component).
# The graph  gamma  must be simple.
#
local comp,used,i,j,k,laynum;
if not IsGraph(gamma) then 
   Error("usage: ComponentLocalInfos( <Graph> )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
comp:=[]; 
used:=BlistList([1..gamma.order],[]);
k:=0;
for i in [1..gamma.order] do 
   if not used[i] then   # new component
      k:=k+1; 
      comp[k]:=LocalInfo(gamma,i);
      laynum:=comp[k].layerNumbers;
      for j in [1..gamma.order] do
	 if laynum[j] > 0 then
	    used[j]:=true;
	 fi;
      od;
   fi; 
od;
return comp;
end);

BindGlobal("Bicomponents",function(gamma)
#
# If  gamma  is bipartite, returns a length 2 list of
# bicomponents, or parts, of  gamma,  else returns the empty list.
# *** This function is for simple  gamma  only.
#
# Note: if gamma.order=0 this function returns [[],[]], and if 
# gamma.order=1 this function returns [[],[1]] (unlike GRAPE 2.2
# which returned [], which was inconsistent with considering 
# a zero vertex graph to be bipartite).
#
local bicomps,i,lnum,loc,locs;
if not IsGraph(gamma) then 
   Error("usage: Bicomponents( <Graph> )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
bicomps:=[[],[]]; 
if gamma.order=0 then 
   return bicomps;
fi;
if IsNullGraph(gamma) then 
   return [[1..gamma.order-1],[gamma.order]];
fi;
locs:=ComponentLocalInfos(gamma);
for loc in locs do
   for i in [2..Length(loc.localParameters)] do
      if loc.localParameters[i][2]<>0 then
         #  gamma  not bipartite.
	 return [];
      fi;
   od;
   for i in [1..Length(loc.layerNumbers)] do 
      lnum:=loc.layerNumbers[i];
      if lnum>0 then
	 if lnum mod 2 = 1 then
	    AddSet(bicomps[1],i);
	 else
	    AddSet(bicomps[2],i);
	 fi;
      fi; 
   od;
od;
return bicomps;
end);

DeclareOperation("IsBipartite",[IsRecord]);
InstallMethod(IsBipartite,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns  true  iff  gamma  is bipartite. 
# *** This function is only for simple  gamma.
#
# Note: Now the one vertex graph is considered to be bipartite 
# (as well as the zero vertex graph). This is a change from the inconsistent 
# GRAPE 2.2 view that a zero vertex graph is bipartite, but not a one 
# vertex graph.
#
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
return Length(Bicomponents(gamma))=2;
end);

BindGlobal("Layers",function(arg)
#
# Returns the list of vertex layers of  gamma=arg[1],  
# starting from  V=arg[2],  which may be a vertex list or singleton vertex. 
# Layers[i]  is the set of vertices at distance  i-1  from  V.
# If  arg[3]  is bound then it is assumed to be a subgroup 
# of  Aut(gamma)  stabilizing  V  setwise.
#
local gamma,V;
gamma:=arg[1];
V:=arg[2];
if IsInt(V) then
   V:=[V];
fi;
if not IsGraph(gamma) or not IsList(V) 
                      or (IsBound(arg[3]) and not IsPermGroup(arg[3])) then 
   Error("usage: Layers( <Graph>, <Int> or <List>, [, <PermGroup>] )");
fi;
if IsBound(arg[3]) then
   return GRAPE_NumbersToSets(LocalInfo(gamma,V,0,[],arg[3]).layerNumbers);
else
   return GRAPE_NumbersToSets(LocalInfo(gamma,V).layerNumbers);
fi;
end);

BindGlobal("LocalParameters",function(arg)
#
# Returns the local parameters of simple, connected  gamma=arg[1],  
# w.r.t to vertex list (or singleton vertex)  V=arg[2].
# The nonexistence of a local parameter is denoted by  -1.
# If  arg[3]  is bound then it is assumed to be a subgroup 
# of  Aut(gamma)  stabilizing  V  setwise.
#
local gamma,V,loc;
gamma:=arg[1];
V:=arg[2];
if IsInt(V) then
   V:=[V];
fi;
if not IsGraph(gamma) or not IsList(V) 
                      or (IsBound(arg[3]) and not IsPermGroup(arg[3])) then 
   Error("usage: LocalParameters( <Graph>, <Int> or <List>, [, <PermGroup>] )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
if Length(V)>1 and not IsConnectedGraph(gamma) then
   Error("<gamma> not a connected graph");
fi;
if IsBound(arg[3]) then
   loc:=LocalInfo(gamma,V,0,[],arg[3]);
else
   loc:=LocalInfo(gamma,V);
fi;
if loc.localDiameter=-1 then
   Error("<gamma> not a connected graph");
fi;
return loc.localParameters;
end);

BindGlobal("GlobalParameters",function(gamma)
#
# Determines the global parameters of connected, simple graph  gamma.
# The nonexistence of a global parameter is denoted by  -1.
#
local i,j,k,reps,pars,lp,loc;
if not IsGraph(gamma) then 
   Error("usage: GlobalParameters( <Graph> )");
fi;
if gamma.order=0 then
   return [];
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
if IsBound(gamma.autGroup) then
   reps:=GRAPE_OrbitNumbers(gamma.autGroup,gamma.order).representatives;
else 
   reps:=gamma.representatives;
fi;
loc:=LocalInfo(gamma,reps[1]);
if loc.localDiameter=-1 then
   Error("<gamma> not a connected graph");
fi;
pars:=loc.localParameters;
for i in [2..Length(reps)] do
   lp:=LocalInfo(gamma,reps[i]).localParameters;
   for j in [1..Maximum(Length(lp),Length(pars))] do
      if not IsBound(lp[j]) or not IsBound(pars[j]) then
	 pars[j]:=[-1,-1,-1];
      else
	 for k in [1..3] do
	    if pars[j][k]<>lp[j][k] then
	       pars[j][k]:=-1;
	    fi;
	 od;
      fi;
   od;
od;
return pars;
end);

DeclareOperation("IsDistanceRegular",[IsRecord]);
InstallMethod(IsDistanceRegular,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns  true  iff  gamma  is distance-regular 
# (a graph must be simple to be distance-regular).
#
local i,reps,pars,lp,loc,d;
if not IsGraph(gamma) then
   TryNextMethod();
fi;
if gamma.order=0 then
   return true;
fi;
if not IsSimpleGraph(gamma) then
   return false;
fi;
if IsBound(gamma.autGroup) then
   reps:=GRAPE_OrbitNumbers(gamma.autGroup,gamma.order).representatives;
else 
   reps:=gamma.representatives;
fi;
loc:=LocalInfo(gamma,reps[1]);
pars:=loc.localParameters;
d:=loc.localDiameter;
if d=-1 then  # gamma not connected
   return false;
fi;
if -1 in Flat(pars) then 
   return false;
fi;
for i in [2..Length(reps)] do
   loc:=LocalInfo(gamma,reps[i]);
   if loc.localDiameter<>d then 
      return false;
   fi;
   if pars <> loc.localParameters then
      return false;
   fi;
od;
return true;
end);

BindGlobal("DistanceSet",function(arg)
#
# Let  gamma=arg[1],  distances=arg[2],  V=arg[3].
# Returns the set of vertices  w  of  gamma,  such that  d(V,w)  is in
# distances (a list or singleton distance). 
# If  arg[4]  is bound, then it is assumed to be a subgroup
# of  Aut(gamma)  stabilizing  V  setwise.
#
local gamma,distances,V,maxlayer,distset,laynum,x,i;
gamma:=arg[1];
distances:=arg[2];
V:=arg[3];
if IsInt(distances) then   # assume  distances  consists of a single distance.
   distances:=[distances];
fi;
if not (IsGraph(gamma) and IsList(distances) and (IsList(V) or IsInt(V))) then
   Error("usage: DistanceSet( <Graph>, <Int> or <List>, ",
			     "<Int> or <List> [, <PermGroup> ] )");
fi;
if not IsSSortedList(distances) then 
   distances:=SSortedList(distances);
fi;
distset:=[];
if Length(distances)=0 then
   return distset;
fi;
maxlayer:=Maximum(distances)+1;
if IsBound(arg[4]) then
   laynum:=LocalInfo(gamma,V,maxlayer,[],arg[4]).layerNumbers;
else
   laynum:=LocalInfo(gamma,V,maxlayer).layerNumbers;
fi;
for i in [1..gamma.order] do
   if laynum[i]-1 in distances then
      Add(distset,i);
   fi;
od;
IsSSortedList(distset);
return distset;
end);

BindGlobal("DistanceSetInduced",function(arg)
#
# Let  gamma=arg[1],  distances=arg[2],  V=arg[3].
# Returns the graph induced on the set of vertices  w  of  gamma,  
# such that  d(V,w)  is in distances (a list or singleton distance). 
# If  arg[4]  is bound, then it is assumed to be a subgroup
# of  Aut(gamma)  stabilizing  V  setwise.
#
local gamma,distances,V,distset,H;
gamma:=arg[1];
distances:=arg[2];
V:=arg[3];
if IsInt(distances) then   # assume  distances  consists of a single distance.
   distances:=[distances];
fi;
if IsInt(V) then
   V:=[V];
fi;
if IsBound(arg[4]) then
   H:=arg[4];
elif Length(V)=1 then
   H:=ProbablyStabilizer(gamma.group,V[1]);
else
   H:=Group([],());
fi;
if not (IsGraph(gamma) and IsList(distances) and IsList(V) and IsPermGroup(H))
  then
   Error("usage: DistanceSetInduced( <Graph>, ",
	 "<Int> or <List>, <Int> or <List> [, <PermGroup> ] )");
fi;
distset:=DistanceSet(gamma,distances,V,H);
return InducedSubgraph(gamma,distset,H);
end);

BindGlobal("DistanceGraph",function(gamma,distances)
#
# Returns graph  delta  with the same vertex-set, names, and group as 
# gamma,  and  [x,y]  is an edge of  delta  iff  d(x,y)  (in gamma)
# is in  distances. 
#
local r,delta,d,i;
if IsInt(distances) then
   distances:=[distances];
fi;
if not IsGraph(gamma) or not IsList(distances) then 
   Error("usage: DistanceGraph( <Graph>, <Int> or <List> )");
fi;
delta:=rec(isGraph:=true,order:=gamma.order,group:=gamma.group,
	   schreierVector:=Immutable(gamma.schreierVector),adjacencies:=[],
	   representatives:=Immutable(gamma.representatives));
if IsBound(gamma.names) then
   delta.names:=Immutable(gamma.names);
fi;
for i in [1..Length(delta.representatives)] do 
   delta.adjacencies[i]:=DistanceSet(gamma,distances,delta.representatives[i]);
od;
if not (0 in distances) and IsBound(gamma.isSimple) and gamma.isSimple then
   delta.isSimple:=true;
fi;
return delta;
end);

BindGlobal("ComplementGraph",function(arg)
#
# Returns the complement of the graph  gamma=arg[1]. 
# arg[2] is true iff loops/nonloops are to be complemented (default:false).
#
local gamma,comploops,i,delta,notnecsimple;
gamma:=arg[1];
if IsBound(arg[2]) then
   comploops:=arg[2];
else
   comploops:=false;
fi;
if not IsGraph(gamma) or not IsBool(comploops) then 
   Error("usage: ComplementGraph( <Graph> [, <Bool> ] )");
fi;
notnecsimple:=not IsBound(gamma.isSimple) or not gamma.isSimple;
delta:=rec(isGraph:=true,order:=gamma.order,group:=gamma.group,
	   schreierVector:=Immutable(gamma.schreierVector),adjacencies:=[],
	   representatives:=Immutable(gamma.representatives));
if IsBound(gamma.names) then
   delta.names:=Immutable(gamma.names);
fi;
if IsBound(gamma.autGroup) then
   delta.autGroup:=gamma.autGroup;
fi;
if IsBound(gamma.isSimple) then
   if gamma.isSimple and not comploops then
      delta.isSimple:=true;
   fi;
fi;
for i in [1..Length(delta.representatives)] do 
   delta.adjacencies[i]:=Difference([1..gamma.order],gamma.adjacencies[i]);
   if not comploops then
      RemoveSet(delta.adjacencies[i],delta.representatives[i]);
      if notnecsimple and (gamma.representatives[i] in gamma.adjacencies[i])
       then
	 AddSet(delta.adjacencies[i],delta.representatives[i]);
      fi;
   fi;
od;
return delta;
end);

BindGlobal("PointGraph",function(arg)
#
# Assuming that  gamma=arg[1]  is simple, connected, and bipartite, 
# this function returns the connected component containing  
# v=arg[2]  of the distance-2  graph of  gamma=arg[1]  
# (default:  arg[2]=1,  unless  gamma has zero
# vertices, in which case a zero vertex graph is returned). 
# Thus, if  gamma  is the incidence graph of a (connected) geometry, and 
# v  represents a point, then the point graph of the geometry is returned.
#
local gamma,delta,bicomps,comp,v,gens,hgens,i,g,j,outer;
gamma:=arg[1];
if IsBound(arg[2]) then 
   v:=arg[2];
else
   v:=1;
fi;
if not IsGraph(gamma) or not IsInt(v) then
   Error("usage: PointGraph( <Graph> [, <Int> ])");
fi;
if gamma.order=0 then
   return CopyGraph(gamma);
fi;
bicomps:=Bicomponents(gamma);
if Length(bicomps)=0 or not IsSimpleGraph(gamma) 
		     or not IsConnectedGraph(gamma) then
   Error("<gamma> not  simple,connected,bipartite");
fi;
if v in bicomps[1] then 
   comp:=bicomps[1];
else
   comp:=bicomps[2];
fi;
delta:=DistanceGraph(gamma,2);
# construct Schreier generators for the subgroup of  gamma.group 
# fixing  comp.
gens:=GeneratorsOfGroup(gamma.group);
hgens:=[];
for i in [1..Length(gens)] do
   g:=gens[i];
   if v^g in comp then
      AddSet(hgens,g);
      if IsBound(outer) then
	 AddSet(hgens,outer*g/outer);
      fi;
   else    # g is an "outer" element
      if IsBound(outer) then
	 AddSet(hgens,g/outer);
	 AddSet(hgens,outer*g);
      else 
	 outer:=g;
	 for j in [1..i-1] do
	    AddSet(hgens,outer*gens[j]/outer);
	 od;
	 g:=g^2;
	 if g <> () then
	    AddSet(hgens,g);
	 fi;
      fi;
   fi;
od;
return InducedSubgraph(delta,comp,Group(hgens,()));
end);

BindGlobal("EdgeGraph",function(gamma)
#
# Returns the edge graph, also called the line graph, of the 
# (assumed) simple graph  gamma.
# This edge graph  delta  has the unordered edges of  gamma  as 
# vertices, and  e  is joined to  f  in delta precisely when 
# e<>f,  and  e,f  have a common vertex in  gamma.
#
local delta,i,j,k,edgeset,adj,r,e,f;
if not IsGraph(gamma) then 
   Error("usage: EdgeGraph( <Graph> )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
edgeset:=UndirectedEdges(gamma);
delta:=NullGraph(Action(gamma.group,edgeset,OnSets),Length(edgeset));
delta.names:=Immutable(List(edgeset,e->List(e,i->VertexName(gamma,i))));
for i in [1..Length(delta.representatives)] do
   r:=delta.representatives[i];
   e:=edgeset[r];
   adj:=delta.adjacencies[i];
   for k in [1,2] do
      for j in Adjacency(gamma,e[k]) do
	 f:=SSortedList([e[k],j]);
	 if e<>f then
	    AddSet(adj,PositionSet(edgeset,f));
	 fi;
      od;
   od;
od;
return delta;
end);

BindGlobal("QuotientGraph",function(gamma,R)
#
# Returns the quotient graph  delta  of  gamma  defined by the 
# smallest  gamma.group  invariant equivalence relation  S 
# (on the vertices of  gamma)  containing the relation  R  (given
# as a list of ordered pairs of vertices of  gamma).
# The vertices of this quotient  delta  are the equivalence 
# classes of  S,  and  [X,Y]  is an edge of  delta  iff  
# [x,y]  is an edge of  gamma  for some  x in X,  y in Y.
#
local root,Q,F,V,W,i,j,r,q,x,y,names,gens,delta,g,h,m,pos;

root := function(x)
#
# Returns the root of the tree containing  x  in the forest represented 
# by  F,  and compresses the path travelled in this tree to find the root.
# F[x]=-x  if  x  is a root, else  F[x]  is the parent of  x.
#
local t,u;
t:=F[x];
while t>0 do 
   t:=F[t];
od;
# compress path
u:=F[x];
while u<>t do
   F[x]:=-t;
   x:=u;
   u:=F[x];
od;  
return -t;
end;

if not IsGraph(gamma) or not IsList(R) then
   Error("usage: QuotientGraph( <Graph>, <List> )");
fi;
if gamma.order<=1 or Length(R)=0 then
   delta:=CopyGraph(gamma);
   delta.names:=Immutable(List([1..gamma.order],i->[VertexName(gamma,i)]));
   return delta;
fi;
if IsInt(R[1]) then   # assume  R  consists of a single pair.
   R:=[R];
fi;
F:=[];
for i in [1..gamma.order] do
   F[i]:=-i;
od;
Q:=[];
for r in R do
   x:=root(r[1]);
   y:=root(r[2]);
   if x<>y then
      if x>y then
	 Add(Q,x);
	 F[x]:=y;
      else
	 Add(Q,y);
	 F[y]:=x;
      fi;
   fi;
od;
for q in Q do 
   for g in GeneratorsOfGroup(gamma.group) do
      x:=root(F[q]^g);
      y:=root(q^g);
      if x<>y then
	 if x>y then
	    Add(Q,x);
	    F[x]:=y;
	 else
	    Add(Q,y);
	    F[y]:=x;
	 fi;
      fi;
   od;
od;
for i in Reversed([1..gamma.order]) do
   if F[i] < 0 then
      F[i]:=-F[i];
   else
      F[i]:=root(F[i]);
   fi;
od;
V:=SSortedList(F);
W:=[];
names:=[];
m:=Length(V);
for i in [1..m] do
   W[V[i]]:=i;
   names[i]:=[];
od;
for i in [1..gamma.order] do
   Add(names[W[F[i]]],VertexName(gamma,i));
od; 
gens:=[];
for g in GeneratorsOfGroup(gamma.group) do
   h:=[];
   for i in [1..m] do
      h[i]:=W[F[V[i]^g]];
   od;
   Add(gens,PermList(h));
od;
delta:=NullGraph(Group(gens,()),m);
delta.names:=Immutable(names);
IsSSortedList(delta.representatives);
for i in [1..gamma.order] do
   pos:=PositionSet(delta.representatives,W[F[i]]);
   if pos<>fail then
      for j in Adjacency(gamma,i) do
	 AddSet(delta.adjacencies[pos],W[F[j]]);
      od;
   fi;
od;
if IsLoopy(delta) then
   delta.isSimple:=false;
elif IsBound(gamma.isSimple) and gamma.isSimple then
   delta.isSimple:=true;
else
   Unbind(delta.isSimple);
fi;
return delta;
end);
 
BindGlobal("BipartiteDouble",function(gamma)
#
# Returns the bipartite double of  gamma,  as defined in BCN.
#
local gens,g,delta,n,i,adj;
if not IsGraph(gamma) then 
   Error("usage: BipartiteDouble( <Graph> )");
fi;
if gamma.order=0 then 
   return CopyGraph(gamma);
fi;
n:=gamma.order;
gens:=GRAPE_IntransitiveGroupGenerators
	 (GeneratorsOfGroup(gamma.group),GeneratorsOfGroup(gamma.group),n,n);
g:=[];
for i in [1..n] do
   g[i]:=i+n;
   g[i+n]:=i;
od;
Add(gens,PermList(g));
delta:=NullGraph(Group(gens,()),2*n);
for i in [1..Length(delta.adjacencies)] do
   adj:=Adjacency(gamma,delta.representatives[i]);
   if Length(adj)=0 then
      delta.adjacencies[i]:=[];
   else
      delta.adjacencies[i]:=adj+n;
   fi;
od;
if not IsBound(gamma.isSimple) or not gamma.isSimple then
   Unbind(delta.isSimple);
fi;
delta.names:=[];
for i in [1..n] do
   delta.names[i]:=[VertexName(gamma,i),"+"];
od;
for i in [n+1..2*n] do
   delta.names[i]:=[VertexName(gamma,i-n),"-"];
od;
delta.names:=Immutable(delta.names);
return delta;
end);
   
BindGlobal("UnderlyingGraph",function(gamma)
#
# Returns the underlying graph  delta  of  gamma.
# This graph has the same vertex-set as  gamma,  and 
# has an edge  [x,y]  precisely when  gamma  has an 
# edge  [x,y]  or  [y,x].
# This function also sets the  isSimple  fields of 
# gamma  (via IsSimpleGraph)  and  delta.
#
local delta,adj,i,x,orb,H;
if not IsGraph(gamma) then 
   Error("usage: UnderlyingGraph( <Graph> )");
fi;
delta:=CopyGraph(gamma);
if IsSimpleGraph(gamma) then
   delta.isSimple:=true;
   return delta;
fi;
for i in [1..Length(delta.adjacencies)] do
   adj:=delta.adjacencies[i];
   x:=delta.representatives[i];
   H:=ProbablyStabilizer(delta.group,x);
   for orb in OrbitsDomain(H,adj) do
      if not IsVertexPairEdge(delta,orb[1],x) then
	 AddEdgeOrbit(delta,[orb[1],x]);
      fi;
   od;
od;
delta.isSimple := not IsLoopy(delta); 
return delta;
end);

BindGlobal("NewGroupGraph",function(G,gamma)
#
# Returns a copy of  delta  of  gamma, except that  delta.group=G.
#
local delta,i;
if not IsPermGroup(G) or not IsGraph(gamma) then 
   Error("usage: NewGroupGraph( <PermGroup>, <Graph> )");
fi;
delta:=NullGraph(G,gamma.order);
if IsBound(gamma.isSimple) then
   delta.isSimple:=gamma.isSimple;
else
   Unbind(delta.isSimple);
fi;
if IsBound(gamma.autGroup) then
   delta.autGroup:=gamma.autGroup;
fi;
# if IsBound(gamma.canonicalLabelling) then
#    delta.canonicalLabelling:=gamma.canonicalLabelling;
# fi;
if IsBound(gamma.names) then
   delta.names:=Immutable(gamma.names);
fi;
if IsBound(gamma.maximumClique) then
   delta.maximumClique:=Immutable(gamma.maximumClique);
fi;
if IsBound(gamma.minimumVertexColouring) then
   delta.minimumVertexColouring:=Immutable(gamma.minimumVertexColouring);
fi;
for i in [1..Length(delta.representatives)] do
   delta.adjacencies[i]:=Adjacency(gamma,delta.representatives[i]);
od;
return delta;
end);

BindGlobal("GeodesicsGraph",function(gamma,x,y)
#
# Returns the graph induced on the set of geodesics between 
# vertices  x  and  y,  but not including  x  or  y. 
# *** This function is only for simple  gamma.
#
local i,n,locx,geoset,H,laynumx,laynumy,w,g,h,rwx,rwy,gens,sch,orb,pt,im;
if not IsGraph(gamma) or not IsInt(x) or not IsInt(y) then 
   Error("usage: GeodesicsGraph( <Graph>, <Int>, <Int> )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
locx:=LocalInfo(gamma,x,0,y);
if locx.distance=-1 then
   Error("<x> not joined to <y>");
fi;
laynumx:=locx.layerNumbers;
laynumy:=LocalInfo(gamma,y,0,x).layerNumbers;
geoset:=[];
n:=locx.distance;
for i in [1..gamma.order] do 
   if laynumx[i]>1 and laynumy[i]>1 and laynumx[i]+laynumy[i]=n+2 then
      Add(geoset,i);
   fi;
od;
H:=ProbablyStabilizer(gamma.group,y);
gens:=GeneratorsOfGroup(gamma.group);
rwx:=GRAPE_RepWord(gens,gamma.schreierVector,x);
rwy:=GRAPE_RepWord(gens,gamma.schreierVector,y);
g:=();
if rwx.representative=rwy.representative then
   for w in Reversed(rwx.word) do 
      g:=g/gens[w];
   od;
   for w in rwy.word do 
      g:=g*gens[w];
   od;
   pt:=y^g;
   sch:=[];
   orb:=[pt];
   sch[pt]:=();
   for i in orb do
      for h in GeneratorsOfGroup(H) do
	 im:=i^h;
	 if not IsBound(sch[im]) then
	    sch[im]:=h;
	    Add(orb,im);
	 fi;
      od;
   od; 
   if IsBound(sch[x]) then
      i:=x;
      h:=();
      while i<>pt do
	 h:=h/sch[i];
	 i:=x^h;
      od;
      g:=g*h^-1;
   fi;
fi;
H:=ProbablyStabilizer(H,x);
if x^g=y and y^g=x then
   H:=ShallowCopy(GeneratorsOfGroup(H));
   Add(H,g);
   H:=Group(H,());
fi;
return InducedSubgraph(gamma,geoset,H);
end);

BindGlobal("IndependentSet",function(arg)
#
# Returns a (hopefully large) independent set (coclique) of  gamma=arg[1].
# The returned independent set will contain the (assumed) independent set  
# arg[2]  (default [])  and not contain any element of arg[3]
# (default [], in which case the returned independent set is maximal).
# An error is signalled if arg[2] and arg[3] have non-trivial intersection.
# A "greedy" algorithm is used, and the graph  gamma  must be simple.
#
local gamma,is,forbidden,i,j,k,poss,adj,mindeg,minvert,degs;
gamma:=arg[1];
if not IsBound(arg[2]) then
   is:=[];
else
   is:=SSortedList(arg[2]);
fi;
if not IsBound(arg[3]) then
   forbidden:=[];
else
   forbidden:=SSortedList(arg[3]);
fi;
if not (IsGraph(gamma) and IsSSortedList(is) and IsSSortedList(forbidden)) then 
   Error("usage: IndependentSet( <Graph> [, <List> [, <List> ]] )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
if Length(Intersection(is,forbidden))>0 then
   Error("<is> and <forbidden> have non-trivial intersection");
fi;
if gamma.order=0 then 
   return [];
fi;
poss:=Difference([1..gamma.order],forbidden); 
SubtractSet(poss,is);
for i in is do
   SubtractSet(poss,Adjacency(gamma,i));
od;
#  is  contains the independent set so far.
#  poss  contains the possible new elements of the independent set.
degs:=[];
for i in poss do
   degs[i]:=Length(Intersection(Adjacency(gamma,i),poss));
od;
while poss <> [] do
   minvert:=poss[1];
   mindeg:=degs[poss[1]];
   for i in [2..Length(poss)] do
      k:=degs[poss[i]];
      if k < mindeg then
	 mindeg:=k;
	 minvert:=poss[i];
      fi;
   od;
   AddSet(is,minvert);
   RemoveSet(poss,minvert);
   adj:=Intersection(Adjacency(gamma,minvert),poss);
   SubtractSet(poss,adj); 
   for i in adj do
      for j in Intersection(poss,Adjacency(gamma,i)) do
	 degs[j]:=degs[j]-1;
      od;
   od;
od;
return is;
end);

BindGlobal("CollapsedIndependentOrbitsGraph",function(arg)
#
# Given a subgroup  G=arg[1]  of the automorphism group of
# the graph  gamma=arg[2]  (assumed simple), this function returns 
# a graph  delta  defined as follows.  The vertices of  delta  are 
# those G-orbits of V(gamma) that are independent sets,
# and  x  is joined to  y  in  delta  iff  x union y  is *not* an
# independent set in  gamma.
# If  arg[3]  is bound then it is assumed to be a subgroup of 
# Aut(gamma) preserving the set of orbits of  G  on the vertices
# of  gamma  (for example, the normalizer of  G  in gamma.group). 
#
local G,gamma,N,orb,orbs,i,j,L,rel;
G:=arg[1];
gamma:=arg[2];
if IsBound(arg[3]) then
   N:=arg[3];
else
   N:=G;
fi;
if not IsPermGroup(G) or not IsGraph(gamma) or not IsPermGroup(N) then
   Error("usage: CollapsedIndependentOrbitsGraph( ",
	 "<PermGroup>, <Graph> [, <PermGroup>] )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
orbs:=List(OrbitsDomain(G,[1..gamma.order]),Set);
i:=1;
L:=[];
rel:=[];
for orb in orbs do
  if Length(Intersection(orb,Adjacency(gamma,orb[1])))=0 then
      # an independent set is induced on  orb
      Add(L,orb);
      for j in [i+1..i+Length(orb)-1] do
	 Add(rel,[i,j]);
      od;
      i:=i+Length(orb);
   fi;
od;
return QuotientGraph(InducedSubgraph(gamma,Concatenation(L),N),rel);
end);

BindGlobal("CollapsedCompleteOrbitsGraph",function(arg)
#
# Given a subgroup  G=arg[1]  of the automorphism group of
# the graph  gamma=arg[2]  (assumed simple), this function returns
# a graph  delta  defined as follows.  The vertices of  delta  are 
# those G-orbits of V(gamma) that are complete subgraphs,
# and  x  is joined to  y  in  delta  iff  x<>y  and  x union y  is a
# complete subgraph of  gamma.
# If  arg[3]  is bound then it is assumed to be a subgroup of 
# Aut(gamma) preserving the set of orbits of  G  on the vertices
# of  gamma  (for example, the normalizer of  G  in gamma.group). 
#
local G,gamma,N;
G:=arg[1];
gamma:=arg[2];
if IsBound(arg[3]) then
   N:=arg[3];
else
   N:=G;
fi;
if not IsPermGroup(G) or not IsGraph(gamma) or not IsPermGroup(N) then
   Error("usage: CollapsedCompleteOrbitsGraph( ",
	 "<PermGroup>, <Graph> [, <PermGroup>] )");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> not a simple graph");
fi;
return 
   ComplementGraph(CollapsedIndependentOrbitsGraph(G,ComplementGraph(gamma),N));
end);

BindGlobal("GraphImage",function(gamma,perm)
#
# Returns the image  delta  of the graph  gamma,  under the permutation  perm,
# which must be a permutation of  [1..gamma.order].
#
local delta,i,perminv;
if not IsGraph(gamma) or not IsPerm(perm) then 
   Error("usage: GraphImage( <Graph>, <Perm> )");
fi;
if LargestMovedPoint(perm) > gamma.order then
   Error("<perm> must be a permutation of [1..<gamma>.order]");
fi;
delta:=NullGraph(Group(List(GeneratorsOfGroup(gamma.group),x->x^perm),()),
   gamma.order);
if HasSize(gamma.group) or HasStabChainMutable(gamma.group) then
   SetSize(delta.group,Size(gamma.group));
fi;
if IsBound(gamma.isSimple) then
   delta.isSimple:=gamma.isSimple;
else
   Unbind(delta.isSimple);
fi;
if IsBound(gamma.autGroup) then
   delta.autGroup:=Group(List(GeneratorsOfGroup(gamma.autGroup),x->x^perm),());
   if HasSize(gamma.autGroup) or HasStabChainMutable(gamma.autGroup) then
      SetSize(delta.autGroup,Size(gamma.autGroup));
   fi;
fi;
# if IsBound(gamma.canonicalLabelling) then
#    delta.canonicalLabelling:=gamma.canonicalLabelling*perm;
# fi;
perminv:=perm^-1;
delta.names:=Immutable(List([1..delta.order],i->VertexName(gamma,i^perminv)));
if IsBound(gamma.maximumClique) then
   delta.maximumClique:=Immutable(OnSets(gamma.maximumClique,perm)); 
fi;
if IsBound(gamma.minimumVertexColouring) then
   delta.minimumVertexColouring:=Immutable(List([1..delta.order],
      i->gamma.minimumVertexColouring[i^perminv]));
fi;
for i in [1..Length(delta.representatives)] do
   delta.adjacencies[i]:=
      OnSets(Adjacency(gamma,delta.representatives[i]^perminv),perm);
od;
return delta;
end);

BindGlobal("CompleteSubgraphsMain",function(gamma,kvector,allsubs,allmaxes,
                                        partialcolour,weightvectors,dovector)
#
# This function, not for the user, subsumes the tasks formerly 
# done by  CompleteSubgraphs  and  CompleteSubgraphsOfGivenSize. 
# These latter functions are now shells to check parameters and 
# to call this main function, which can also compute complete
# subgraphs with given vertex-weightvector sum. More precise details 
# are given below.
#
# Let  gamma  be a simple graph, and  kvector  an integer vector
# of dimension (i.e. a dense integer list of length)  d>=1,  with all 
# entries non-negative if d>1.
#
# The parameter  weightvectors  is then a list of length 
# gamma.order  of non-zero d-vectors of non-negative integers, 
# with the *weight-vector* (or *weightvector*) of a
# vertex  v  of  gamma  being  weightvectors[v],  and
# the  *weight*  of  v  being the sum of the entries of its
# weight-vector. Moreover, we assume that there is a group  GG  acting on
# the set of all integer d-vectors by permuting vector positions, such that: 
#
# (1) there is an epimorphism  theta : GG --> gamma.group,  and  
# 
# (2) for all  v  in  Vertices(gamma)  and all  g  in  GG,  we have
#
#                weightvectors[v^((g)theta)] = weightvectors[v]^g
#
# (where the first action is OnPoints, and the second action is the assumed 
# one of  GG  on integer d-vectors).  
#
# Note that, in particular, this implies that  Set(weightvectors)  
# is invariant under  GG,  and that the weight of a vertex is constant 
# over a  gamma.group  orbit of vertices.
#
# We assume that  kvector  is fixed by  GG,  and let  k=Sum(kvector).
#
# First, suppose that  kvector=[k],  with k<0. 
#
# Then this function returns a set  K  of complete subgraphs of  gamma, 
# with a complete subgraph being represented by the set of its vertices.
# If  allmaxes=true  then only  maximal complete subgraphs are returned, 
# and if  allmaxes=false  then arbitrary complete subgraphs are returned. 
# 
# The parameter  allsubs  is used to control how many 
# complete subgraphs are returned.
# If  allsubs=1,  then  K  will contain (perhaps properly) 
# a set of  gamma.group  orbit-representatives of the maximal  
# (if allmaxes=true)  or of all (if allmaxes=false)  
# complete subgraphs of  gamma.  
# If  allsubs=2  then  K  will be (exactly) a set of  gamma.group  
# orbit-representatives of the maximal  (if allmaxes=true)  or all
# (if  allmaxes=false) complete subgraphs of  gamma  (this may be
# more expensive than when  allsubs=1).  
# If  allsubs=0,  then  K  will contain exactly one complete subgraph,
# which is guaranteed to be maximal if  allmaxes=true.
#
# The parameters  partialcolour,  weightvectors  and  dovector  
# are ignored if k<0.
#
# Now suppose that  k>=0.
#
# Then this function returns a set  K  of complete subgraphs of  gamma,
# each of which having vertex-weightvectors summing to  kvector.
# Such a complete subgraph is called a *solution* here. 
# A complete subgraph is represented by the set of its vertices. 
# Note that the set of all solutions is  gamma.group-invariant. 
#
# If  allmaxes=true  then only  maximal complete subgraphs  
# forming solutions are returned, and if  allmaxes=false  then 
# the returned solutions need not be maximal complete subgraphs. 
# 
# The parameter  allsubs  is used to control how many solutions  
# are returned.  If  allsubs=1, 
# then  K  will contain (perhaps properly) a set of  gamma.group  
# orbit-representatives of all the solutions  (if allmaxes=false)  or 
# of the solutions that form maximal complete subgraphs  (if allmaxes=true).  
# If  allsubs=2  then  K  will be (exactly) a set of  gamma.group  
# orbit-representatives of all the solutions  (if allmaxes=false)  or 
# of the solutions that form maximal complete subgraphs  (if allmaxes=true)  
# (this may be more expensive than when  allsubs=1).  
# If  allsubs=0, then  K  will contain at most one element and will 
# contain one element iff  gamma   contains a solution,  unless  
# allmaxes=true,  in which case   K  will contain one element iff  gamma  
# contains a solution which forms a maximal complete subgraph  
# (in which case  K  will contain such a solution).
#
# The boolean parameter  partialcolour  determines whether
# or not partial proper vertex-colouring is used to try to cut
# down the search tree.  The default is true (employ this vertex-colouring).
#
# The parameter  dovector  must be a d-vector containing an ordering
# of  [1..d].  There is no harm (except perhaps for efficiency) in
# giving  dovector  the value  [1..d].
#
local IsFixedPoint,HasLargerEntry,k,smallorder,smallorder1,weights,weighted,
      originalG,originalgamma,includingallmaximalreps,zeroonevectorweighted, 
      CompleteSubgraphsSearch,K,clique,cliquenumber,chromaticnumber;

IsFixedPoint := function(G,point)
#
# This boolean function returns true iff  point  is a fixed-point of the 
# group  G  in its action  OnPoints.
#
return ForAll(GeneratorsOfGroup(G),x->point^x=point);
end;

HasLargerEntry := function(v,w)
#
# This boolean function assumes that v and w are equal-length integer vectors,
# and returns true iff v[i]>w[i] for some 1<=i<=Length(v).
#
local i;
for i in [1..Length(v)] do
   if v[i]>w[i] then
      return true;
   fi;
od;
return false;
end;

CompleteSubgraphsSearch := function(gamma,kvector,sofar,forbidden)
#
# This recursive function is called by  CompleteSubgraphsMain  to do all 
# the real work.  It is assumed that on the call from  CompleteSubgraphsMain,  
# gammma.names  is bound, and is equal to  [1..gamma.order]. 
#
# This function returns a dense list of distinct complete subgraphs of
# gamma,  each of which is given as a dense list of distinct vertex-names.
#
# The variables  smallorder,  smallorder1,  originalG,  
# allsubs,  allmaxes,  weights,  weightvectors,  weighted, 
# partialcolour,  dovector,  IsFixedPoint,  and  HasLargerEntry  
# are global.  (originalG  is the group of automorphisms 
# associated with the original graph.)  
#
# If  allsubs=2  then the returned complete subgraphs will be 
# (pairwise) inequivalent under gamma.group. 
# 
# The parameter  sofar  is the set of vertices of the original graph 
# chosen "so far".  We assume that  kvector  is equal to the original
# kvector  passed to  CompleteSubgraphsMain  minus the sum of the 
# weightvectors of the elements in  sofar. 
#
# The parameter  forbidden  is a  gamma.group-invariant  set of
# vertex-names not in  sofar,  such that, for every element  f  in  forbidden, 
# all required solutions have already been found containing  sofar union {f}. 
# The value of  forbidden  may be changed by this function.
#
# If  allsubs>0  then this function returns a list of complete 
# subgraphs which, when each of its elements is augmented by 
# the elements in  sofar,  is a list of solutions containing 
# a transversal of the distinct  originalG-orbits  of all the originally 
# required solutions (maximal complete or otherwise) which contain sofar, 
# except possibly those orbits containing a solution  S  having an  
# element in  forbidden. 
#
# If  allsubs=0  then this function returns (a list of) 
# at most one complete subgraph, and returns (a list of) one
# complete subgraph  c  if and only if  c union sofar  is a solution
# (and also a maximal complete subgraph if  allmaxes=true). 
#
# If  allsubs=2  or  allmaxes:
#    It is assumed that the set of vertex-names of  gamma  is the set 
#    of all vertices in the original graph adjacent to each element of  sofar.
#    It is also assumed that  gamma.group  (in its action on gamma.names)
#    is contained in the image of the stabilizer in  originalG  of the set  
#    sofar (in that group's action on  gamma.names), with equality if  
#    allsubs=2.
#
# We will be attempting the possible ways of adding 
# a vertex(-name)  v  to  sofar,  such that  
# 
#     weightvectors[names[v]][doposition]<>0, 
#
# where  doposition  is a heuristically chosen position 
# of a non-zero element of  kvector.  Currently, we simply take  
#           
#      doposition:=First(dovector,x->kvector[x])<>0);
#
# 
# We "dynamically" order the search tree, as described in:
# W. Myrvold, T. Prsa and N. Walker, A Dynamic programming approach
# for timing and designing clique algorithms, Algorithms and Experiments
# (ALEX '98): Building Bridges Between Theory and Applications, 1998,
# pp. 88-95.
#
local k,n,i,j,delta,adj,rep,a,b,ans,ans1,ans2,names,W,H,HH,newsofar,
      G,orb,kk,ll,mm,active,nadj,verticesremoved,J,doposition,
      A,nactive,nactivevector,wt,indorbwtsum,CompleteSubgraphsSearch1;

CompleteSubgraphsSearch1 := function(mask,kvector,forbidmask)
#
# This function does the work of  CompleteSubgraphsSearch,   
# but assuming the group associated to the graph is trivial.
#
# The parameters  mask  and  forbidmask  are boolean lists of length  n,  
# and the global variable  A  has value an  n x n  adjacency matrix 
# for a graph  gamma  (given as a length  n  list of boolean lists).  
# The actual graph in which we are determining complete subgraphs
# is the induced subgraph  delta  of  gamma  on the 
# vertices  i  for which  mask[i]=true, and we are determining 
# complete subgraphs of  delta  containing no vertex  j
# for which forbidmask[j]=true.  We assume that (as sets),  
# forbidmask  is a subset of mask, and that if  allmaxes=false  then
# forbidmask  is the empty set. 
#
# The variables n,  A,  names,  allmaxes,  allsubs,  partialcolour, 
# weights,  weightvectors,  weighted,  zeroonevectorweighted,  dovector,  
# and  HasLargerEntry are global.
# The parameter  mask  may be changed by this function, and if 
# allmaxes=true  then  forbidmask  may be changed by this function.
#
local k,active,activemask,a,b,c,col,verticesremoved,i,j,ans,ans1,kk,ll,mm,
      vertices,nactive,nactivevector,wt,wtvector,cw,cwsum,endconsider,nadj,
      doposition,minptr;

activemask:=DifferenceBlist(mask,forbidmask);
active:=ListBlist([1..n],activemask);
IsSSortedList(active);
k:=Sum(kvector);
if k=0 or (k<0 and active=[]) then
   if allmaxes and SizeBlist(mask)>0 then
      # We are only looking for maximal complete subgraphs, 
      # but here the complete subgraph of size 0 is *not* maximal.
      return [];
   else 
      # allmaxes=false or there are no vertices
      return [[]];
   fi;
fi;
nactive:=Sum(weights{names{active}});
if nactive<k then 
   # in particular, if nactive=0 then
   return [];
fi;
nactivevector:=ShallowCopy(Sum(weightvectors{names{active}}));
# (ShallowCopy since the value of nactivevecter may be changed)
if HasLargerEntry(kvector,nactivevector) then
   return [];
fi;
# now we have  nactive>0,  and either  k<0  or  nactive >= k > 0.
vertices:=ListBlist([1..n],mask);
IsSSortedList(vertices);
repeat
   nadj := [];  # nadj[j] will record the number of active vertices adjacent
                # to  active[j].
   verticesremoved := false;
   for j in [1..Length(active)] do
      i:=active[j];
      b:=IntersectionBlist(activemask,A[i]);
      nadj[j]:=SizeBlist(b);
      if k>=0 then
         if weighted then
	    ll:=Sum(weights{ListBlist(names,b)});
         else
	    ll:=nadj[j];
         fi;
         wt:=weights[names[i]];
         wtvector:=weightvectors[names[i]];
         mm:=HasLargerEntry(wtvector,kvector); 
         if ll+wt<k or (mm and (not allmaxes)) then
            # eliminate vertex i  
            verticesremoved:=true;
            mask[i]:=false;
            forbidmask[i]:=false;  
            activemask[i]:=false;
            nactive:=nactive-wt;
            AddRowVector(nactivevector,wtvector,-1);
            if HasLargerEntry(kvector,nactivevector) then
               return [];
            fi;
         elif mm then
            # allmaxes=true so we forbid vertex i, but don't eliminate it 
            verticesremoved:=true;
            forbidmask[i]:=true;
            activemask[i]:=false;
            nactive:=nactive-wt;
            AddRowVector(nactivevector,wtvector,-1);
            if HasLargerEntry(kvector,nactivevector) then
               return [];
            fi;
         fi;
      fi;
   od;
   if verticesremoved then
      # Update  active  and  vertices.
      # At this point we know that  nactive>=k>0, and that no entry 
      # of  kvector  is greater than the corresponding entry of  nactivevector. 
      active:=ListBlist([1..n],activemask);
      IsSSortedList(active);
      vertices:=ListBlist([1..n],mask);
      IsSSortedList(vertices);
   fi;
until not verticesremoved;
# At this point we know that  k<0  or  nactive>=k>0, and if  k>0,  that no 
# entry of  kvector  is greater than the corresponding entry of  nactivevector. 
if nactive=k and Length(active)=Length(vertices) then
   # k>0, no forbidden vertices, and we are down to a required solution
   return [names{active}];
fi;
kk:=Length(active)-1;
if ForAll(nadj,x->x=kk) then
   # The induced subgraph on the active vertices is a complete subgraph
   # with vertex-weight sum >= k  (we may have  k<0).
   if Length(vertices)>Length(active) and (k<0 or nactive=k) then
      # Possible solution, but at least one
      # vertex is forbidden (so also allmaxes=true).
      ll:=IntersectionBlist(IntersectionBlist(List(active,x->A[x])),mask);
      if SizeBlist(ll)=0 then
          # the complete subgraph induced on the active vertices is maximal
          return [names{active}];
      else
          # the complete subgraph induced on the active vertices is not maximal
          return [];
      fi;
   elif k<0 then
      # no forbidden vertices here
      if allmaxes or allsubs=0 then
         return [names{active}];
      else
          return Combinations(names{active});
      fi;
   else
      # k>0  and  nactive>k  here, and so each maximal complete 
      # subgraph of vertex-weight-sum  k  contains a forbidden vertex
      if allmaxes then 
         return [];
      else 
         if not weighted then 
            if allsubs=0 then
               return [names{active{[1..k]}}];
            else 
               return Combinations(names{active},k); 
            fi;
         fi;
      fi;
   fi;
fi;
#
# Now determine  doposition. 
#
if not zeroonevectorweighted then
   # Use the standard heuristic.
   doposition:=First(dovector,x->kvector[x]<>0);
else
   # The weight-vectors have dimension > 1 and 
   # all weight-vector entries are <= 1. 
   # Use the alternative heuristic.
   doposition:=0;
   for i in [1..Length(kvector)] do
      if kvector[i]<>0 then
         if doposition=0 or nactivevector[i]<nactivevector[doposition] then
            doposition:=i;
         fi;
      fi;
   od;
fi;
#
# Now order the vertices in active for processing.
#
endconsider:=Length(active);
#
# Begin by pushing active indices from which we do not need to search 
# beyond  endconsider. 
#
if (allmaxes and Length(kvector)=1) or Length(kvector)>1 then
   if Length(kvector)=1 then
      # allmaxes=true here
      mm:=Difference(vertices,active);
      if mm=[] then
         mm:=A[active[1]];
      else
         mm:=A[mm[1]];
      fi;
   fi;
   i:=1;
   while i<=endconsider do
      if (Length(kvector)=1 and mm[active[i]]) or (Length(kvector)>1 and 
        weightvectors[names[active[i]]][doposition]=0) then
         if i<endconsider then
            a:=active[endconsider];
            active[endconsider]:=active[i];
            active[i]:=a;
            nadj[i]:=nadj[endconsider];
         fi;
         endconsider:=endconsider-1;
      else
         i:=i+1;
      fi;
   od;
fi;
#
# Now order the elements in active{[1..endconsider]}, and the corresponding 
# elements of nadj.
#
for i in [1..endconsider] do
   minptr:=i;
   for j in [i+1..endconsider] do
      if nadj[j]<nadj[minptr] then
         minptr:=j;
      fi;
   od; 
   a:=active[i];
   active[i]:=active[minptr];
   active[minptr]:=a;
   a:=nadj[i];
   nadj[i]:=nadj[minptr];
   nadj[minptr]:=a;
   mm:=A[active[i]];
   for j in [i+1..endconsider] do
      if mm[active[j]] then
         nadj[j]:=nadj[j]-1;
      fi;
   od;
od;
if k>=0 and partialcolour then 
   # We do (perhaps partial) proper vertex-colouring.
   col:=[];
   cw:=[]; # cw[j] will record the largest weight (entry) in the doposition of 
           # (a weightvector of) a vertex having colour j
   cwsum:=0;
   mm:=0;  # max. colour used so far
   if Length(kvector)>1 then
      ll:=endconsider;
   else
      ll:=Length(active);
   fi;
   for i in Reversed([1..ll]) do  # col[i] := colour of active[i]  
      c:=BlistList([1..mm+1],[]);
      b:=A[active[i]];
      for j in [i+1..ll] do
         if b[active[j]] then
            c[col[j]]:=true;
         fi;
      od;
      j:=1;
      while c[j] do
         j:=j+1;
      od;
      col[i]:=j;
      wt:=weightvectors[names[active[i]]][doposition];
      if j>mm then
         mm:=j;
         cwsum:=cwsum+wt;
         cw[mm]:=wt;
      elif cw[j]<wt then
         cwsum:=cwsum+(wt-cw[j]);
         cw[j]:=wt;
      fi;
      if cwsum>=kvector[doposition] then
         # stop colouring      
         if endconsider>i then
            endconsider:=i;
         fi;
         break;
      fi;
   od;
   if cwsum < kvector[doposition] then 
      # there is no solution 
      return [];
   fi;
fi;
if k<0 and (not allmaxes) then
   ans:=[[]];
   if allsubs=0 then
      return ans;
   fi;
else
   ans:=[];
fi;
for i in active{[1..endconsider]} do
   wtvector:=weightvectors[names[i]];
   ans1:=CompleteSubgraphsSearch1(IntersectionBlist(mask,A[i]),
                 kvector-wtvector,
                 IntersectionBlist(forbidmask,A[i]));
   if Length(ans1)>0 then
      for a in ans1 do
         Add(a,names[i]);
         Add(ans,a);
      od;
      if allsubs=0 then
         return ans;
      fi;
   fi;
   AddRowVector(nactivevector,wtvector,-1);
   if HasLargerEntry(kvector,nactivevector) then
      break;
   fi;
   if allmaxes then 
      forbidmask[i]:=true;
   else
      mask[i]:=false;
   fi;
od;
return ans;
end;

#
# begin  CompleteSubgraphsSearch
#
k:=Sum(kvector);
n:=gamma.order;
if k=0 or (k<0 and n=Length(forbidden)) then
   if allmaxes and n>0 then
      # We are only looking for maximal complete subgraphs, 
      # but here the complete subgraph of size 0 is *not* maximal.
      return [];
   else 
      # allmaxes=false or there are no vertices 
      return [[]];
   fi;
fi;
names:=gamma.names;
active:=Filtered([1..n],x->not (names[x] in forbidden));
IsSSortedList(active);
nactive:=Sum(weights{names{active}});
if nactive<k then 
   # in particular, if nactive=0 then
   return [];
fi;
nactivevector:=ShallowCopy(Sum(weightvectors{names{active}}));
# (ShallowCopy since the value of nactivevecter may be changed)
if HasLargerEntry(kvector,nactivevector) then
   return [];
fi;
# now k<0 or nactive >= k > 0.
G:=gamma.group;
if IsTrivial(G) or ((not weighted) and Size(G)<=smallorder1) then
   # Use the specialized function  CompleteSubgraphsSearch1, 
   # which works as if the group associated to the graph is trivial. 
   if (not allmaxes) and forbidden<>[] then 
      # strip out the forbidden vertices.
      gamma:=InducedSubgraph(gamma,active,G);
      n:=gamma.order;
      names:=gamma.names;
      active:=[1..n];
   fi;
   A:=List([1..n],i->BlistList([1..n],Adjacency(gamma,i)));
   # So now  A  is the bit-adjacency-matrix of  gamma.
   ans1:=CompleteSubgraphsSearch1(BlistList([1..n],[1..n]), kvector,
            BlistList([1..n],Difference([1..n],active)));
   Unbind(A); # A is no longer needed
   if Length(ans1)<=1 or IsTrivial(gamma.group) then
      # no isomorph rejection is required
      return ans1;
   fi;
   # Otherwise, perform isomorph rejection using explicit orbits
   # (even if  allsubs=1).
   # First, set up a translation vector  W  from vertex-names 
   # to vertices of  gamma.
   W:=[];
   for i in [1..Length(names)] do 
      W[names[i]]:=i; 
   od;
   ans1:=List(ans1,x->Set(W{x}));
   ans1:=List(Orbits(gamma.group,ans1,OnSets),x->names{x[1]});
   return ans1;
fi;
#
# Now handle the general case.
#
J:=Filtered([1..Length(gamma.representatives)],
            x->gamma.representatives[x] in active);
IsSSortedList(J);
nadj:=[]; # nadj[i]  will store the number of active vertices adjacent 
          # to  gamma.representatives[J[i]]
verticesremoved:=false;
for i in [1..Length(J)] do
   rep:=gamma.representatives[J[i]];
   a:=gamma.adjacencies[J[i]];
   if forbidden<>[] then
      a:=Filtered(a,x->not (names[x] in forbidden)); 
   fi;
   nadj[i]:=Length(a);
   if k>=0 then
      if weighted then
         ll:=Sum(weights{names{a}});
      else
         ll:=nadj[i];
      fi;
      if ll+weights[names[rep]] < k
            or HasLargerEntry(weightvectors[names[rep]],kvector) then  
         # forbid the vertex-orbit containing rep 
         verticesremoved:=true;
         UniteSet(forbidden,names{Orbit(G,rep)});
      fi;
   fi;
od;
if verticesremoved then
   return CompleteSubgraphsSearch(gamma,kvector,sofar,forbidden);
fi;
# At this point,  active  is the set of non-forbidden vertices,
# and  k<0  or  nactive>=k>0.  Moreover, if  k>0,  then no
# entry of  kvector  is greater than the corresponding entry of  nactivevector. 
if nactive=k and (not allmaxes or forbidden=[]) then
   # k>0  and we are down to a complete graph on active 
   # vertices which forms a required solution.
   return [names{active}];
fi;
kk:=Length(active)-1;
if ForAll(nadj,x->x=kk) then
   # The induced subgraph on the active vertices is a complete subgraph
   # with vertex-weight sum >= k (we may have  k<0).
   if allmaxes then
      if k>=0 and nactive>k then
         # any maximal complete solution subgraph must contain 
         # a forbidden vertex
         return [];
      else 
         # k<0 or nactivevector=kvector.
         # We now check whether any forbidden vertex in 
         # gamma.representatives  is joined to all active vertices. 
         for i in Difference([1..Length(gamma.representatives)],J) do
            if IsSubset(gamma.adjacencies[i],active) then
               # Each required maximal complete subgraph contains a 
               # forbidden vertex.  
               return [];
            fi; 
         od;
         # At this point we know that the complete subgraph induced on the 
         # active vertices is maximal.
         return [names{active}];
      fi;
   fi;
   # at this point, allmaxes=false and (nactive>k or k<0).
   if allsubs=0 then 
      if k<0 then 
         return [names{active}];
      elif not weighted then
         return [names{active{[1..k]}}];
      fi;
   fi;
fi;
if allsubs=2 then
   # set up translation vector  W  from vertex-names to vertices (of gamma).
   W:=[];
   for i in [1..Length(names)] do 
      W[names[i]]:=i; 
   od;
fi;
# next initialize ans
if k<0 and (not allmaxes) then
   ans:=[[]];
   if allsubs=0 then
      return ans;
   fi;
else
   ans:=[];
fi;
if allmaxes and Length(kvector)=1 then
   mm:=First(Difference([1..Length(gamma.adjacencies)],J),
               x->IsFixedPoint(gamma.group,gamma.representatives[x])); 
   if mm<>fail then
       mm:=gamma.adjacencies[mm];
   else 
      mm:=First(J,x->IsFixedPoint(gamma.group,gamma.representatives[x])); 
      if mm<>fail then
         mm:=gamma.adjacencies[mm];
      else
         mm:=[];
      fi;
   fi;
   if mm<>[] then
      #
      # We will not search from any vertex in the  gamma.group-invariant 
      # set  mm,  since Length(kvector)=1,  allmaxes=true,  and  mm  is the 
      # adjacency of a single (heuristically chosen) vertex, and so
      # no solution can consist entirely of elements of  mm. 
      # 
      ll:=Filtered([1..Length(J)],x->not (gamma.representatives[J[x]] in mm));
      J:=J{ll};
      nadj:=nadj{ll};
   fi;
else
   mm:=[];
fi;
indorbwtsum:=0;
doposition:=First(dovector,x->kvector[x]<>0); 
for j in [1..Length(J)] do 
   i:=1;
   for kk in [2..Length(J)] do 
      if nadj[kk]<nadj[i] then
         i:=kk;
      fi;
   od;
   nadj[i]:=n;
   rep:=gamma.representatives[J[i]];
   adj:=gamma.adjacencies[J[i]];
   orb:=SSortedList(Orbit(G,rep));
   #  wt  will record the maximum entry in doposition of a vector in  orb.
   if Length(kvector)=1 then
      wt:=weightvectors[names[rep]][1]; 
      # wt>0 and does not depend on the orbit rep.
   else
      wt:=0;
      for a in orb do 
         kk:=weightvectors[names[a]][doposition];
         if kk>wt or (a=rep and kk=wt) then
            # these statements are executed at least once
            wt:=kk;
            b:=a;
         fi;
      od;
      if b<>rep then
         rep:=b;
         adj:=Adjacency(gamma,rep);
       fi;
   fi;
   if wt<>0 then
      # 
      # We consider searching for solutions containing  rep.
      # 
      # However, if  k>=0  and  mm=[]  we shall not search from any 
      # vertex in certain independent orbits, such that the sum  
      # of the  wt's  for these orbits is less than  kvector[doposition].
      # This is because no solution can be made from vertices coming 
      # only from these independent orbits, together with those orbits
      # with  wt=0. (Note that if  wt=0  then we must have  
      # Length(kvector)>1,  and so  k>=0,  mm=[].)
      # 
      if k>=0 and Length(mm)=0 and indorbwtsum+wt < kvector[doposition] 
                           and Length(Intersection(orb,adj))=0 then
         #
         # Ignore the independent (active) orbit  orb,  and add  wt  to the 
         # running total  indorbwtsum.
         #
         indorbwtsum:=indorbwtsum+wt;
      else 
         newsofar:=Union(sofar,[names[rep]]);
         if allsubs<>2 and (not allmaxes) then
            # We can strip out all forbidden vertices since in this case:
            #   (1) we are stabilizing each successive sofar with 
            #       (a constituent image of) a subgroup of 
            #       the previous stabilizer of sofar, and
            #       so the set of non-forbidden vertices will *always* be 
            #       invariant under further  gamma.groups;  
            #   (2) we need not check whether our complete subgraphs are maximal
            delta:=InducedSubgraph(gamma,
                                   Filtered(adj,x->not (names[x] in forbidden)),
                                   ProbablyStabilizer(gamma.group,rep));
            ans1:=CompleteSubgraphsSearch(delta,
                     kvector-weightvectors[names[rep]],newsofar,[]);
         elif allsubs<>2 then
            delta:=InducedSubgraph(gamma,adj,
                                   ProbablyStabilizer(gamma.group,rep));
            ans1:=CompleteSubgraphsSearch(delta,
                     kvector-weightvectors[names[rep]],newsofar,
                     Intersection(delta.names,forbidden));
         else
            # allsubs=2 
            delta:=InducedSubgraph(gamma,adj,Stabilizer(gamma.group,rep));
            HH:=Stabilizer(originalG,newsofar,OnSets);
            if not IsFixedPoint(HH,names[rep]) then 
               H:=Action(HH,names{adj},OnPoints);
               delta:=NewGroupGraph(H,delta);
               ans1:=CompleteSubgraphsSearch(delta,
                        kvector-weightvectors[names[rep]],newsofar,
                        Intersection(delta.names,Union(Orbits(HH,forbidden))));
            else
               ans1:=CompleteSubgraphsSearch(delta,
                        kvector-weightvectors[names[rep]],newsofar,
                        Intersection(delta.names,forbidden));
            fi; 
         fi;
         if Length(ans1)>0 then
            for a in ans1 do
               Add(a,names[rep]);
            od;
            if allsubs=0 then
                return ans1;
            fi;
            if allsubs<>2 or Length(ans1)=1 or IsFixedPoint(gamma.group,rep) then
               # isomorph rejection is unnecessary
               for a in ans1 do
                  Add(ans,a);
               od;
            elif Size(gamma.group)<=smallorder then
               # perform isomorph rejection using explicit orbits
               ans1:=List(ans1,x->Set(W{x}));
               ans1:=List(Orbits(gamma.group,ans1,OnSets),x->names{x[1]});
               for a in ans1 do
                  Add(ans,a);
               od;
            else
               # perform isomorph rejection using SmallestImageSet
               ans2:=List(ans1,x->
	                SmallestImageSet(gamma.group,Set(W{x}))); 
	       SortParallel(ans2,ans1);		
	       Add(ans,ans1[1]);
               for a in [2..Length(ans1)] do
		  if ans2[a]<>ans2[a-1] then
                     # new  gamma.group  orbit representative
                     Add(ans,ans1[a]);
                  fi;
               od;
            fi;
         fi;
         if j < Length(J) then
            AddRowVector(nactivevector,Sum(weightvectors{names{orb}}),-1);
            if HasLargerEntry(kvector,nactivevector) then
               break;
            fi;
            for kk in [1..Length(J)] do
               if nadj[kk]<>n then
                  adj:=gamma.adjacencies[J[kk]];
                  for a in orb do
                     if a in adj then 
                        nadj[kk]:=nadj[kk]-1;
                     fi;
                  od;
               fi;
            od;
            UniteSet(forbidden,names{orb});
         fi;
      fi;
   fi;
od;
return ans;
end;

#
# begin  CompleteSubgraphsMain
#
# Minimal checking of parameters since this function should only 
# be called internally or by experts.
#
if not (IsGraph(gamma) and IsList(kvector) and IsInt(allsubs) and
        IsBool(allmaxes) and IsBool(partialcolour) and
        IsList(weightvectors) and IsList(dovector)) then
   Error("usage: CompleteSubgraphsMain( <Graph>, <List>, <Int>, <Bool>, <Bool>, <List>, <List>)");
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
smallorder:=8; # to try to optimize isomorph rejection. 
# If allsubs=2, we perform isomorph rejection via explicit orbits 
# on cliques when the group associated with the graph under 
# consideration has  order<=smallorder. 
smallorder1:=8; # to try to optimise when  CompleteSubgraphsSearch1  
# is used for unweighted graphs. 
# In  CompleteSubgraphsSearch,  if the graph under consideration 
# is unweighted, and the group associated with that graph 
# has  order <= smallorder1,  then we use  CompleteSubgraphsSearch1
# and perform isomorph rejection via explicit orbits on cliques.
#
originalgamma:=gamma;
originalG:=gamma.group;
gamma:=ShallowCopy(gamma);
gamma.names:=Immutable([1..gamma.order]);
k:=Sum(kvector);
if k<0 then
   # We are computing maximal complete subgraphs (not of given size).
   if Length(kvector)<>1 then
      Error("cannot have Sum(<kvector>)<0 if Length(<kvector>)<>1");
   fi;
   includingallmaximalreps:=(allsubs in [1,2]); 
   partialcolour:=false;
   weightvectors:=List([1..gamma.order],x->[1]);
   weights:=ListWithIdenticalEntries(gamma.order,1); 
   weighted:=false;
   dovector:=[1];
else
   includingallmaximalreps:=false; 
   weights:=List(weightvectors,x->Sum(x));
   weighted:=not ForAll(weightvectors,x->x=[1]);
   if weighted and ForAll(weights,x->x=weights[1]) 
               and k mod weights[1] <> 0 then
      # there is no solution
      return [];
   fi; 
fi;
if not weighted and k>=0 then
   if IsBound(gamma.maximumClique) then
      cliquenumber:=Length(gamma.maximumClique);
      if k>cliquenumber then
         # gamma has no clique of size k.
         return [];
      fi; 
      if allsubs=0 and (not allmaxes or k=cliquenumber) then
         return [gamma.maximumClique{[1..k]}]; 
      fi; 
   elif IsBound(gamma.minimumVertexColouring) then
      chromaticnumber:=Length(Set(gamma.minimumVertexColouring));
      if k>chromaticnumber then
         # gamma has no clique of size k.
         return [];
      fi; 
   fi;
   if allsubs=0 and IsBound(gamma.autGroup) and
      not IsCompleteGraph(gamma) and not IsNullGraph(gamma) and
      Size(gamma.group)<Size(gamma.autGroup) then
      # Make use of the full automorphism group of  gamma.
      gamma:=NewGroupGraph(gamma.autGroup,gamma);
   fi;
fi;
zeroonevectorweighted:=weightvectors<>[] and Length(weightvectors[1])>1 and
   ForAll(weightvectors,x->ForAll(x,y->y<=1));
K:=CompleteSubgraphsSearch(gamma,kvector,[],[]);
for clique in K do
   Sort(clique); 
od;
Sort(K);
if not weighted and not IsBound(originalgamma.maximumClique) then 
   if includingallmaximalreps then 
      #  K  contains a maximum clique of  originalgamma.
      cliquenumber:=Maximum(List(K,Length));
      originalgamma.maximumClique:=Immutable(First(K,x->Length(x)=cliquenumber));
   elif IsBound(originalgamma.minimumVertexColouring) then 
      chromaticnumber:=Length(Set(originalgamma.minimumVertexColouring));
      if ForAny(K,x->Length(x)=chromaticnumber) then
         cliquenumber:=chromaticnumber;
         originalgamma.maximumClique:=Immutable(First(K,x->Length(x)=cliquenumber));
      fi;
   fi;
fi; 
return K;
end);

BindGlobal("CompleteSubgraphsOfGivenSize",function(arg)
#
# Interface to CompleteSubgraphsMain.
#
local gamma,k,kvector,allsubs,allmaxes,partialcolour,weights,weightvectors;
if not (Length(arg) in [2..6]) then
   Error("must have 2, 3, 4, 5 or 6 parameters");
fi;
gamma:=arg[1];
k:=arg[2];
if IsBound(arg[3]) then
   allsubs:=arg[3];
else
   allsubs:=1;
fi;
if allsubs=false then
   allsubs:=0;
elif allsubs=true then
   allsubs:=1;
elif not (allsubs in [0,1,2]) then
   Error("<arg[3]> must be boolean or in [0,1,2]");
fi;
if IsBound(arg[4]) then
   allmaxes:=arg[4];
else 
   allmaxes:=false;
fi;
if IsBound(arg[5]) then
   partialcolour:=arg[5];
else 
   partialcolour:=true;
fi;
if IsRat(partialcolour) then
   partialcolour:=true;  # for backward compatibility
fi;  
if not (IsGraph(gamma) and (IsInt(k) or IsList(k)) and IsBool(allmaxes) 
                       and IsBool(partialcolour)
        and (not IsBound(arg[6]) or IsList(arg[6])) ) then    
   Error("usage: CompleteSubgraphsOfGivenSize( <Graph>, <Int> or <List>",
	"[, <Int> or <Bool> [, <Bool> [, <Bool> or <Rat> [, <List> ]]]] )");
fi;
if IsInt(k) then
   if k<0 then 
      Error("<k> must be non-negative");
   fi;
   kvector:=[k];
else
   kvector:=k;
   if Length(kvector)=0 or ForAny(kvector,x->x<0) then 
      Error("<kvector> must be a non-empty list of non-negative integers");
   fi;
fi;
if not IsSimpleGraph(gamma) then 
   Error("<gamma> not a simple graph");
fi;
if IsBound(arg[6]) then
   weights:=arg[6];
   if Length(weights)<>gamma.order then
      Error("<weights> not of length <gamma>.order");
   fi;
   if Length(weights)>0 and IsInt(weights[1]) then
      if ForAny(weights,w->not IsInt(w) or w<=0) then
          Error("all weights must be positive integers (or all lists)");
      fi;
      if ForAny(GeneratorsOfGroup(gamma.group),g->
   	     ForAny([1..gamma.order],i->weights[i^g]<>weights[i])) then
         Error("integer vertex-weights not <gamma>.group-invariant");
      fi;
      weightvectors:=List(weights,x->[x]);
   else
      weightvectors:=weights;
   fi;
else
   weightvectors:=List([1..gamma.order],x->[1]);
fi;
if ForAny(weightvectors,x->Length(x)<>Length(kvector)) then
   Error("All weight-vectors must be the same length as <kvector>");
fi;
return CompleteSubgraphsMain(gamma,kvector,allsubs,allmaxes,partialcolour,
                             weightvectors,[1..Length(kvector)]);
end);

BindGlobal("CliquesOfGivenSize",CompleteSubgraphsOfGivenSize);

BindGlobal("CompleteSubgraphs",function(arg)
#
# Interface to  CompleteSubgraphsMain.
#
local gamma,k,allsubs,allmaxes;
if not (Length(arg) in [1..3]) then
   Error("must have 1, 2 or 3 parameters");
fi;
gamma:=arg[1];
if IsBound(arg[2]) then
   k:=arg[2];
else
   k:=-1;
fi;
if IsBound(arg[3]) then
   allsubs:=arg[3];
else
   allsubs:=1;
fi;
if allsubs=false then
   allsubs:=0;
elif allsubs=true then
   allsubs:=1;
elif not (allsubs in [0,1,2]) then
   Error("<arg[3]> must be boolean or in [0,1,2]");
fi;
if k<0 then
   allmaxes:=true; 
else
   allmaxes:=false; 
fi;
if not (IsGraph(gamma) and IsInt(k)) then
   Error("usage: CompleteSubgraphs( <Graph> [,<Int> [,<Int> or <Bool> ]] )");
fi;
if not IsSimpleGraph(gamma) then 
   Error("<gamma> not a simple graph");
fi;
return CompleteSubgraphsMain(gamma,[k],allsubs,allmaxes,
         true,List([1..gamma.order],x->[1]),[1]); 
end);

BindGlobal("Cliques",CompleteSubgraphs);

BindGlobal("CayleyGraph",function(arg)
#
# Given a group  G=arg[1]  and a list  gens=arg[2]  of 
# generators for  G,  this function constructs a Cayley graph 
# for  G  w.r.t.  the generators  gens.  The generating list  
# arg[2]  is optional, and if omitted, then we take  
# gens:=GeneratorsOfGroup(G).  
# The boolean argument  arg[3]  is also optional, and if true (the default)
# then the returned graph is undirected (as if  gens  was closed 
# under inversion whether or not it is). 
#
# The Cayley graph  caygraph  which is returned is defined as follows:
# the vertices (actually the vertex-names) of  caygraph  are the elements
# of  G;  if  arg[3]=true  (the default) then vertices  x,y  are 
# joined by an edge iff there is a  g  in  gens with  y=g*x  
# or  y=g^-1*x;  if  arg[3]=false  then vertices  x,y  are 
# joined by an edge iff there is a  g  in  gens with  y=g*x.  
# 
# *Note* It is not checked whether  G = <gens>.  However, even if  G  
# is not generated by  gens,  the function still works as described 
# above (as long as  gens  is contained in  G), but returns a 
# "Cayley graph" which is not connected.
# 
local G,gens,elms,undirected,caygraph;
G:=arg[1];
if IsBound(arg[2]) then 
   gens:=arg[2];
else
   gens:=GeneratorsOfGroup(G);
fi;
if IsBound(arg[3]) then
   undirected:=arg[3];
else
   undirected:=true;
fi;
if not(IsGroup(G) and IsList(gens) and IsBool(undirected)) then
   Error("usage: CayleyGraph( <Group> [, <List> [, <Bool> ]] )");
fi;
elms:=AsList(G);
SetSize(G,Length(elms));
if not IsSSortedList(gens) then
   gens:=SSortedList(gens);
fi;
caygraph := Graph(G,elms,OnRight,
		  function(x,y) return y*x^-1 in gens; end,true);
#
# Note that  caygraph.group  comes from the right regular action of
# G  as a group of automorphisms of the Cayley graph constructed.  
#
SetSize(caygraph.group,caygraph.order);
if undirected then
  caygraph:=UnderlyingGraph(caygraph);
fi;
return caygraph;
end);

BindGlobal("SwitchedGraph",function(arg)
#
# Returns the switched graph  delta  of graph  gamma=arg[1],  
# w.r.t to vertex list (or singleton vertex)  V=arg[2].
#
# The returned graph  delta  has vertex-set the same as  gamma. 
# If vertices  x,y  of  delta  are both in  V  or both not in
# V,  then  [x,y]  is an edge of  delta  iff  [x,y]  is an edge
# of  gamma;  otherwise  [x,y]  is an edge of delta  iff  [x,y]
# is not an edge of  gamma.
# 
# If  arg[3]  is bound then it is assumed to be a subgroup 
# of  Aut(gamma)  stabilizing  V  setwise.
#
local gamma,delta,n,V,W,H,A,i;
gamma:=arg[1];
V:=arg[2];
if IsInt(V) then
   V:=[V];
fi;
if not IsGraph(gamma) or not IsList(V) then 
   Error("usage: SwitchedGraph( <Graph>, <Int> or <List>, [,<PermGroup>] )");
fi;
n:=gamma.order;
V:=SSortedList(V);
if not IsSubset([1..n],V) then 
   Error("<V> must be a subset of [1..<n>]");
fi;
if Length(V) > n/2 then
   V:=Difference([1..n],V);
fi;
if V=[] then 
   return CopyGraph(gamma);
fi;
if IsBound(arg[3]) then 
   H:=arg[3];
elif Length(V)=1 then
   H:=ProbablyStabilizer(gamma.group,V[1]);
else
   H:=Group([],());
fi;
if not IsPermGroup(H) then
   Error("usage: SwitchedGraph( <Graph>, <Int> or <List>, [, <PermGroup>] )");
fi;
delta:=NullGraph(H,n);
if IsBound(gamma.isSimple) then
   delta.isSimple:=gamma.isSimple;
else
   Unbind(delta.isSimple);
fi;
if IsBound(gamma.names) then
   delta.names:=Immutable(gamma.names);
fi;
W:=Difference([1..n],V);
for i in [1..Length(delta.representatives)] do
   A:=Adjacency(gamma,delta.representatives[i]);
   if delta.representatives[i] in V then
      delta.adjacencies[i]:=Union(Intersection(A,V),Difference(W,A));
   else
      delta.adjacencies[i]:=Union(Intersection(A,W),Difference(V,A));
   fi;
od;
return delta;
end);

BindGlobal("VertexTransitiveDRGs",function(gpin)
#
# If  gpin  is a permutation group G, then it must be transitive 
# and non-trivial, and we set coladjmats:=OrbitalDigraphColadjMats(gpin).
#
# Otherwise, we take  coladjmats:=gpin,  which must be a list of collapsed
# adjacency matrices for the orbital digraphs of a non-trivial 
# transitive permutation group  G  (on a set V say), collapsed 
# w.r.t. a fixed point-stabilizer (such as the list of matrices produced
# by  OrbitalDigraphColadjMats ).
#
# In either case, this function returns a record (called  result),
# which gives information on  G.
# The most important component of this record is the list
# orbitalCombinations,  whose elements give the combinations of
# the (indices of) the G-orbitals whose union gives the edge-set
# of a distance-regular graph with vertex-set  V.
# The component  intersectionArrays  gives the corresponding
# intersection arrays. The component  degree  is the degree of
# the permutation group  G,  rank  is its (permutation) rank, and
# isPrimitive  is true if  G  is primitive, and false otherwise.
# It is assumed that the orbital/suborbit indexing used is the same
# as that for the rows (and columns) of each of the matrices and
# also for the indexing of the matrices themselves, with the trivial
# suborbit first, so that, in particular,  coladjmats[1]  must be an
# identity matrix.
#
# The techniques used in this function are described in:
# Praeger and Soicher, "Low Rank Representations and Graphs for
# Sporadic Groups", CUP, Cambridge, 1997.
#
# May 2018: The efficiency of this function has been improved for 
# the case when not all G-orbitals are self-paired.
#
local coladjmats,include,i,j,M,C,rank,comb,loc,sum,degree,prim,result;
if not IsList(gpin) and not IsPermGroup(gpin) then
   Error("usage: VertexTransitiveDRGs( <List> or <PermGroup> )");
fi;
if IsPermGroup(gpin) then
   # Remark: OrbitalDigraphColadjMats will check if  gpin  is transitive,
   # so we do not do this here.
   if IsTrivial(gpin) then
      Error("Input group must must be non-trivial,");
   fi;
   coladjmats := OrbitalDigraphColadjMats(gpin);
else
   coladjmats := gpin;
fi;
if Length(coladjmats)<2 or not IsMatrix(coladjmats[1])
      or not IsInt(coladjmats[1][1][1]) then
   Error("<coladjmats> must be a list of integer matrices of length > 1,");
fi;
rank:=Length(coladjmats);
prim:=true;
for i in [2..rank] do
   if LocalInfoMat(coladjmats[i],1).localDiameter=(-1) then
      # The i-th orbital graph is not (strongly) connected.
      prim:=false;
      break;
   fi;
od;
degree:=Sum(Sum(List(coladjmats,a->a[1])));
result:=rec(degree:=degree, rank:=rank, isPrimitive:=prim,
            orbitalCombinations:=[], intersectionArrays:=[]);
include:=ListWithIdenticalEntries(rank,true);
include[1]:=false; # corresponding to the trivial orbital
M:=[];
for i in [1..rank] do
   if coladjmats[i][1][i]=0 then
      Error("Error in <coladjmats>[",i,"]");
   fi;
   if not include[i] then
      continue;
   fi;
   if coladjmats[i][i][1]=1 then
      # The orbital corresponding to coladjmats[i] is self-paired.
      Add(M,[i]);
   else
      j:=First([i+1..rank],x->include[x] and coladjmats[x][i][1]=1);
      # The orbital corresponding to coladjmats[i] is paired with
      # the orbital corresponding to coladjmats[j].
      Add(M,[i,j]);
      include[j]:=false;
   fi;
od;
for comb in Combinations(M) do
   if comb<>[] then
      C:=Union(comb);
      sum:=Sum(coladjmats{C});
      loc:=LocalInfoMat(sum,1);
      if loc.localDiameter <> -1 and not (-1 in Flat(loc.localParameters)) then
         # We've found a DRG.
         Add(result.orbitalCombinations,C);
         Add(result.intersectionArrays,loc.localParameters);
      fi;
   fi;
od;
return result;
end);

DeclareOperation("MaximumClique",[IsRecord]);
InstallMethod(MaximumClique,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns a clique  C  of maximum size of the simple graph  gamma, 
# and if  gamma.maximumClique  is unbound, sets  gamma.maximumClique 
# to be an immutable copy of  C. 
#
local G,delta,C,CC,lower,upper,mid; 
if not IsGraph(gamma) then 
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
if IsBound(gamma.maximumClique) then
   return ShallowCopy(gamma.maximumClique);
fi; 
if gamma.order=0 then
   C:=[];
   gamma.maximumClique:=Immutable(C); 
   return C; 
elif IsNullGraph(gamma) then
   C:=[1];
   gamma.maximumClique:=Immutable(C); 
   return C; 
elif IsCompleteGraph(gamma) then
   C:=[1..gamma.order];
   gamma.maximumClique:=Immutable(C); 
   return C; 
fi;
G:=AutomorphismGroup(gamma); 
if G=gamma.group then 
   delta:=gamma;
else
  delta:=NewGroupGraph(G,gamma); # to take full advantage of Aut(gamma)
fi;
lower:=1;
C:=[1]; 
if IsBound(gamma.minimumVertexColouring) then
   upper:=Length(Set(gamma.minimumVertexColouring))+1; 
else
   upper:=Maximum(VertexDegrees(delta))+2; 
fi;
while upper-lower>1 do 
   # Loop invariant: lower and upper are integers,
   # max clique size is in [lower,upper),
   # and C is a clique of size lower.
   mid:=Int((lower+upper)/2); 
   CC:=CompleteSubgraphsOfGivenSize(delta,mid,0); 
   if CC=[] then
      upper:=mid;
   else
      lower:=mid; 
      C:=CC[1];
   fi;
od;
gamma.maximumClique:=Immutable(C); 
return C;
end); 

DeclareOperation("MaximumCompleteSubgraph",[IsRecord]);
InstallMethod(MaximumCompleteSubgraph,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Implements alternative name for  MaximumClique.
#
if not IsGraph(gamma) then 
   TryNextMethod();
fi;
return MaximumClique(gamma);
end); 

DeclareAttribute("CliqueNumber",IsRecord);
InstallMethod(CliqueNumber,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Returns the size of a largest clique of the simple graph  gamma.
#
if not IsGraph(gamma) then 
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
return Length(MaximumClique(gamma));
end); 

BindGlobal("GRAPE_ExactSetCover",function(arg)
#
# Let  n:=arg[3]  be a non-negative integer, 
# let  G:=arg[1]  be a permutation group on  [1..n],  
# let  blocks:=arg[2]  be a list of non-empty subsets of  [1..n],
# and let  H:=arg[4]  (default: Group(()))  be a subgroup of  G.
#
# Then this function returns an H-invariant exact set-cover
# of  [1..n]  by elements from  Concatenation(Orbits(G,blocks,OnSets)),  
# if such a cover exists, and returns  `fail'  otherwise. 
# 
local G,blocks,n,H,gamma,hom,i,j,wts,K,N;
if not Length(arg) in [3,4] then
   Error("GRAPE_ExactSetCover should have 3 or 4 arguments");
fi;
n:=arg[3];
if not IsInt(n) and n>=0 then
   Error("<n> must be a non-negative integer");
fi;
G:=arg[1];
if not (IsPermGroup(G) and LargestMovedPoint(G)<=n) then
   Error("<G> must be a permutation group on [1..<n>]"); 
fi;
blocks:=arg[2];
if not IsList(blocks) and 
   ForAll(blocks,x->IsSet(x) and x<>[] and IsSubset([1..n],x)) then
   Error("<blocks> must be a list of non-empty subsets of [1..<n>]");
fi;
if IsBound(arg[4]) then
   H:=arg[4];
   if not IsSubgroup(G,H) then
      Error("<H> must be a subgroup of <G>");
   fi;
else
   H:=Group(());
fi;
if n=0 then
   return [];
elif blocks=[] then
   return fail;
fi;
gamma:=Graph(G,blocks,OnSets,function(x,y) return Intersection(x,y)=[]; end);
if Size(H)>1 then
   hom:=ActionHomomorphism(G,VertexNames(gamma),OnSets);
   N:=Image(hom,Normalizer(G,H));
   H:=Image(hom,H);
   gamma:=CollapsedCompleteOrbitsGraph(H,gamma,N);
else
   AssignVertexNames(gamma,List(VertexNames(gamma),x->[x]));
fi;
wts:=[];
for i in [1..gamma.order] do
   wts[i]:=ListWithIdenticalEntries(n,0); 
   for j in Concatenation(gamma.names[i]) do 
      wts[i][j]:=1;
   od;
od;
K:=CompleteSubgraphsOfGivenSize(gamma,ListWithIdenticalEntries(n,1),
   0,true,true,wts);
if K=[] then
   return fail;
else
   return Union(gamma.names{K[1]});
fi;
end);
      
BindGlobal("GRAPE_CliqueCovering",function(arg)
#
# Let  gamma:=arg[1]  be a simple graph and let  k:=arg[2]  be 
# a non-negative integer.
#
# This function returns a covering of  gamma  by at most  k  pairwise disjoint
# non-empty cliques if such a covering exists, and otherwise returns  fail.  
#
# A returned covering is given as a set of sets, forming a partition 
# of the vertex set of  gamma  into at most  k  non-empty cliques. 
# 
# If  arg[3]  is bound then it must be a non-negative integer, such that
# no clique in any clique k-covering of  gamma  has size > arg[3]. 
#
local gamma,k,m,cliquecovering,delta,cov,C,c,exhaustive_search,smallorder;

cliquecovering := function(delta,k,start,olddelta)
#
# Let  delta  be a simple graph, and let  k  be a non-negative integer.
# 
# Suppose that the boolean variable  exhaustive_search 
# (global to this function) has value  true.  Then this function 
# returns a covering of  delta  by at most  k  pairwise disjoint 
# non-empty cliques, if such a covering exists; otherwise  fail  is returned.  
#
# Now suppose that  exhaustive_search = false.  Then  start  must 
# be an integer, and this function tries to find a covering of
# delta  by at most  k  pairwise disjoint non-empty cliques of size <= start, 
# and returns such a covering if found.  If no such covering is found 
# (although one may still exist), then  fail  is returned. 
#
# If  start  is an integer, then it must be non-negative, we let m=start,
# ignore olddelta, and it is assumed that there is *no* partition of 
# the vertices of delta into <=k cliques such that some part has size > m.  
#
# Now suppose  start  is not an integer. Then oldelta must be a simple graph, 
# start  must be a clique of olddelta, delta is the subgraph induced on the 
# set of vertices of olddelta not in start, and we let m=Length(start). 
# Furthermore, it is assumed that there is *no* partition of the vertices 
# of olddelta into  <=k+1  cliques such that some part has size > m  or 
# some part P has size m and P<start (in the usual lex-order on GAP sets). 
# 
# For this function (regardless of the value of  exhaustive_search), 
# a returned covering is given as a list of lists of vertex-names of  delta. 
# (These lists are not necessarily sorted, but contain no repeated elements.) 
# In addition, we assume that on the initial call to this recursive function 
# that m is an integer and delta.names=[1..delta.order]. 
#
local m,C,CC,c,d,t,s,cov,newdelta,K,A,translation,i,exclude,eps,dtranslation; 
if IsInt(start) then
   m:=start;
else
   m:=Length(start); 
fi; 
if delta.order=0 then
   return [];
elif m*k<delta.order then
   # in particular, if m=0 or k=0
   return fail;
elif k=1 then 
   if IsCompleteGraph(delta) then
      return [ShallowCopy(delta.names)];
   else
      return fail;
   fi;
fi;
if not IsInt(start) then
   translation:=Difference(Vertices(olddelta),start);
   # translation[i] is the vertex in olddelta corresponding to 
   # the i-th vertex in delta. 
fi;
s:=m;
while s*k>=delta.order do 
   if exhaustive_search then
      if s=m and (not IsInt(start)) then
         # Some vertices of delta may be excluded from 
         # the returned maximal cliques of size s. 
         exclude:=[];
         for i in [1..delta.order] do
            if translation[i]>start[1] then
               break;
            fi;
            Add(exclude,i);
         od;
         if Length(exclude)>0 then
            exclude:=Union(Orbits(delta.group,exclude));
            dtranslation:=Difference(Vertices(delta),exclude);
            eps:=InducedSubgraph(delta,dtranslation,delta.group);
            # dtranslation[i] is the vertex in delta corresponding to 
            # the i-th vertex in eps. 
            C:=CompleteSubgraphsOfGivenSize(eps,s,2,true);
            C:=Set(C,c->dtranslation{c});
            C:=Filtered(C,c->
               Length(Intersection(List(c,x->Adjacency(delta,x))))=0);
            # Each element of C must be a maximal clique of delta.
         else
            C:=CompleteSubgraphsOfGivenSize(delta,s,2,true);
         fi;
      else
         if IsTrivial(delta.group) then 
            C:=CompleteSubgraphsOfGivenSize(delta,s,1,true);
         else 
            C:=CompleteSubgraphsOfGivenSize(delta,s,2,true);
         fi;
      fi;
      if not IsInt(start) then
         CC:=[];
         for c in C do 
            t:=translation{c}; 
            d:=Union(t,Filtered(start,x->IsSubset(Adjacency(olddelta,x),t)));
            if Length(d)>m then
               continue;
            fi; 
            if Length(d)=m and 
               (d<start or SmallestImageSet(olddelta.group,d)<start) then 
               continue;
            fi;
            Add(CC,c);
         od;
         C:=CC;
      fi;
      if s*k=delta.order and Size(delta.group)<=smallorder then
         # Use exact cover.
         K:=GRAPE_ExactSetCover(delta.group,C,delta.order);
         if K=fail then
            return fail;
         else
            return List(K,x->delta.names{x});
         fi;
      elif not IsTrivial(delta.group) then
         C:=Set(C,x->SmallestImageSet(delta.group,x)); 
      fi;
   else
      C:=CompleteSubgraphsOfGivenSize(delta,s,0,true);
   fi;
   for c in C do
      A:=Difference(Vertices(delta),c);
      newdelta:=InducedSubgraph(delta,A,Stabilizer(delta.group,c,OnSets));
      if exhaustive_search then 
         cov:=cliquecovering(newdelta,k-1,c,delta); 
      else
         cov:=cliquecovering(newdelta,k-1,s,0); 
      fi; 
      if cov<>fail then 
         return Concatenation(cov,[delta.names{c}]);
      elif not exhaustive_search then
         # We give up.
         return fail;
      fi;
   od;
   s:=s-1;
od;
return fail;
end;

if not (Length(arg) in [2,3]) then
   Error("must have 2 or 3 arguments");
fi;
gamma:=arg[1];
k:=arg[2];
if not IsGraph(gamma) or not IsInt(k) then 
   Error("usage: GRAPE_CliqueCovering( <Graph>, <Int> [, <Int> ] )");
elif not IsSimpleGraph(gamma) then
   Error("<arg[1]> must be a simple graph");
elif k<0 then
   Error("<arg[2]> must be non-negative"); 
fi;
if IsBound(arg[3]) then
   m:=arg[3];
   if not IsInt(m) then 
      Error("usage: GRAPE_CliqueCovering( <Graph>, <Int> [, <Int> ] )");
   elif m<0 then
      Error("<arg[3]> must be non-negative"); 
   fi;
   if k*m<gamma.order then
      return fail;
   fi;
fi;
if gamma.order=0 then
   return [];
elif k=0 then
   return fail;
fi;
if IsCompleteGraph(gamma) then
   return [[1..gamma.order]];
elif k=1 then
   return fail;
fi;
C:=Bicomponents(ComplementGraph(gamma));
if C<>[] then
   # The complement of the non-complete graph  gamma  is bipartite.
   return Set(List(C,Set));
elif k=2 then
   return fail;
fi;
delta:=NewGroupGraph(AutomorphismGroup(gamma),gamma); 
delta.names:=Immutable([1..delta.order]); 
if not IsBound(m) then
   m:=CliqueNumber(delta);
fi;
# 
smallorder:=24; # To try to optimise when exact cover is used. 
# smallorder  can be given any positive integer value, but a value
# in the range 8 to 120 seems to work well. 
#
exhaustive_search:=false;
cov:=cliquecovering(delta,k,m,0); 
if cov=fail then
   exhaustive_search:=true;
   cov:=cliquecovering(delta,k,m,0); 
   if cov=fail then
      return fail;
   fi;
fi;
for c in cov do
   Sort(c);
od;
Sort(cov);
return cov;
end);

BindGlobal("IsVertexColouring",function(arg)
#
# Let  gamma:=arg[1]  be a simple graph, let  C:=arg[2]  be a list of 
# positive integers of length  OrderGraph(gamma),  and let  k:=arg[3]  
# be a non-negative integer (default: Length(C)).  
#
# Then this function returns  true  if  C  is a vertex k-colouring 
# of  gamma,  and returns  false  if not.  (The list  C  is a vertex 
# k-colouring of  gamma  iff  C[v]<>C[w]  whenever  [v,w]  is an edge of  
# gamma,  and the number of distinct elements of  C  (the colours) is
# at most  k.  A proper vertex-colouring of  gamma  is the same thing 
# as a vertex OrderGraph(gamma)-colouring of  gamma.)
# 
local gamma,C,k,v,w;  
if not Length(arg) in [2,3] then
   Error("IsVertexColouring should have 2 or 3 arguments");
fi;
gamma:=arg[1];
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
C:=arg[2];
if not (IsList(C) and Length(C)=OrderGraph(gamma) and ForAll(C,IsPosInt)) then
   Error("<C> must be a list of length OrderGraph(<gamma>) of positive integers"); 
fi;
if IsBound(arg[3]) then
   k:=arg[3];
   if not (IsInt(k) and k>=0) then
      Error("<k> must be a non-negative integer"); 
   fi;
else
   k:=OrderGraph(gamma);
fi;
if Length(Set(C))>k then
   # too many colours
   return false;
fi; 
for v in Vertices(gamma) do
   for w in Adjacency(gamma,v) do
      if v<w then
         if C[v]=C[w] then
            # The adjacent vertices v and w have the same colour.
            return false;
         fi;
      fi;
   od;
od;
return true;
end); 

BindGlobal("VertexColouring",function(arg)
#
# Let  gamma:=arg[1]  be a simple graph. Then this function returns 
# a proper vertex-colouring of  gamma.  A proper vertex-colouring of  
# gamma  is given as a dense list  C  of length  gamma.order,
# such that  Set(C)=[1..Maximum(C)],  where  C[i]  is the   
# "colour" of the i-th vertex, and  C[i]<>C[j]  if  [i,j]  is an
# edge of  gamma.  
# 
# If  k:=arg[2]  is bound, then it must be a non-negative integer,
# and a colouring using at most  k  colours is returned, or `fail'
# iff no such colouring exists.
#
# If  arg[2]  is unbound then a greedy algorithm only is used. 
#
# If  arg[3]  is bound then it must be a non-negative integer, such that
# there is no monochromatic set of vertices of size > arg[3]  in  
# any vertex k-colouring of  gamma. 
#
local gamma,k,m,i,j,g,c,C,orb,a,adj,adjs,adjcolours,maxcolour,im,gens,cov;
if not (Length(arg) in [1,2,3]) then
   Error("must have 1, 2 or 3 arguments");
fi;
gamma:=arg[1];
if not IsGraph(gamma) then 
   Error("usage: VertexColouring( <Graph> [, <Int> [, <Int> ]] )");
elif not IsSimpleGraph(gamma) then
   Error("<arg[1]> not a simple graph");
fi;
if IsBound(arg[2]) then
   k:=arg[2];
   if not IsInt(k) then 
      Error("usage: VertexColouring( <Graph> [, <Int> [, <Int> ]] )");
   elif k<0 then
      Error("<arg[2]> must be non-negative"); 
   fi;
else 
   k:=gamma.order;
fi;
if IsBound(arg[3]) then
   m:=arg[3];
   if not IsInt(m) then 
      Error("usage: VertexColouring( <Graph> [, <Int> [, <Int> ]] )");
   elif m<0 then
      Error("<arg[3]> must be non-negative"); 
   fi;
   if k*m<gamma.order then
      return fail;
   fi;
fi;
if IsBound(gamma.minimumVertexColouring) then
   C:=gamma.minimumVertexColouring;
   if k<Length(Set(C)) then  # k < chromatic number of gamma
      return fail;
   else 
      return ShallowCopy(C);
   fi;
elif IsBound(gamma.maximumClique) then
   if k<Length(gamma.maximumClique) then
      return fail;
   fi;
fi;
if gamma.order=0 then
   return [];
fi;
#
# First try a greedy algorithm.
#
C:=ListWithIdenticalEntries(gamma.order,0);
maxcolour:=0;
gens:=GeneratorsOfGroup(gamma.group);
for i in [1..Length(gamma.representatives)] do
   orb:=[gamma.representatives[i]];
   adjs:=[];
   adj:=gamma.adjacencies[i];
   adjs[orb[1]]:=adj;
   # colour vertex  orb[1]
   adjcolours:=BlistList([1..maxcolour+1],[]);
   for a in adj do
      if C[a]>0 then
	 adjcolours[C[a]]:=true;
      fi;
   od;
   c:=1;
   while adjcolours[c] do
      c:=c+1;
   od;
   if c>maxcolour then
      maxcolour:=c;
      if maxcolour>k then
         break;
      fi;
   fi;
   C[orb[1]]:=c;
   for j in orb do 
      for g in gens do
	 im:=j^g;
	 if C[im]=0 then 
	    Add(orb,im);
	    adj:=OnTuples(adjs[j],g);
	    adjs[im]:=adj;
	    # colour vertex  im
	    adjcolours:=BlistList([1..maxcolour+1],[]);
	    for a in adj do
	       if C[a]>0 then
		  adjcolours[C[a]]:=true;
	       fi;
	    od;
	    c:=1;
	    while adjcolours[c] do
	       c:=c+1;
	    od;
	    if c>maxcolour then
	       maxcolour:=c;
               if maxcolour>k then
                  break;
               fi;
	    fi;
	    C[im]:=c;
	 fi; 
      od; 
      Unbind(adjs[j]);
      if maxcolour>k then
         break;
      fi; 
   od;
   if maxcolour>k then
      break;
   fi; 
od;
if maxcolour<=k then 
   #  C  is a vertex k-colouring of  gamma.
   if not IsVertexColouring(gamma,C,k) then
      # This should not happen!
      Error("BUG: <C> should be a (proper) vertex <k>-colouring of <gamma>");
   fi;
   if IsBound(gamma.maximumClique) and Length(gamma.maximumClique)=Length(Set(C)) then
      #  C  is a minimum vertex-colouring of  gamma.
      gamma.minimumVertexColouring:=Immutable(C);
   fi;
   return C;
fi;
# Otherwise, we need to work harder. 
if IsBound(arg[3]) then 
   cov:=GRAPE_CliqueCovering(ComplementGraph(gamma),k,arg[3]);
else
   cov:=GRAPE_CliqueCovering(ComplementGraph(gamma),k);
fi;
if cov=fail then
   return fail;
fi;
# Otherwise, we make C into a k-colouring from cov. 
C:=[];
for i in [1..Length(cov)] do
   for j in cov[i] do
      C[j]:=i;
   od;
od;
if not IsVertexColouring(gamma,C,k) then
   # This should not happen!
   Error("BUG: <C> should be a (proper) vertex <k>-colouring of <gamma>");
fi;
if IsBound(gamma.maximumClique) and Length(gamma.maximumClique)=Length(Set(C)) then
   #  C  is a minimum vertex-colouring of  gamma.
   gamma.minimumVertexColouring:=Immutable(C);
fi;
return C;   
end);

BindGlobal("GRAPE_MinimumCliqueCovering",function(gamma)
#
# Let  gamma  be a simple graph. Then this function returns a clique covering
# of  gamma  of minimum size. The returned covering is given as a set of sets, 
# forming a partition of the vertex set of  gamma  into non-empty cliques. 
# 
local C,CC,lwr,lower,upper,mid,i,delta; 
if not IsGraph(gamma) then 
   Error("usage: GRAPE_MinimumCliqueCovering( <Graph> )");
elif not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
if gamma.order=0 then
   return [];
elif IsCompleteGraph(gamma) then
   return [[1..gamma.order]];
fi;
delta:=ComplementGraph(gamma); 
C:=GRAPE_NumbersToSets(VertexColouring(delta)); 
Sort(C); 
# Now  C  is a partition of the vertex set of  gamma  into  
# Length(C)  cliques. 
if Length(C)=2 then 
   return C;
fi;
upper:=Length(C);
if Maximum(VertexDegrees(gamma))<(gamma.order-1)/2 then
   lwr:=gamma.order/CliqueNumber(gamma);
   if IsInt(lwr) then
      lower:=lwr-1;
   else
      lower:=Int(lwr);
   fi;
else
   lower:=CliqueNumber(delta)-1;
fi;
while upper-lower>1 do 
   # Loop invariant: lower and upper are integers,
   # The clique covering number of gamma is in (lower,upper]
   # and C is a clique covering of size upper.
   mid:=Int((lower+upper)/2); 
   CC:=GRAPE_CliqueCovering(gamma,mid);
   if CC=fail then
      lower:=mid;
   else
      upper:=Length(CC); # which is <= mid and > lower. 
      C:=CC;
   fi;
od;
return C;
end); 

DeclareOperation("MinimumVertexColouring",[IsRecord]);
InstallMethod(MinimumVertexColouring,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Let  gamma  be a simple graph. Then this function returns a proper vertex-
# colouring  C  of  gamma,  using as few colours as possible, and if
# gamma.minimumVertexColouring  is unbound, sets  gamma.minimumVertexColouring 
# to be an immutable copy of  C. 
#
# A proper vertex-colouring of  gamma  is given as a list  C  of 
# length  gamma.order  of positive integers, such that  C[i]  is the 
# "colour" of the i-th vertex, and  C[i]<>C[j]  if  [i,j]  is an edge 
# of  gamma.  
#
local cov,C,i,j;  
if not IsGraph(gamma) then 
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
if IsBound(gamma.minimumVertexColouring) then
   return ShallowCopy(gamma.minimumVertexColouring); 
fi;     
cov:=GRAPE_MinimumCliqueCovering(ComplementGraph(gamma)); 
C:=[];
for i in [1..Length(cov)] do
   for j in cov[i] do
      C[j]:=i;
   od;
od;
gamma.minimumVertexColouring:=Immutable(C); 
return C;
end);

DeclareAttribute("ChromaticNumber",IsRecord);
InstallMethod(ChromaticNumber,"for GRAPE graph",[IsRecord],0, 
function(gamma)
#
# Let  gamma  be a simple graph. Then this function returns the 
# chromatic number of  gamma,  that is, the minimum number of 
# colours needed to properly vertex-colour  gamma.
# 
if not IsGraph(gamma) then 
   TryNextMethod();
fi;
if not IsSimpleGraph(gamma) then
   Error("<gamma> must be a simple graph");
fi;
return Length(Set(MinimumVertexColouring(gamma)));
end); 

BindGlobal("IsGraphWithColourClasses",function(obj) 
return IsRecord(obj) and IsBound(obj.graph) and IsGraph(obj.graph) and IsBound(obj.colourClasses);
end);

BindGlobal("MonochromaticColourClasses",function(gamma) 
# Returns colour-classes list with all vertices having the same 
# colour for the vertices of the graph  gamma.
if not IsGraph(gamma) then
   Error("usage: MonochromaticColourClasses( <Graph> )"); 
fi;
if gamma.order=0 then 
   return [];
else
   return [[1..gamma.order]];
fi; 
end);

BindGlobal("CheckColourClasses",function(gamma,col) 
#
# Checks whether col  is a valid list of colour-classes for the 
# graph  gamma. 
#
if not (IsGraph(gamma) and IsList(col)) then
   Error("usage: CheckColourClasses( <Graph>, <List> )"); 
fi;
if not ForAll(col,x->IsSet(x) and x<>[]) then 
    Error("each colour-class must be a non-empty set");
fi;
if Union(col)<>[1..gamma.order] then
   Error("the union of the colour-classes is not equal to the vertex set of <gamma>"); 
fi; 
if Sum(List(col,Length))>gamma.order then
   Error("the colour-classes must be pairwise disjoint");
fi;
return;
end);

# Set up temporary directory for use with nauty/dreadnaut or bliss.
BindGlobal("GRAPE_nautytmpdir",DirectoryTemporary());
Add(GAPInfo.PostRestoreFuncs,function()
  MakeReadWriteGlobal("GRAPE_nautytmpdir");
  Unbind(GRAPE_nautytmpdir);
  BindGlobal("GRAPE_nautytmpdir",DirectoryTemporary());
end);

BindGlobal("PrintStreamNautyGraph",function(stream,gamma,col)
#
# Prints in dreadnaut graph format the graph  gamma  with 
# colour-classes  col  onto the given output stream  stream. 
#
  local i, j, issimple;
  issimple:=IsSimpleGraph(gamma);
  if issimple then
    # output gamma to dreadnaut as an undirected loopless graph
    PrintTo(stream,"$1n",gamma.order,"g\n");
  else
    # treat as a directed graph
    PrintTo(stream,"d\n$1n",gamma.order,"g\n");
  fi;
  for i in [1..gamma.order] do 
    for j in Adjacency(gamma,i) do 
      if (not issimple) or i<j then
        AppendTo(stream,j,"\n");
      fi;
    od;
    if i<gamma.order then
      AppendTo(stream,";\n");
    else
      AppendTo(stream,".\n");
    fi;
  od;
  AppendTo(stream,"f[\n");
  if col<>MonochromaticColourClasses(gamma) then 
    for i in [1..Length(col)] do
      for j in [1..Length(col[i])] do
        AppendTo(stream,col[i][j]);
	if j<Length(col[i]) then
	  AppendTo(stream,",");
	elif i<Length(col) then
	  AppendTo(stream,"|");
	fi;
	AppendTo(stream,"\n");
      od;
    od;
  fi;
  AppendTo(stream,"]\n");
end);

BindGlobal("ReadOutputNauty",function(file)
#
# Reads the output of a run of dreadnaut/nauty, given in the file  file.
# Returns  [sgens,bas],  where  sgens  is a strong generating set
# for the automorphism group wrt base  bas. 
# Function originally written by Alexander Hulpke.
# 
  local f, bas, sgens, l, s, p, i, deg, processperm, pi;

  processperm:=function()
    if Length(pi)=0 then 
      # no permutation to process
      return; 
    fi;
    if deg=fail then
      # set degree
      deg:=Length(pi);
    else
      if Length(pi)<>deg then
        Error("degree discrepancy in nauty output! ",Length(pi)," vs ",deg);
      fi;
    fi;
    Add(sgens,PermList(pi));
    pi:=[];
  end;

  deg:=fail;
  f:=InputTextFile(file);
  if f=fail then
    Error("cannot find output produced by dreadnaut in file ",file);
  fi;
  bas:=[];
  sgens:=[];
  pi:=[];
  while not IsEndOfStream(f) do
    l:=ReadLine(f);
    if l<>fail then
      l:=Chomp(l);
      if Length(l)>4 and l{[1..5]}="level" then
        # new base point 
	processperm();
        s:=SplitString(l,";");
	s:=s[Length(s)-1]; # should be " x...x fixed"
	if Length(s)<5 or s{[Length(s)-4..Length(s)]}<>"fixed" then
	  Error("unparsable line ",l);
	fi;
	s:=s{[1..Length(s)-6]};
	while s[1]=' ' do
	  s:=s{[2..Length(s)]};
	od;
	Add(bas,Int(s));
      elif ForAll(l,x->x in CHARS_DIGITS or x=' ') then
	if Length(pi)>0 and (Length(l)<5 or l{[1..4]}<>"    ") then
	  processperm(); # permutation starts -- clean out old
	fi;
	s:=SplitString(l,[]," ");
	Append(pi,List(s,Int));
      elif deg<>fail then
	processperm();
      fi;

    fi;
  od;
  CloseStream(f);
  bas:=Reversed(bas);
  sgens:=Set(sgens);
  return [sgens,bas];
end);

BindGlobal("ReadCanonNauty",function(file)
#
# Reads the canonical labelling output of a run of dreadnaut/nauty,
# given in the file  file, and returns this canonical labelling. 
# Function originally written by Alexander Hulpke.
#
  local f, can, l, deg, s, i;
  f:=InputTextFile(file);
  if f=fail then
    Error("cannot find canonization produced by dreadnaut in file ",file);
  fi;
  can:=[];
  # first line: degree
  l:=ReadLine(f);
  l:=Chomp(l);
  deg:=Int(l);
  # now read in until you have enough integers for the permutation -- the
  # rest is the relabelled graph and can be discarded
  while Length(can)<deg do
    l:=ReadLine(f);
    l:=Chomp(l);
    s:=SplitString(l,' ');
    for i in s do
      if Length(i)>0 and Length(can)<deg then
        Add(can,Int(i));
      fi;
    od;
  od;
  CloseStream(f);
  return PermList(can);
end);

BindGlobal("SetAutGroupCanonicalLabellingNauty",function(gr,setcanon) 
#
# Sets the  autGroup  component (if not already bound) and the
# canonicalLabelling  component (if not already bound and setcanon=true) 
# of the graph or graph with colour-classes  gr.
# Uses the nauty system. 
#
  local gamma,col,ftmp1,ftmp2,fdre,fg,status,
        ftmp1_stream,fdre_stream,out_stream,gp;
  if IsBound(gr.canonicalLabelling) then
    setcanon:=false;
  fi;
  if IsBound(gr.autGroup) and not setcanon then
    return;
  fi;
  if IsGraph(gr) then
    gamma:=gr;
    col:=MonochromaticColourClasses(gamma);
  else
    gamma:=gr.graph;
    col:=gr.colourClasses;
    CheckColourClasses(gamma,col);
  fi;
  if gamma.order<=1 then 
    if not IsBound(gr.autGroup) then
      gr.autGroup:=Group([],());
    fi;
    if setcanon then
      gr.canonicalLabelling:=();
    fi;
    return;
  fi;

  ftmp1:=Filename(GRAPE_nautytmpdir,"ftmp1");
  ftmp2:=Filename(GRAPE_nautytmpdir,"ftmp2");
  
  # In principle redundant, but a failed call might have left files sitting
  # -- just throw out what will be overwritten anyhow.
  RemoveFile(ftmp1);
  RemoveFile(ftmp2);

  if GRAPE_DREADNAUT_INPUT_USE_STRING then
    # Use a string for fdre_stream.
    fdre:="";
    fdre_stream:=OutputTextString(fdre,false);
  else
    # Use a file for fdre_stream.
    fdre:=Filename(GRAPE_nautytmpdir,"fdre");
    RemoveFile(fdre);  # in case there is a leftover file
    fdre_stream:=OutputTextFile(fdre,false);
    if fdre_stream=fail then
       Error("error opening output text stream using file ", fdre); 
    fi;
  fi;
  SetPrintFormattingStatus(fdre_stream,false);
  PrintStreamNautyGraph(fdre_stream,gamma,col);
  if not setcanon then
    # only the automorphism group is computed
    if IsSimpleGraph(gamma) then
      AppendTo( fdre_stream, "> ", ftmp1, " p,xq\n" );
    else
      AppendTo( fdre_stream, "> ", ftmp1, " p,*=13,k=1 10,xq\n" );
    fi;
  else
    if IsSimpleGraph(gamma) then
      AppendTo( fdre_stream, "> ", ftmp1, " p,cx\n>> ", ftmp2, " bq\n" );
    else
      AppendTo( fdre_stream, "> ", ftmp1, " p,*=13,k=1 10,cx\n>> ", ftmp2,
               " bq\n" );
    fi;
  fi;
  CloseStream(fdre_stream);
  PrintTo(ftmp2,gamma.order,"\n"); # initialize ftmp2
  if GRAPE_DREADNAUT_INPUT_USE_STRING then
    fdre_stream := InputTextString(fdre);
  else 
    fdre_stream := InputTextFile(fdre);
    if fdre_stream=fail then
       Error("error opening input text stream using file ", fdre); 
    fi;
  fi;
  out_stream := OutputTextUser(); 
  status := GRAPE_Exec(GRAPE_DREADNAUT_EXE, [], fdre_stream, out_stream);
  CloseStream(fdre_stream);
  CloseStream(out_stream); 
  if status<>0 then
    Error("exit code ",status," returned by dreadnaut executable;\n",
       "returned results may be wrong");
  fi;

  if not IsBound(gr.autGroup) then 
    fg:=ReadOutputNauty(ftmp1);
    # fg[1]=stronggens, fg[2]=base
    gp:=GroupWithGenerators(fg[1],());
    SetStabChainMutable(gp,StabChainBaseStrongGenerators(fg[2],fg[1],()));
    gr.autGroup:=gp;
  fi;
  if setcanon then
    gr.canonicalLabelling:=ReadCanonNauty(ftmp2);
  fi;

  RemoveFile(ftmp1);
  RemoveFile(ftmp2);
  if not GRAPE_DREADNAUT_INPUT_USE_STRING then
    RemoveFile(fdre);
  fi;
end);

BindGlobal("PrintStreamBlissGraph",function(stream,gamma,col)
#
# Prints in bliss graph format the graph  gamma  with 
# colour-classes  col  onto the given output stream  stream. 
# Procedure originally written by Jerry James. 
#
  local i, j, nedges, issimple;
  issimple:=IsSimpleGraph(gamma);
  if IsRegularGraph(gamma) and gamma.order > 0 then
    nedges := gamma.order*Length(Adjacency(gamma,1)); 
  else
    nedges:=0;
    for i in [1..gamma.order] do
      nedges := nedges + Length(Adjacency(gamma,i));
    od;
  fi;
  # nedges = no. of directed edges of gamma. 
  if issimple then
    nedges := nedges/2;
    # so in this case, nedges = no. of undirected edges of gamma.
  fi;
  PrintTo(stream,"p edge ",gamma.order," ",nedges,"\n");
  if col<>MonochromaticColourClasses(gamma) then 
    for i in [1..Length(col)] do
      for j in [1..Length(col[i])] do
        AppendTo(stream, "n ", col[i][j], " ", i, "\n");
      od;
    od;
  fi;
  for i in [1..gamma.order] do 
    for j in Adjacency(gamma,i) do
      if (not issimple) or i<j then
        AppendTo(stream, "e ", i, " ", j, "\n");
      fi;
    od;
  od;
end);

BindGlobal("ReadOutputBliss",function(file,setcanon)
#
# Reads the output of a run of bliss given in the file  file.
# Returns  [gens,can],  where  gens  is a generating list
# for the automorphism group and  can  is the canonical labelling
# if  setcanon=true,  and  can=[]  if  setcanon=false. 
# Function originally written by Jerry James. 
# 
  local f, gens, l, i, pi, can;

  f:=InputTextFile(file);
  if f=fail then
    Error("cannot find output produced by bliss in file ",file);
  fi;
  gens:=[];
  can:=[];
  while not IsEndOfStream(f) do
    l:=ReadLine(f);
    if l<>fail then
      l:=Chomp(l);
      if Length(l)>11 and l{[1..11]}="Generator: " then
	pi:=EvalString(l{[12..Length(l)]});
	Add(gens,pi);
      elif setcanon and Length(l)>20 and l{[1..20]}="Canonical labeling: " then
	can:=InverseSameMutability(EvalString(l{[21..Length(l)]}));
      elif setcanon and Length(l)=20 and l{[1..20]}="Canonical labeling: " then
	can:=();
      fi;
    fi;
  od;
  CloseStream(f);
  return [gens,can];
end);

BindGlobal("SetAutGroupCanonicalLabellingBliss",function(gr,setcanon) 
#
# Sets the  autGroup  component (if not already bound) and the
# canonicalLabelling  component (if not already bound and setcanon=true) 
# of the graph or graph with colour-classes  gr.
# Uses the bliss system. 
#
  local gamma,col,ftmp,ftmp_stream,fdre,fg,fdre_stream,in_stream,
        arglist,status,gp;
  if IsBound(gr.canonicalLabelling) then
    setcanon:=false;
  fi;
  if IsBound(gr.autGroup) and not setcanon then
    return;
  fi;
  if IsGraph(gr) then
    gamma:=gr;
    col:=MonochromaticColourClasses(gamma);
  else
    gamma:=gr.graph;
    col:=gr.colourClasses;
    CheckColourClasses(gamma,col);
  fi;
  if gamma.order<=1 then 
    if not IsBound(gr.autGroup) then
      gr.autGroup:=Group([],());
    fi;
    if setcanon then
      gr.canonicalLabelling:=();
    fi;
    return;
  fi;

  fdre:=Filename(GRAPE_nautytmpdir,"fdre");
  ftmp:=Filename(GRAPE_nautytmpdir,"ftmp");
  
  # In principle redundant, but a failed call might have left files sitting
  # -- just throw out what will be overwritten anyhow.
  RemoveFile(fdre);
  RemoveFile(ftmp);

  fdre_stream:=OutputTextFile(fdre,false); 
  if fdre_stream=fail then
    Error("error opening output text stream using file ", fdre); 
  fi;
  SetPrintFormattingStatus(fdre_stream,false);
  PrintStreamBlissGraph(fdre_stream,gamma,col);
  CloseStream(fdre_stream);

  if not setcanon then
    # only the automorphism group is computed
    if IsSimpleGraph(gamma) then
      arglist:=[ fdre ];
    else
      arglist:=[ "-directed", fdre ];
    fi;
  else
    # compute the automorphism group and canonical labelling
    if IsSimpleGraph(gamma) then
      arglist:=[ "-can", fdre ];
    else
      arglist:=[ "-directed", "-can", fdre ];
    fi;
  fi;

  ftmp_stream:=OutputTextFile(ftmp,false);
  if ftmp_stream=fail then
    Error("error opening output text stream using file ", ftmp); 
  fi;
  SetPrintFormattingStatus(ftmp_stream,false);
  in_stream:=InputTextNone();
  status := GRAPE_Exec(GRAPE_BLISS_EXE, arglist, in_stream, ftmp_stream);
  CloseStream(in_stream); 
  CloseStream(ftmp_stream);
  if status<>0 then
    Error("exit code ",status," returned by bliss executable;\n",
       "returned results may be wrong");
  fi;

  fg:=ReadOutputBliss(ftmp,setcanon);
  # fg[1]=gens for the aut group, 
  # fg[2]=canonical labelling if setcanon=true, else the empty list
  if not IsBound(gr.autGroup) then 
    gp:=GroupWithGenerators(fg[1],());
    gr.autGroup:=gp;
  fi;
  if setcanon then
    gr.canonicalLabelling:=fg[2];
  fi;

  RemoveFile(fdre);
  RemoveFile(ftmp);

end);

BindGlobal("SetAutGroupCanonicalLabelling",function(arg) 
#
# Let  gr:=arg[1]  and  setcanon:=arg[2]  (default: true).
# Sets the  autGroup  component (if not already bound) and the
# canonicalLabelling  component (if not already bound and setcanon=true) 
# of the graph or graph with colour-classes  gr.
#
  local gr,setcanon;
  gr:=arg[1];
  if IsBound(arg[2]) then
    setcanon:=arg[2];
  else
    setcanon:=true;
  fi;
  if not (IsGraph(gr) or IsGraphWithColourClasses(gr)) or not IsBool(setcanon) then
    Error("usage: SetAutGroupCanonicalLabelling( <Graph> or <GraphWithColourClasses> [, <Bool> ] )");
  fi;
  if GRAPE_NAUTY then
    SetAutGroupCanonicalLabellingNauty(gr, setcanon);
  else
    SetAutGroupCanonicalLabellingBliss(gr, setcanon);
  fi;
end);

BindGlobal("AutGroupGraph",function(arg) 
#
# Let  gr:=arg[1]  be a graph or a graph with colour-classes.
#
# If arg[2] is unbound (the usual case) then this function returns 
# the automorphism group of  gr  (making use of B.McKay's 
# dreadnaut, nauty  programs).
# 
# If arg[2] is bound then  gr  must be a graph and arg[2] is 
# a vertex-colouring (not necessarily proper) for  gr
# (i.e. a list of colour-classes for the vertices of gr),
# in which case the subgroup of Aut(gr) preserving this colouring 
# is returned instead of the full automorphism group.
# (Here a vertex-colouring is a list of sets, forming an ordered
# partition of the vertices. The set for the last colour may be omitted.)
#
local gr,gamma,col;
if IsBound(arg[2]) then
   if not IsGraph(arg[1]) or not IsList(arg[2]) then 
      Error("usage: AutGroupGraph( <Graph> [, <List> ] ) or AutGroupGraph( <GraphWithColourClasses> )");
   fi;
   gamma:=arg[1];
   col:=arg[2];
   if Union(col)<>[1..gamma.order] then
      # for backward compatibility
      Add(col,Difference([1..gamma.order],Union(col)));
   fi; 
   CheckColourClasses(gamma,col);
   if col<>MonochromaticColourClasses(gamma) then 
      gr:=rec(graph:=gamma,colourClasses:=col);
   else
      gr:=gamma;
   fi;
else 
   gr:=arg[1];
fi;
# Now deal with <gr>.
if not (IsGraph(gr) or IsGraphWithColourClasses(gr)) then 
   Error("usage: AutGroupGraph( <Graph> [, <List> ] ) or AutGroupGraph( <GraphWithColourClasses> )");
fi;
SetAutGroupCanonicalLabelling(gr,false);
return gr.autGroup;
end);

InstallOtherMethod(AutomorphismGroup,"for graph or graph with colour-classes",
   [IsRecord],100,
function(gamma)
if not IsGraph(gamma) and not IsGraphWithColourClasses(gamma) then
  TryNextMethod();
fi;
return AutGroupGraph(gamma);
end);

BindGlobal("IsGraphIsomorphism",function(gr1,gr2,perm)
#
# Let  gr1  and   gr2  both be graphs or both be graphs with colour-classes.  
# Then this function returns  true  if  perm  is an
# isomorphism from  gr1  to  gr2  (and  false  if not).
# 
local gamma1,gamma2,col1,col2,u,g,i,j,x,aut1,aut2,adj1,adj2,reps1;
if not ((IsGraph(gr1) and IsGraph(gr2)) or (IsGraphWithColourClasses(gr1) and IsGraphWithColourClasses(gr2))) or not IsPerm(perm) then
   Error("usage: IsGraphIsomorphism( <Graph>, <Graph>, <Perm> ) or IsGraphIsomorphism( <GraphWithColourClasses>, <GraphWithColourClasses>, <Perm> )"); 
fi;
if IsGraphWithColourClasses(gr1) then 
   # both gr1 and gr2 are graphs with colour-classes
   gamma1:=gr1.graph;
   col1:=gr1.colourClasses;
   CheckColourClasses(gamma1,col1);
   gamma2:=gr2.graph;
   col2:=gr2.colourClasses;
   CheckColourClasses(gamma2,col2);
else
   # both gr1 and gr2 are graphs 
   gamma1:=gr1;
   col1:=MonochromaticColourClasses(gamma1);
   gamma2:=gr2;
   col2:=MonochromaticColourClasses(gamma2);
fi;
if LargestMovedPoint(perm)>gamma1.order then
   return false;
fi;
if gamma1.order<>gamma2.order or
   VertexDegrees(gamma1) <> VertexDegrees(gamma2) then 
   # the graphs are not isomorphic
   return false; 
elif gamma1.order<=1 then
   return true;
fi;
if List(col1,c->OnSets(c,perm))<>col2 then
   return false;
fi;
# So now we know that perm takes col1 to col2.
if IsBound(gamma1.autGroup) and IsBound(gamma2.autGroup) then
   aut1:=gamma1.autGroup;
   aut2:=gamma2.autGroup;
   if aut1^perm<>aut2 then
      return false;
   fi;
else
   aut1:=Group(());
   aut2:=Group(());
fi;
# So now, either aut1 and aut2 are both trivial, or they
# are the full aut groups of gamma1 and gamma2, respectively,
# and  aut1^perm=aut2.
reps1:=GRAPE_OrbitNumbers(aut1,gamma1.order).representatives;
for i in reps1 do 
   adj1:=Adjacency(gamma1,i);
   adj2:=Adjacency(gamma2,i^perm);
   if OnSets(adj1,perm)<>adj2 then
      return false;
   fi;
od;
return true;
end);

BindGlobal("GraphIsomorphism",function(arg)
#
# Let  gr1:=arg[1]  and  gr2:=arg[2]  both be graphs or both be 
# graphs with colour-classes.  
# Then this function returns an isomorphism from  gr1  to  gr2,  if
# gr1  and  gr2  are isomorphic,  else returns  fail.
# 
# The optional boolean parameter  firstunbindcanon=arg[3]  determines
# whether or not the  canonicalLabelling  components of both gr1 and
# gr2  are first made unbound before proceeding.   If
# firstunbindcanon=true (the default, safe and possibly slower option) 
# then these components are first unbound.  
# If  firstunbindcanon=false,  then an old canonical labelling
# is used when it exists.  However, canonical labellings can depend on
# the version of nauty, the version of GRAPE, certain settings
# of nauty, and the compiler and computer used.  
# Thus, if firstunbindcanon=false, the user must be 
# sure that any canonicalLabelling component(s) which may already 
# exist for gr1 or gr2 were created in exactly the same 
# environment in which the user is presently computing. 
#
local gr1,gr2,gamma1,gamma2,col1,col2,firstunbindcanon,g,i,j,x;
gr1:=arg[1];
gr2:=arg[2];
if IsBound(arg[3]) then
   firstunbindcanon:=arg[3];
else
   firstunbindcanon:=true;
fi;
if not ((IsGraph(gr1) and IsGraph(gr2)) or (IsGraphWithColourClasses(gr1) and IsGraphWithColourClasses(gr2))) or not IsBool(firstunbindcanon) then
   Error("usage: GraphIsomorphism( <Graph>, <Graph> [, <Bool>] ) or GraphIsomorphism( <GraphWithColourClasses>, <GraphWithColourClasses> [, <Bool>] )"); 
fi;
if IsGraphWithColourClasses(gr1) then 
   # both gr1 and gr2 are graphs with colour-classes
   gamma1:=gr1.graph;
   col1:=gr1.colourClasses;
   CheckColourClasses(gamma1,col1);
   gamma2:=gr2.graph;
   col2:=gr2.colourClasses;
   CheckColourClasses(gamma2,col2);
else
   # both gr1 and gr2 are graphs 
   gamma1:=gr1;
   col1:=MonochromaticColourClasses(gamma1);
   gamma2:=gr2;
   col2:=MonochromaticColourClasses(gamma2);
fi;
if firstunbindcanon then
  Unbind(gr1.canonicalLabelling);
  Unbind(gr2.canonicalLabelling);
fi;
if gamma1.order<>gamma2.order or
   VertexDegrees(gamma1) <> VertexDegrees(gamma2) then 
   # the graphs are not isomorphic 
   return fail; 
elif List(col1,Length)<>List(col2,Length) then
   # incompatible colourings
   return fail;
elif gamma1.order<=1 then
   return ();
fi;
SetAutGroupCanonicalLabelling(gr1,true);
SetAutGroupCanonicalLabelling(gr2,true);
x:=LeftQuotient(gr1.canonicalLabelling,gr2.canonicalLabelling);
if IsGraphIsomorphism(gr1,gr2,x) then
   return x;
else
   return fail;
fi;
end);

BindGlobal("IsIsomorphicGraph",function(arg)
#
# Let  gr1:=arg[1]  and  gr2:=arg[2]  both be graphs or both be 
# graphs with colour-classes.  
# Then this function returns true if  gr1  and  gr2  are isomorphic,
# else returns  false.
# 
# The optional boolean parameter  firstunbindcanon=arg[3]  determines
# whether or not the  canonicalLabelling  components of both gr1 and
# gr2  are first made unbound before proceeding.   If
# firstunbindcanon=true (the default, safe and possibly slower option) 
# then these components are first unbound.  
# If  firstunbindcanon=false,  then an old canonical labelling
# is used when it exists.  However, canonical labellings can depend on
# the version of nauty, the version of GRAPE, certain settings
# of nauty, and the compiler and computer used.  
# Thus, if firstunbindcanon=false, the user must be 
# sure that any canonicalLabelling component(s) which may already 
# exist for gr1 or gr2 were created in exactly the same 
# environment in which the user is presently computing. 
#
if Length(arg)=2 then
   return IsPerm(GraphIsomorphism(arg[1],arg[2]));
elif Length(arg)=3 then
   return IsPerm(GraphIsomorphism(arg[1],arg[2],arg[3]));
else
   Error("number of arguments must be 2 or 3");
fi;
end);

BindGlobal("GraphIsomorphismClassRepresentatives",function(arg)
#
# Given a list  L:=arg[1]  of graphs, or of graphs with colour-classes, 
# this function returns a list
# containing pairwise non-isomorphic elements of  L,  representing
# all the isomorphism classes of elements of  L. 
#
# The optional boolean parameter  firstunbindcanon=arg[2]  determines
# whether or not the  canonicalLabelling  components of all 
# the graphs in L are first made unbound before proceeding. 
# If firstunbindcanon=true (the default, safe and possibly slower option) 
# then these components are first unbound.  
# If  firstunbindcanon=false,  then an old canonical labelling
# is used when it exists.  However, canonical labellings can depend on
# the version of nauty, the version of GRAPE, certain settings
# of nauty, and the compiler and computer used.  
# Thus, if firstunbindcanon=false, the user must be 
# sure that any canonicalLabelling component(s) which may already 
# exist for graphs in L were created in exactly the same 
# environment in which the user is presently computing. 
#
local L,firstunbindcanon,reps,i,x,found;
L:=arg[1];
if IsBound(arg[2]) then
   firstunbindcanon:=arg[2];
else
   firstunbindcanon:=true;
fi;
if not (IsList(L) and IsBool(firstunbindcanon)) then
   Error("usage: GraphIsomorphismClassRepresentatives( <List> [, <Bool> ] )");
fi;
if not (ForAll(L,IsGraph) or ForAll(L,IsGraphWithColourClasses)) then
   Error("<L> must be a list of graphs or a list of graphs with colour-classes");
fi; 
if firstunbindcanon then
   for x in L do
      Unbind(x.canonicalLabelling);
   od;
fi;
if Length(L)<=1 then
   return ShallowCopy(L);
fi;
reps:=[L[1]];
for i in [2..Length(L)] do
   found:=false;
   for x in reps do
      if IsIsomorphicGraph(x,L[i],false) then
         found:=true;
         break;
      fi;
   od;
   if not found then 
      Add(reps,L[i]);
   fi;
od;
return reps;
end);
   
BindGlobal("PartialLinearSpaces",function(arg)
#
# Let  s  and  t  be positive integers.  Then a *partial linear space*  
# (P,L),  with *parameters*  s,t,  consists of a set  P  of *points*, 
# together with a set  L  of (s+1)-subsets of  P  called *lines*, 
# such that every point is in exactly  t+1  lines, and 
# every pair of (distinct) points is contained in at most one line.
# The *point graph* of a partial linear space  S  having point-set
# P  is the graph with vertex-set  P  and having  (p,q)  an edge iff 
# p<>q  and  p,q  lie on a common line of  S. Two partial linear 
# spaces  (P,L)  and  (P',L')  (with parameters  s,t)  are said 
# to be *isomorphic* if there is a bijection  P-->P'  which induces
# a bijection  L-->L'.
#
# This function returns a list of representatives of distinct isomorphism 
# classes of partial linear spaces with (simple) point graph  ptgraph=arg[1],  
# and parameters  s=arg[2],t=arg[3].  The default is that representatives
# for all isomorphism classes are returned.  
# 
# The integer argument  nspaces=arg[4]  is optional, and has 
# default value  -1,  which means that representatives for all
# isomorphism classes are returned.  If  nspaces>=0  then exactly  nspaces
# representatives are returned if there are at least  nspaces  isomorphism
# classes, otherwise representatives for all isomorphism classes are returned.
#
# In the output of this function, a partial linear space  S  is given
# by its incidence graph  delta.  The point-vertices of  delta  are
# 1,...,ptgraph.order, with the name of point-vertex  i  being the
# name of vertex  i  of  ptgraph.  A line-vertex of  delta  is named by a
# list (not necessarily ordered) of the point-vertex names for the points
# on that line.  We warn that this is a *different* naming convention to
# versions of GRAPE before 4.1.  The group  delta.group  associated
# with the incidence graph  delta  is the automorphism group of  S  
# acting on point-vertices and line-vertices, and preserving both sets.
#
# If  arg[5]  is bound then it controls the printlevel  (default 0).
# Permitted values for  arg[5]  are 0,1,2.  
# 
# If  arg[6]  is bound then it is assumed to be a list (without repeats)
# of the (s+1)-cliques of  ptgraph.  If known, this can help the function
# to run faster. 
# 
local ptgraph,aut,X,printlevel,I,K,s,t,deg,search,cliques,nlines,
      ans,lines,pts,i,j,k,adj,nspaces,names;
ptgraph:=arg[1];
s:=arg[2];
t:=arg[3];
if IsBound(arg[4]) then
   nspaces:=arg[4];
else
   nspaces:=-1;
fi;
if IsBound(arg[5]) then
   printlevel:=arg[5];
else
   printlevel:=0;
fi;
if not (IsGraph(ptgraph) and IsInt(s) and IsInt(t) and 
	IsInt(nspaces) and IsInt(printlevel)) 
    or (IsBound(arg[6]) and not IsList(arg[6])) then
   Error("usage: PartialLinearSpaces(",
	 "<Graph>, <Int>, <Int>, [<Int>, [<Int>, [<List>]]])");
fi;
if not printlevel in [0,1,2] then
   Error("<printlevel> must be 0, 1, or 2");
fi;
if s<1 or t<1 then
   Error("<s> and <t> must be positive integers");
fi;
if not IsSimpleGraph(ptgraph) then
   Error("<ptgraph> must be a simple graph");
fi;
nlines:=(t+1)*ptgraph.order/(s+1);      # number of lines
if not IsInt(nlines) or nspaces=0 then  # no partial linear spaces
   return [];
fi;
if IsBound(arg[6]) then
   cliques:=arg[6];
   if ForAny(cliques,x->not IsSSortedList(x) or Length(x)<>s+1) then
      Error("<arg[6]> incorrect");
   fi;
   if Length(cliques) < nlines then   
      return [];
   fi;
fi;  
deg:=s*(t+1);
if ForAny(ptgraph.adjacencies,x->Length(x)<>deg) then
   return [];
fi;
aut:=AutGroupGraph(ptgraph);
ptgraph:=NewGroupGraph(aut,ptgraph);
if not IsBound(cliques) then
   if IsCompleteGraph(ptgraph) then
      cliques:=Combinations([1..ptgraph.order],s+1); 
   else
      K:=CompleteSubgraphsOfGivenSize(ptgraph,s+1,true,false,true);
      cliques:=Concatenation(Orbits(ptgraph.group,K,OnSets));
   fi;
   if Length(cliques) < nlines then 
      return [];
   fi;
fi;
if nlines=t*(s+1)+1 then  # line graph is complete graph
   adj:=function(x,y) return x<>y and Length(Intersection(x,y))<>1; end;
else
   adj:=function(x,y) return x<>y and Length(Intersection(x,y))>1; end;
fi;
X:=Graph(aut,cliques,OnSets,adj,true);
X.isSimple:=true;
Unbind(X.names);
StabChainOp(X.group,rec(limit:=Size(aut)));
#
# The set  S  of independent sets of size  nlines  in  X  is in 1-to-1 
# correspondence with (the line sets of) the partial linear spaces
# with point graph  ptgraph,  and parameters  s,t.
# 
# Moreover, the orbits of  X.group  (induced by  Aut(ptgraph))  on  S  
# are in  1-to-1  correspondence with the isomorphism classes 
# of the partial linear spaces with point graph  ptgraph,  
# and parameters  s,t.
# 
# We shall classify  S  modulo  X.group,  in order to classify the 
# required partial linear spaces up to isomorphism
# (except that we stop if  nspaces>0  isomorphism classes are required
# and we find that number of them).
#
if Size(X.group) < Size(aut) then
   #
   # non-faithful action of  aut  on (s+1)-cliques, which is impossible if 
   # a subset of these cliques form the line set of a partial linear space
   # with parameters  s,t > 1.
   #
   return [];
fi;
if printlevel > 0 then
   Print("X.order=",X.order," VertexDegrees(X)=",VertexDegrees(X),"\n");
fi;
I:=IndependentSet(ptgraph);
if printlevel > 0 then
   Print("Length(I)=",Length(I),"\n");
fi;
I:=Concatenation(I,Difference([1..ptgraph.order],I));
#
# We shall build the possible partial linear spaces by determining
# the possible line-sets through  I[1],I[2],I[3],...  (in order)
# and backtracking when necessary.  
#
# It appears to be a good strategy to start  I  with the vertices 
# of a maximal independent set of  ptgraph.
#
ans:=[]; 
#
# The "smallest" representatives of new isomorphism classes of the required
# partial linear spaces are put in  ans  as and when they are found.
#

search := function ( i, sofar, live, H )
#
# This is the function for the backtrack search.
#
# Given in  sofar  the vertices of  X  indexing the (s+1)-cliques 
# forming all the lines through the points  I[1],...,I[i-1],  this function
# determines representatives for the new isomorphism classes 
# (not in  ans)  of the required partial linear spaces  S,
# such that the line-set of  S  contains all the cliques indexed by elements 
# of  sofar,  but no clique not indexed by an element in the union of  
# sofar  and  live.  (The clique indexed by  v  is simply  cliques[v].)
# 
# This function assumes that  sofar  and  live  are disjoint sets, and
# that  H <= X.group  stabilizes each of  sofar  and  live  (setwise).
# It is also assumed that  X.names  is unbound, or  X.names=[1..X.order].
#
# Note: On entry to this function it is assumed that  nspaces=-1
# or  nspaces > 0.  If  nspaces > 0  then it is assumed that (on entry)
# nspaces  isomorphism classes have not yet been found.  
# If  nspaces > 0  then this function terminates if  nspaces  
# isomorphism classes are found.  
# It is also assumed that, on entry, the elements of  ans  are distinct
# and are the least lexicographically in their respective  X.group-orbits. 
# 
local  L, K, ind, k, forbid, nlinesreq, F, pointstocover, wts, ii, jj;
if printlevel > 1 then
   Print("\ni=",i," Size(H)=",Size(H));
fi;
if Length(sofar)=nlines then
   #
   # partial linear space found.
   # check if its isomorphism class is new.
   #
   sofar:=SmallestImageSet(X.group,sofar);
   if not (sofar in ans) then
      # process new isomorphism class 
      if printlevel > 1 then
         Print("\n",cliques{sofar},"\n");
      fi;     
      Add(ans,sofar);
   fi;
   return;
fi;
F:=Filtered(sofar,x->I[i] in cliques[x]);
nlinesreq:=(t+1)-Length(F); 
#
#  nlinesreq  is the number of new lines through  I[i]  that 
# must be found.
#
if nlinesreq=0 then
   search(i+1,sofar,live,H);
   return;
fi;
L:=Filtered( live, x->I[i] in cliques[x]);
if printlevel > 1 then    
   Print(" nlinesreq=",nlinesreq,"  Length(L)=",Length(L));
fi;    
if Length(L) < nlinesreq then
   return;
fi;
H := Stabilizer( H, L, OnSets );
ind := ComplementGraph(InducedSubgraph( X, L, H ));
pointstocover :=
   Difference(Adjacency(ptgraph,I[i]),Union(List(F,x->cliques[x])));
wts := List(L,x->ListWithIdenticalEntries(Length(pointstocover),0));
for ii in [1..Length(L)] do
   for jj in cliques[L[ii]] do
      if jj<>I[i] then
         wts[ii][PositionSorted(pointstocover,jj)] := 1;
      fi;
   od;
od;
K := CompleteSubgraphsOfGivenSize( ind, 
   ListWithIdenticalEntries(Length(pointstocover),1), 2, true, true, wts); 
# 
#  K  contains the sets of possible additional lines through  I[i].
# 
if K = [] then
   return;
fi;
if printlevel > 1 then    
   Print("  Length(K)=",Length(K));
fi;    
for k in K  do
   L := ind.names{k};
   forbid := Union( L, Union(List(L,x->Adjacency(X,x))) );
   search( i+1, Union( sofar, L), Difference(live,forbid),
	   Stabilizer(H,L,OnSets) ); 
   if nspaces>=0 and Length(ans)=nspaces then
      return;
   fi;
od;
end;

search(1,[],[1..X.order],X.group);   
for i in [1..Length(ans)] do
   #
   # Determine the incidence graph of the partial linear space
   # whose lines are  cliques{ans[i]},  and store the result in  ans[i].
   #
   pts:=List([1..ptgraph.order],x->[]);
   for j in ans[i] do
      for k in cliques[j] do
	 AddSet(pts[k],j);
      od;
   od;
   aut:=Action(Stabilizer(X.group,ans[i],OnSets),pts,OnSets);
   lines:=SSortedList( cliques{ans[i]} );
   ans[i]:=Graph(aut,
		 Concatenation([1..ptgraph.order],lines),
		 function(x,g)
		    if IsInt(x) then
		       return x^g;
		    else
		       return OnSets(x,g);
		    fi;
		 end,
		 function(x,y)
		    if IsInt(x) then
		       return IsSSortedList(y) and x in y;
		    else 
		       return IsInt(y) and y in x;
		    fi;
		 end,
		 true);
   ans[i].isSimple:=true;
   # now rename the vertices of  ans[i]
   names:=[];
   for j in [1..ptgraph.order] do
      names[j]:=VertexName(ptgraph,j);
   od;
   for j in [ptgraph.order+1..ans[i].order] do
      names[j]:=List(ans[i].names[j],x->VertexName(ptgraph,x));
   od;
   ans[i].names:=Immutable(names);
od;
return ans;
end);
