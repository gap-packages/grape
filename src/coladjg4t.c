/* coladjg4t.c
   Copyright L.H.Soicher, 1992.
   Slightly modified September, 1998. */

#include <stdio.h>
#define NULL 0
#define MAXREP 255 /* must be <= 255 */
#define MAXGEN 255 /* must be <= 255 */

typedef unsigned char byte;
extern char *malloc();

void memoryerror()
{
fprintf(stderr,"\n *** error trying to allocate memory\n"); exit(0);
}

int *makeintvec(n) int n;
{
int *vec;
if((vec=(int *)malloc((unsigned)(n+1)*sizeof(int)))==NULL)memoryerror();
vec[0]=n; return(vec);
}

byte *makebytevec(n) int n;
{
byte *vec;
if((vec=(byte *)malloc((unsigned)(n+1)*sizeof(byte)))==NULL)memoryerror();
return(vec);
}

int **makeintptrvec(n) int n;
{
int **vec;
if((vec=(int **)malloc((unsigned)(n+1)*sizeof(int *)))==NULL)memoryerror();
vec[0]=makeintvec(0); vec[0][0]=n;
return(vec);
}

int *getintvec()
{
int *vec,n,i;
scanf("%d",&n); vec=makeintvec(n);
for(i=1;i<=n;i++)scanf("%d",vec+i);
return(vec);
}

int **getintvecs()
{
int **vecs,n,i;
scanf("%d",&n); vecs=makeintptrvec(n);
for(i=1;i<=n;i++)vecs[i]=getintvec();
return(vecs);
}

int *orbits(a,w,sv,ind) int **a,**w; byte *sv,*ind;
/* Calculates the orbits under the action of the words in 
   w  in the generators in  a. 
   Makes schreier vector  sv  iff  sv!=NULL,  and if makes this
   vector assumes all words in  w  have length 1.
   Makes indicator vector  ind,  and returns vector of orbit 
   representatives. 
   Assumes  a  contains at least one generator. */
{
int *orb,n,makesv,*rep,*rp,s,t,pt,i,j,k,nrep; 
n=a[1][0];
orb=makeintvec(n); rep=makeintvec(MAXREP);
if(makesv=(sv!=NULL))sv[1]=(byte)0;
for(i=1;i<=n;i++)ind[i]=(byte)0;
nrep=0;
for(i=1;i<=n;i++)if(ind[i]==(byte)0)
   {
   /* new orbit */
   if(++nrep>MAXREP)
      {fprintf(stderr,"\n *** error, too many orbits\n"); exit(0);}
   ind[i]=(byte)nrep; rep[nrep]=orb[1]=i;
   s=0; t=1; 
   while(s<t)
      {
      /* act on next point by each word in w */
      s++; 
      for(j=1;j<=w[0][0];j++)
	 {
	 for(pt=orb[s],k=1;k<=w[j][0];k++)pt=a[w[j][k]][pt];
	 if(ind[pt]==(byte)0)
	    {
	    /* new point in orbit */
            ind[pt]=(byte)nrep;
	    if(makesv)sv[pt]=(byte)(w[j][1]);
	    orb[++t]=pt;
	    }
	 }
      }
   }
free((char *)orb);
rp=makeintvec(nrep); for(i=1;i<=nrep;i++)rp[i]=rep[i];
free((char *)rep);
return(rp);
}

int **repword(a,inv,rep,sv) int **a,**inv,*rep; byte *sv;
/* For each  i  calculates word in  a  taking  1  to  rep[i]. */
{
int **rw,i,j,k,pt,length,gen;
rw=makeintptrvec(rep[0]);
for(i=1;i<=rep[0];i++)
   {
   /* first find word length */
   length=0; pt=rep[i];
   while((gen=(int)(sv[pt]))!=0)
      {
      length++; 
      /* apply inverse of  a[gen]  to  pt */
      for(j=1;j<=inv[gen][0];j++)pt=a[inv[gen][j]][pt];
      }
   rw[i]=makeintvec(length);
   /* now calculate word taking  1  to  rep[i] */
   pt=rep[i]; 
   for(j=length;j>=1;j--)
      {
      gen=rw[i][j]=(int)(sv[pt]);
      /* apply inverse of  a[gen]  to  pt */
      for(k=1;k<=inv[gen][0];k++)pt=a[inv[gen][k]][pt];
      }
   }   
return(rw);
}

