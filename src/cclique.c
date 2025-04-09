/* This program determines the cliques with a given vertex vector-weight
   sum in a graph with adjacency matrix  Gamma,  given a sequence 
   of partial solutions and corresponding lists of active vertices 
   from which to augment the partial solutions and the corresponding 
   required vertex vector-weight sums for the augmentations. 

   The partial solutions to consider are those with with indices 
   argv[1] up to argv[2], or until EOF if this comes first or if 
   argv[2] is -1.

   Leonard Soicher, 09/09/2023 */

#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

/* Integer lists are stored in arrays, with indexing starting at 1.
   For an integer list  x,  x[0] is used to store the length of  x,
   so the list itself is  x[1],...,x[x[0]]  (but the array used to 
   store  x  may be longer than x[0]+1 integers). */

#define Length(x) ((x)[0]) /* for integer lists */

#define SetLength(x,length) (((x)[0])=(length)) /* for integer lists */

typedef unsigned char byte;

byte **Gamma; 
/* the (0,1)-adjacency matrix, with indexing starting at 1 */

int Gamma_order,Gamma_d; 

int **weightvectors,**weightpositions; 
/* weightvectors[i] stores the (vector-)weight of vertex  i. 
   Each weightvector must be a non-zero list of non-negative integers of
   length  Gamma_d.  weightpositions[i] is a list giving the positions in
   weightvectors[i] of the non-zero elements.*/

int isolevel;
/* The value of isolevel must be  0  or  1.
   If isolevel==1 then all solutions will be found.
   If isolevel==0 then just one solution will be found
   (iff a solution exists). */

int allmaxes;
/* The value of  allmaxes  must be  0  or  1. 
   If  allmaxes==0  then solutions that are not necessarily 
   maximal are returned. 
   If  allmaxes==1  then only maximal solutions are returned. */
   
long long int solution_count,f_count; 
FILE *solution_file;

int *IntArray(int n) 
/* Returns an uninitialized integer array with n elements. */
{
int *a;
if((a=(int *)malloc(((unsigned)n)*sizeof(int)))==NULL)
   {
   fprintf(stderr,
      "\n*** error trying to allocate memory for integer array\n"); 
   exit(EXIT_FAILURE);
   }
return a;
}

byte *ByteArray(int n) 
/* Returns an uninitialized byte array with n elements. */
{
byte *a;
if((a=(byte *)malloc(((unsigned)n)*sizeof(byte)))==NULL)
   {
   fprintf(stderr,
      "\n*** error trying to allocate memory for byte array\n"); 
   exit(EXIT_FAILURE);
   }
return a;
}

int **IntArrayArray(int m,int n) 
/* Returns an uninitialized m by n int array. */
{
int **a;
int i;
if((a=(int **)malloc(((unsigned)m)*sizeof(int *)))==NULL)
   {
   fprintf(stderr,
      "\n*** error trying to allocate memory for an m by n int array\n"); 
   exit(EXIT_FAILURE);
   }
for(i=1;i<=m;i++)
   a[i]=IntArray(n);
return a;
}

byte **ByteArrayArray(int m,int n) 
/* Returns an uninitialized m by n byte array. */
{
byte **a;
int i;
if((a=(byte **)malloc(((unsigned)m)*sizeof(byte *)))==NULL)
   {
   fprintf(stderr,
      "\n*** error trying to allocate memory for an m by n byte array\n"); 
   exit(EXIT_FAILURE);
   }
for(i=1;i<=m;i++)
   a[i]=ByteArray(n);
return a;
}

int IsClique(int *vertexlist) 
/* Where  vertexlist  is an integer list of vertices of  Gamma,
   this function returns  1  if these vertices form a clique of  
   Gamma,  and returns  0  if not.  */
{
int i,j; 
for(i=1;i<=Length(vertexlist)-1;i++)
   for(j=i+1;j<=Length(vertexlist);j++)
      if(!Gamma[vertexlist[i]][vertexlist[j]])
         return 0;
return 1;
}

