program tcfrontend(input,output,tcfein,tcfeout);

(* Program to process the input for  enum  Coset Enumeration version 2.1,
   and also the Praeger-Soicher book format for Coxeter relators.
   Copyright L.H.Soicher, 1992-1998.

   This version expects ASCII input.

   The input presentation (in the form described in enum.doc)
   is read from GRAPE_tcfein, error messages go to output, 
   and the output for the FORTRAN enumerator goes to file GRAPE_tcfeout. *)

label 999;
const maxexpr =  200;
      maxword = 2000;
type  charset = set of char;
      expression = array[1..maxexpr] of char;
      word = array[1..maxword] of 1..104;
      errortype = (badmaxexpr,badmaxword,illchar,illgen,syntax);
var   tcfein,tcfeout : text;
      num : array['A'..'z'] of 1..52;
      inv : array[1..104] of 1..104;

procedure error(err : errortype; ch : char);
begin
writeln;
case err of
   badmaxexpr : writeln(' *** constant maxexpr too small');
   badmaxword : writeln(' *** constant maxword too small');
   illchar : writeln(' *** illegal character ''',ch,'''');
   illgen : writeln(' *** undeclared generator ''',ch,'''');
   syntax : writeln(' *** syntax error - did not expect ''',ch,'''')
end;
goto 999  (* error exit *)
end;

procedure readexpr(var f : text; var e : expression;
		   valid,stop,ignore : charset);
var j : integer;
    brackets : -maxint..0;
    ch : char;
begin
j := 0; 
brackets := 0; (* brackets = 0 iff all brackets are matched *)
repeat
   repeat
      while eoln(f) do readln(f);
      read(f,ch);
      if not(ch in valid) then
	 begin
	 if ch in ['A'..'Z','a'..'z'] then error(illgen,ch)
         else error(illchar,ch)
	 end
   until ch in (valid-ignore);
   j := j+1; 
   if j > maxexpr then error(badmaxexpr,' ');
   e[j] := ch;
   if ch in ['(','['] then brackets := brackets-1
   else if ch in [')',']'] then brackets := brackets+1
until (ch in stop) and (brackets = 0)
end;

function value(var e : expression;
              front : integer; var back : integer) : integer;
(* returns the value of the unsigned integer in e[front]...e[back] *)
var mpr,val,j : integer;
begin
j := front;
while e[j] in ['0'..'9'] do j := j+1;
back := j-1;
mpr := 1; val := 0;
for j := back downto front do
   begin
   val := val + mpr*(ord(e[j])-ord('0'));
   if j > front then mpr := mpr*10
   end;
value := val
end;

procedure invert(var w : word; front,back : integer);
(* inverts w[front]...w[back] *)
var temp : integer;
begin
while front <= back do
   begin
   temp := w[front]; w[front] := inv[w[back]]; w[back] := inv[temp];
   front := front+1; back := back-1
   end
end;

procedure power(var w : word; front : integer;
                var back : integer; n : integer);
(* puts (w[front]...w[back])**n into w[front]... *)
var i,j,k : integer;
begin
if n = 0 then back := front-1
else
   begin
   k := back;
   for i := 2 to n do for j := front to back do
      begin
      k := k+1;
      if k > maxword then error(badmaxword,' ');
      w[k] := w[j] 
      end;
   back := k
   end
end;

procedure writeword(var f : text; var w : word; front,back : integer);
var j : integer;
begin
writeln(f,back-front+1:1);
for j := front to back do writeln(f,w[j]:1)
end;

procedure commutate(var e : expression; var last : integer; 
		    var w : word; front : integer; var back : integer);
forward;

procedure process(var e : expression; var last : integer;
                  var w : word; front : integer; var back : integer);
(* translates the next word in e[last+1]... into w[front]...w[back]. *)
label 99;
begin
back := front-1; last := last+1; 
if e[last] in [')',']',',',';','.','='] then goto 99;
if e[last] = '1' then 
   begin process(e,last,w,front,back); goto 99 end;
if e[last] in ['A'..'Z','a'..'z'] then
   begin
   back := back+1;
   if back > maxword then error(badmaxword,' ');
   w[back] := num[e[last]]
   end
else if e[last] in ['(','['] then
   begin
   process(e,last,w,front,back);
   if e[last] in [',',';'] then commutate(e,last,w,front,back) 
   end
else error(syntax,e[last]);
if e[last+1] = '-' then
   begin invert(w,front,back); last := last+1 end;
if e[last+1] in ['0'..'9'] then power(w,front,back,value(e,last+1,last));
process(e,last,w,back+1,back);
99:end;

procedure commutate;
(* calculates the commutator [ w[front]...w[back] , ... ].
   commutators are left normed, so that [a,b,c,...] means [[a,b],c...]. *)
var i,backsave : integer;
begin
backsave := back;
process(e,last,w,backsave+1,back); 
for i := back+1 to 2*back-front+1 do 
   begin
   if i > maxword then error(badmaxword,' ');
   w[i] := w[i-back+front-1]
   end;
invert(w,front,backsave); invert(w,backsave+1,back);
back := 2*back-front+1;
if e[last] in [',',';'] then commutate(e,last,w,front,back)
end;

procedure mainproc(var tcfein,tcfeout : text);
var   e : expression;
      w,ww : word;
      a : array[1..52,1..52] of 0..maxword;  (* stores Coxeter rels *)
      i,j,k,ngen,x,y,v,min,imin,jmin,back,last,firstlength : integer;
      valid,gens : charset;
      flag : boolean;
begin
(* read generators *)
valid := [' ','A'..'Z','a'..'z',',',';','.'];
readexpr(tcfein,e,valid,['.'],[' ',',',';']);
j := 1; gens := [];
while e[j] <> '.' do
   begin gens := gens+[e[j]]; num[e[j]] := j; j := j+1 end;
valid := valid - (['A'..'Z','a'..'z'] - gens);
ngen := j-1;
for j := 1 to ngen do inv[j] := j;
(* read non-involutions *)
readexpr(tcfein,e,valid,['.'],[' ',',',';']);
j := 1;
while e[j] <> '.' do
   begin inv[num[e[j]]] := ngen+j; inv[ngen+j] := num[e[j]]; j := j+1 end;
writeln(tcfeout,ngen+j-1:1);
for k := 1 to ngen+j-1 do writeln(tcfeout,inv[k]:1);
(* read subgroup generators *)
valid := valid + ['0'..'9','(',')','[',']','+','-'];
repeat
   readexpr(tcfein,e,valid,[',',';','.'],[' ','+']);
   last := 0;
   process(e,last,w,1,back);
   writeword(tcfeout,w,1,back);
until e[last] = '.';
writeln(tcfeout,-1:1); (* indicate start of relators *)
(* check for Coxeter relators *)
valid := valid - ['(',')','[',']','+','-'];
readexpr(tcfein,e,valid,['.'],[' ',',',';']);
if e[1] <> '.' then
   (* process Coxeter relators *)
   begin
   for i := 1 to ngen do for j := 1 to ngen do a[i,j] := 2;
   j := 1;
   if not(e[2] in ['0'..'9']) then
      (* normal enum format for Coxeter relators *)
      repeat
         while not(e[j+2] in ['0'..'9']) do
	    begin
	    x := num[e[j]]; y := num[e[j+1]];
	    a[x,y] := 3; a[y,x] := 3;
	    j := j+1
	    end;
         x := num[e[j]];
         j := j+1;
         repeat
	    y := num[e[j]];
	    v := value(e,j+1,j);
            a[x,y] := v; a[y,x] := v;
	    if e[j+1] <> '.' then j := j+1
         until not(e[j+1] in ['0'..'9'])
      until e[j+1] = '.'
   else
      (* Praeger-Soicher book format for Coxeter relators *)
      repeat
         (* process a path in the Coxeter graph *)
         x := num[e[j]];
         while e[j+1] in ['0'..'9'] do
            begin
            v := value(e,j+1,j);
            j := j+1;
            y := num[e[j]];
            a[x,y] := v; a[y,x] := v;
            x := y
            end;
         j := j+1
      until e[j] = '.';
   min := 0;
   repeat
      flag := true;
      for i := 1 to ngen-1 do for j := i+1 to ngen do
         if (a[i,j] > 0) and ((a[i,j] < min) or flag) then
            begin flag := false; imin := i; jmin := j; min := a[i,j] end;
      if not flag then
         begin
         a[imin,jmin] := 0;
         writeln(tcfeout,2*min:1);
         for j := 1 to min do
	    begin writeln(tcfeout,imin:1); writeln(tcfeout,jmin:1) end
         end
   until flag
   end;
(* read other relators *)
valid := valid + ['(',')','[',']','+','-','=']; 
repeat
   readexpr(tcfein,e,valid,['.',',',';','='],[' ','+']);
   last := 0;
   process(e,last,w,1,firstlength);
   if e[last] = '=' then invert(w,1,firstlength)
   else writeword(tcfeout,w,1,firstlength);
   while e[last] = '=' do
      begin
      readexpr(tcfein,e,valid,['.',',',';','='],[' ','+']);
      last := 0;
      process(e,last,ww,1,back);
      writeln(tcfeout,firstlength+back:1);
      for j := 1 to firstlength do writeln(tcfeout,w[j]:1);
      for j := 1 to back do writeln(tcfeout,ww[j]:1)
      end
until e[last] = '.';
for j := 1 to ngen do
   begin
   writeln(tcfeout,2:1); writeln(tcfeout,j:1); writeln(tcfeout,inv[j]:1);
   if j <> inv[j] then
      begin
      writeln(tcfeout,2:1);
      writeln(tcfeout,inv[j]:1);
      writeln(tcfeout,j:1)
      end
   end;
writeln(tcfeout,-2:1)
end;

begin (* main program *)
reset(tcfein,'GRAPE_tcfein');
rewrite(tcfeout,'GRAPE_tcfeout');
mainproc(tcfein,tcfeout);
999:end.