int ***coladj(a,rw,ind) int **a,**rw; byte *ind;
{
int ***ca,nrep,n,i,j,k,pt;
n=a[1][0];
nrep=rw[0][0];
if((ca=(int ***)malloc((unsigned)(nrep+1)*sizeof(int **)))==NULL)
   memoryerror();
ca[0]=makeintptrvec(0); ca[0][0][0]=nrep;
for(i=1;i<=nrep;i++)
   {
   ca[i]=makeintptrvec(nrep);
   for(j=1;j<=nrep;j++)
      {
      ca[i][j]=makeintvec(nrep);
      for(k=1;k<=nrep;k++)ca[i][j][k]=0;
      }
   }
for(i=1;i<=n;i++)for(j=1;j<=nrep;j++)
   {
   for(pt=i,k=1;k<=rw[j][0];k++)pt=a[rw[j][k]][pt];
   (ca[(int)ind[i]][j][(int)ind[pt]])++;
   }
return(ca);
}

main(argc,argv) int argc; char *argv[];
{
int ngen,n,i,j,k,pi,pj,nrep,**a,**inv,**wgrp,**wsub,*rep,*p,*l,**rw,***ca; 
byte *sv,*ind;
FILE *outfile;  
a=getintvecs(); ngen=a[0][0];
if(ngen<=0)
   {
   fprintf(stderr,"\n *** error, must have at least one generator\n"); 
   exit(0);
   }
if(ngen>MAXGEN)
   {fprintf(stderr,"\n *** error, too many generators\n"); exit(0);}
n=a[1][0];
inv=getintvecs();
wsub=getintvecs();
wgrp=makeintptrvec(ngen);
for(i=1;i<=ngen;i++){wgrp[i]=makeintvec(1); wgrp[i][0]=1; wgrp[i][1]=i;}
sv=makebytevec(n); ind=makebytevec(n);
rep=orbits(a,wgrp,sv,ind);
if(rep[0]!=1)
   {fprintf(stderr,"\n *** error, group not transitive\n"); exit(0);}
free((char *)rep);
rep=orbits(a,wsub,(byte *)NULL,ind);
nrep=rep[0];
rw=repword(a,inv,rep,sv);
free((char *)sv);
ca=coladj(a,rw,ind);
/* now determine ordering  p  for orbits, based first on orbit length, 
   then by order in rep */
p=makeintvec(nrep); l=makeintvec(nrep);
for(i=1;i<=nrep;i++)l[i]=ca[i][1][i];
for(i=1;i<=nrep;i++)
   {
   k=n+1; /* bigger than any orbit length */
   for(j=1;j<=nrep;j++)if(l[j]<k){p[i]=j; k=l[j];}
   l[p[i]]=n+1;
   }
free((int *)l);
/* output the matrices for non-trivial graphs in various formats */
/* human format */
for(i=2;i<=nrep;i++)
   {
   pi=p[i];
   printf("\nword = "); 
   for(j=1;j<=rw[pi][0];j++)printf("%c",argv[1][rw[pi][j]-1]);
   printf("\n");
   for(j=1;j<=nrep;j++)
      {
      pj=p[j];
      for(k=1;k<=nrep;k++)printf("%8d",ca[pi][pj][p[k]]);
      printf("\n");
      }
   }
printf("\n");
/* gap-3/gap-4 format */
outfile=fopen("GRAPE_coladj.g","w");
fprintf(outfile,"GRAPE_coladjmatseq:=[");
if(nrep==1)fprintf(outfile,"];\n");
for(i=2;i<=nrep;i++)
   {
   pi=p[i];
   fprintf(outfile,"[");
   for(j=1;j<=nrep;j++)
      {
      pj=p[j];
      fprintf(outfile,"[");
      for(k=1;k<=nrep;k++)
	 {
	 fprintf(outfile,"\n%d",ca[pi][pj][p[k]]);
	 if(k<nrep)fprintf(outfile,","); else fprintf(outfile,"]");
	 }
      if(j<nrep)fprintf(outfile,","); else fprintf(outfile,"]");
      }
   if(i<nrep)fprintf(outfile,","); else fprintf(outfile,"];\n");
   }
fclose(outfile);
/* latex format */
outfile=fopen("GRAPE_coladj.tex","a");
for(i=2;i<=nrep;i++)
   {
   pi=p[i];
   fprintf(outfile,"\n\\medskip$${\\tt\n");
   for(j=1;j<=rw[pi][0];j++)fprintf(outfile,"%c",argv[1][rw[pi][j]-1]);
   fprintf(outfile,"\n}$$");
   fprintf(outfile,"\n$$\\left(\\begin{array}{");
   for(j=1;j<=nrep;j++)fprintf(outfile,"r");
   fprintf(outfile,"}");
   for(j=1;j<=nrep;j++)
      {
      pj=p[j];
      for(k=1;k<=nrep;k++)
	 {
	 fprintf(outfile,"\n%d",ca[pi][pj][p[k]]);
	 if(k<nrep)fprintf(outfile," &"); else fprintf(outfile," \\\\");
	 }
      if(j==nrep)fprintf(outfile,"\n\\end{array}\\right)$$");
      }
   }
fprintf(outfile,"\n");
fclose(outfile);
}