int IsMaximal(int *clique) 
/* Where  clique  is an integer list of vertices of  Gamma,
   which form a clique, this function returns  1  if this clique
   is maximal in  Gamma,  and returns  0  if not.  */
{
int i,j; 
for(i=1;i<=Gamma_order;i++)
   {
   for(j=1;j<=Length(clique);j++)
      {
      if(!Gamma[i][clique[j]])
         /* vertex  i  is not joined to every element of  clique. */
         break;
      }
   if(j>Length(clique))
      /* vertex  i  is joined to every element of  clique. */
      return 0;
   }
return 1;
}

void InitialiseSolutions()
{
solution_count=0;
solution_file=stdout;
fprintf(solution_file,"[");
}

void ProcessSolution(int *solution)
/* Processes the solution in the list  solution  of vertices of  Gamma. */
{
int i;
if (solution_count>0)
   fprintf(solution_file,","); /* after previous solution */
solution_count++;
fprintf(solution_file,"["); /* start of current solution */
for(i=1;i<=Length(solution);i++)
   {
   if(i>1)
      fprintf(solution_file,",");
   fprintf(solution_file,"%d",solution[i]); 
   }
fprintf(solution_file,"]"); 
}

void FinaliseSolutions()
{
fprintf(solution_file,"]");
}

void CliqueSearch1(int *sofar,int *active,int *kvector)
/* The function parameters are integer lists. 
   The lists  sofar  and  active  are assumed each to have have 
   storage for their length and for  Gamma_order  integers. 
   The list  kvector  is assumed to have storage for its length 
   and for  Gamma_d  integers. */ 

/* Given a partial solution in the list  sofar,  and a list  
   active  of vertices which can be used to augment  sofar  
   (in particular, every element of  active  is joined to 
   every element of  sofar  in the graph  Gamma),
   this function determines cliques  C  in the induced 
   subgraph of  Gamma  on the vertices in  active,  such that the 
   sum of the weight-vectors of the vertices of  C  is equal to  
   kvector.  

   If  allmaxes==0  then each such  C  together with  sofar  is a 
   solution, and if  allmaxes==1,  each such  C  together with  sofar  
   that is a maximal clique is a solution.

   If  isolevel==0,  just one solution is determined iff 
   there is a solution, and if  isolevel==1,  then all
   solutions are determined.   

   Each solution determined is processed by the function  ProcessSolution.

   The list  active  may be changed by this function. */
{   
int k,i,j,m,ll,jj,count,vertex,endconsider,equality,
   doposition,temp,wt,cwsum,minptr,*wv,*wp,startcolouring,
   *nactivevector,*activecountvector, 
   *adj; /* For storing the sizes of adjacencies or for storing 
            the vertices in an adjacency to be passed as "active". */
byte *a;

/* Arrays to be used for partial proper vertex-colouring. */
int *col,*cw,*cn;
byte *adjcol;

f_count++; /* Counts the number of times this function is called. */
k=0;
for(i=1; i<=Length(kvector); i++)
   k+=kvector[i];
if(k==0)
   {
   /* The list  sofar  is the only possible solution. */
   if(allmaxes)
      {
      /* determine whether  sofar  is maximal */
      if(Length(active)>0)
         /* sofar is not maximal */
         return;
      if(!IsMaximal(sofar))
         return;
      }
   ProcessSolution(sofar);
   return;
   }
nactivevector=IntArray(Gamma_d+1);
activecountvector=IntArray(Gamma_d+1);
SetLength(nactivevector,Length(kvector)); 
SetLength(activecountvector,Length(kvector)); 
for(j=1; j<=Length(nactivevector); j++)
   {
   nactivevector[j]=0;
   activecountvector[j]=0;
   }
for(i=1; i<=Length(active); i++)
   {
   wv=weightvectors[active[i]];	
   wp=weightpositions[active[i]];
   for(j=1; j<=Length(wp); j++)
      if(wv[wp[j]]>kvector[wp[j]])
	 {
	 /* We eliminate active[i], as it cannot be in a solution. */
	 active[i]=0;
         break;
         }	 
   if(active[i])
      for(j=1; j<=Length(wp); j++)
	 {
	 nactivevector[wp[j]]+=wv[wp[j]];
	 activecountvector[wp[j]]++;
	 }
   }
equality=1;
for(j=1; j<=Length(nactivevector); j++)
   {
   if(kvector[j]>nactivevector[j])
      {
      /* No solution is possible. */
      free(nactivevector);
      free(activecountvector);
      return;
      }
   if(kvector[j]!=nactivevector[j])
         equality=0;
   }
/* At this point we know that  kvector  is not the zero vector,
   and no entry of  kvector  is greater than the corresponding 
   entry of  nactivevector.  Moreover,  equality==1  iff 
   kvector  equals  nactivevector  (as integer lists). 

   Now compress  active  to remove any zero (i.e. eliminated) 
   elements. */
count=0; /* counts the non-zero elements in  active */
for(i=1; i<=Length(active); i++)
   if(active[i])
      active[++count]=active[i];
SetLength(active,count); 
if(equality)
   {	
   /* We have a solution iff the active vertices form a clique,
      and if allmaxes, then also this clique must be maximal. */
   if(!IsClique(active))
      {
      free(nactivevector);
      free(activecountvector);
      return;
      }
   /* Now the clique  active concat sofar  is the only possible solution. */	
   for(i=1; i<=Length(sofar); i++)
      {
      SetLength(active,Length(active)+1);
      active[Length(active)]=sofar[i];
      }
   if(allmaxes)
      if(!IsMaximal(active))
         {
         free(nactivevector);
         free(activecountvector);
         return;
         }
   /* Now  active  is the only solution. */
   free(nactivevector);
   free(activecountvector);
   ProcessSolution(active); 
   return;
   }
/* Now (heuristically) determine  doposition  to 
   (hopefully) minimize the work which follows.
   We choose  doposition  to be the index in 
   activecountvector  of a least non-zero element. */
doposition=0;
for(i=1; i<=Length(activecountvector); i++) 
   if(activecountvector[i]>0)
      {
      if(doposition==0)
         doposition=i;
      else
         if(activecountvector[i]<activecountvector[doposition])
            doposition=i;
      }
endconsider=Length(active);
if(Gamma_d>1)
   {
   /* Push active vertices whose weightvectors have 0 in the doposition
      beyond endconsider. */
   i=1;
   while(i<=endconsider)
      if(weightvectors[active[i]][doposition])
         i++;
      else
         {
         if(i<endconsider)
            {
            temp=active[endconsider];
            active[endconsider]=active[i];
            active[i]=temp;
	    }
         endconsider--;
         }
   }
if(Gamma_d==1 && allmaxes)
   {
   for(i=1;i<=Gamma_order;i++)
      {
      for(j=1;j<=Length(sofar);j++)
         {
         if(!Gamma[i][sofar[j]])
            break;
         }
      if(j>Length(sofar))
         /* vertex  i  is joined to every element of  sofar. */
         break;
      }
   /* Push active vertices joined to vertex  i  beyond endconsider. */
   j=1;
   while(j<=endconsider)
      if(!Gamma[active[j]][i])
         j++;
      else
         {
         if(j<endconsider)
            {
            temp=active[endconsider];
            active[endconsider]=active[j];
            active[j]=temp;
	    }
         endconsider--;
         }
   }
adj=IntArray(Gamma_order+1); 
if(kvector[doposition]>1) 
   {
   /* Order (heuristically) the vertices in active[1],...,active[endconsider],
      and apply partial proper vertex-colouring appropriately. */
   SetLength(adj,endconsider); 
   /* adj[i] will be used to record the number of active vertices 
      adjacent to  active[i],  for  i=1,...,endconsider. */
   for(i=1; i<=endconsider; i++)
      {
      vertex=active[i];
      adj[i]=0;
      for(m=1; m<=Length(active); m++)
         if(Gamma[vertex][active[m]])
             adj[i]++;
      }
   /* Now order the elements in  active[1],...,active[endconsider], 
      and the corresponding elements of  adj. */
   for(i=1; i<=endconsider; i++)
      {
      minptr=i;
      for (j=i+1; j<=endconsider; j++)
         if(adj[j]<adj[minptr])
            minptr=j;
      temp=active[i];
      active[i]=active[minptr];
      active[minptr]=temp;
      temp=adj[i];
      adj[i]=adj[minptr];
      adj[minptr]=temp;
      /* Now  active[i]  is a vertex of least degree ( == nadj[i]) 
         amongst  active[i],...,active[endconsider]  in the
         induced subgraph in  Gamma  on the vertices   
	 active[i],...,active[Length(active)]. */
      a=Gamma[active[i]];
      for(j=i+1; j<=endconsider; j++)
         if(a[active[j]])
            adj[j]--;
      }
   if(Gamma_d>1)
      startcolouring=endconsider;
   else
      startcolouring=Length(active);
    /* Do partial proper vertex-colouring, in reverse order 
      of the vertices in  active,  starting from the  
      startcolouring  position.  
   
      col[i]  will record the colour of  active[i],  if and when  
      active[i]  is coloured. 
   
      cw[j]  will record the largest entry in the doposition 
      of a weightvector of a vertex having colour  j. 

      cn[jj]  will record the number of vertices currently having
      colour  jj.

      The arrays  col,  cw,  and  cn  are *not* considered to be 
      integer lists. */ 
   col=IntArray(startcolouring+1);
   cw=IntArray(startcolouring+1);
   cn=IntArray(startcolouring+1);
   adjcol=ByteArray(startcolouring+1); 
   cwsum=0;
   m=0;  /* maximum colour used so far */
   for(i=startcolouring; i>=1; i--) 
      {
      /* try to colour active[i] */
      for(j=1; j<=m+1; j++)
         adjcol[j]=0; /* initialize to false */
      a=Gamma[active[i]];
      for(j=i+1; j<=startcolouring; j++)
         if(a[active[j]])
            adjcol[col[j]]=1; /* true */
      j=m+1; /* current colour choice for active[i] */
      for(jj=1; jj<=m; jj++)
         {
         if(!adjcol[jj])
            {
            /* jj is a feasible colour for active[i] */
            if(j==m+1)
               j=jj; /* new current colour choice */
            else
               {
               if(cn[jj]>cn[j])
                  /* More vertices are currently coloured with jj than
                     current colour choice j. */
                  j=jj; /* new current colour choice */
               }
            }
         }
      /* We plan to colour  active[i]  with the colour  j. */
      col[i]=j;
      wt=weightvectors[active[i]][doposition];
      if(j>m)
         {
         /* j is a new colour */
         m++;
         cwsum=cwsum+wt;
         cw[j]=wt;
         cn[j]=1;
         }
      else 
         {
         cn[j]++;
         if(cw[j]<wt)
            {
            cwsum=cwsum+(wt-cw[j]);
            cw[j]=wt;
            }
         }
      if(cwsum>=kvector[doposition])
         {
         /* stop colouring */
         if(i<endconsider)
            endconsider=i;
         break;
         }
      }
   free(col);
   free(cw);
   free(cn);
   free(adjcol);
   if(cwsum<kvector[doposition])
      {
      /* there is no solution */
      free(adj); 
      free(nactivevector);
      free(activecountvector);
      return; 
      }
   }
/* Now search recursively. */
for(i=1; i<=endconsider; i++)
   {
   /* Determine the solutions containing  active[i]  in the induced
      subgraph in  Gamma  on  active[i],...,active[Length(active)].

      First, determine the adjacency  adj  of  active[i]  in this
      induced subgraph. */
   a=Gamma[active[i]];
   ll=0;
   for(j=i+1; j<=Length(active); j++)
      if(a[active[j]])
         adj[++ll]=active[j]; 
   SetLength(adj,ll); 
   /* Now make  kvector  for the recursive call. */
   wv=weightvectors[active[i]];
   wp=weightpositions[active[i]];
   for(j=1; j<=Length(wp); j++)
      kvector[wp[j]]-=wv[wp[j]];
   /* Now make  sofar  for the recursive call. */
   SetLength(sofar,Length(sofar)+1);
   sofar[Length(sofar)]=active[i];
   /* The recursive call. */
   CliqueSearch1(sofar,adj,kvector);
   /* Now restore  sofar. */
   SetLength(sofar,Length(sofar)-1);  /* deletes  active[i]  from  sofar  */
   /* Now restore  kvector */
   for(j=1; j<=Length(wp); j++)
      kvector[wp[j]]+=wv[wp[j]];
   if(solution_count>0 && isolevel==0)
      {
      /* We are done. */
      free(adj);
      free(nactivevector);
      free(activecountvector);
      return;
      }
   for(j=1; j<=Length(wp); j++)
      if((nactivevector[wp[j]]-=wv[wp[j]])<kvector[wp[j]])
	 {
	 free(adj);
         free(nactivevector);
         free(activecountvector);
         return;
	 }
   }
free(adj); 
free(nactivevector);
free(activecountvector);
return;
}

int main(int argc, char *argv[])
{  
int lengthsofar,lengthactive,i,j,num,m,count,
    *sofar,*active,*kvector;
long int case_count,startwork,endwork;
char **strptr;
if(argc<3)
   {
   fprintf(stderr,"\nerror: command must have at least 2 arguments.\n");
   exit(EXIT_FAILURE);
   }
startwork=strtol(argv[1],strptr,10);
endwork=strtol(argv[2],strptr,10);
f_count=0;
InitialiseSolutions();
stderr = fopen("cclique.err","w");
m=scanf("%d %d %d %d",&isolevel,&allmaxes,&Gamma_order,&Gamma_d);
if (isolevel!=0 && isolevel!=1) 
   {
   fprintf(stderr,"\nerror: isolevel must be  0  or  1\n");
   exit(EXIT_FAILURE);
   }
if (allmaxes!=0 && allmaxes!=1) 
   {
   fprintf(stderr,"\nerror: allmaxes must be  0  or  1\n");
   exit(EXIT_FAILURE);
   }
Gamma=ByteArrayArray(Gamma_order+1,Gamma_order+1);
/* Read adjacency matrix  Gamma. */
for(i=1; i<=Gamma_order; i++)
   {
   for(j=1; j<=Gamma_order; j++)
      {
      m=scanf("%d",&num);
      if(num!=0 && num!=1)
         {
         fprintf(stderr,"\nerror: adjacency matrix entries must be 0 or 1\n");
         exit(EXIT_FAILURE);
         }
      Gamma[i][j]=(byte)num;
      }
   }
weightvectors=IntArrayArray(Gamma_order+1,Gamma_d+1);
weightpositions=IntArrayArray(Gamma_order+1,1+1); /* for starters */
for(i=1; i<=Gamma_order; i++)
   {
   /* Determine  weightvectors[i]  and  weightpositions[i]. */
   SetLength(weightvectors[i],Gamma_d);
   count=0; /* counts the number of non-zero entries in weightvectors[i] */
   for(j=1; j<=Gamma_d; j++)
      {
      m=scanf("%d",&num);
      weightvectors[i][j]=num;
      if(num)
         count++;
      }
   if(count>1)
      /* need to enlarge  weightpositions[i] */
      weightpositions[i]=IntArray(count+1); 
   SetLength(weightpositions[i],count);
   count=0;
   for(j=1; j<=Gamma_d; j++)
      if(weightvectors[i][j])
         weightpositions[i][++count]=j;
   }
case_count=0;
sofar=IntArray(Gamma_order+1);
active=IntArray(Gamma_order+1);
kvector=IntArray(Gamma_d+1);
while(1==scanf("%d",&lengthsofar))
   {
   /* Successful read indicates new partial solution to consider. */ 
   if(endwork!=-1 && case_count>=endwork) 
      /* All required cases have been considered. */
      break;
   case_count++;
   SetLength(sofar,lengthsofar);
   for(i=1; i<=lengthsofar; i++)
      m=scanf("%d",&sofar[i]);
   m=scanf("%d",&lengthactive);
   SetLength(active,lengthactive);
   for(i=1; i<=lengthactive; i++)
      m=scanf("%d",&active[i]);
   SetLength(kvector,Gamma_d);
   for(i=1; i<=Gamma_d; i++)
      m=scanf("%d",&kvector[i]);
   if(case_count>=startwork) 
      {
      CliqueSearch1(sofar,active,kvector); 
      if(solution_count>0 && isolevel==0)
         break;  
      }
   }
FinaliseSolutions();
exit(EXIT_SUCCESS);
}
