#include <stdio.h>
#define MAXSTRING 100
#define MAXBASE 10000

/* Program to convert nauty graph automorphism group output to gap 4 input. 
   This program relies on the precise form of nauty 2.0 output
   and may have to be changed if a different version of nauty
   is used. It also relies on the vertex numbering starting at  1, and the
   "level" output being on a single line. 

   "GRAPE_dr_sgens" is a sequence of strong generators w.r.t.
   the base "GRAPE_dr_base". */

char skipwhite()
/* returns the first non-whitespace character on stdin
   (assuming that such a character exists). */
{
char c;   
do c=(char)getchar(); while(c==' ' || c=='\t' || c=='\n' || c=='\r');
return c;
}

void skipline()
/* reads until start of new line. */
{
char c;   
do c=(char)getchar(); while(c!='\n');
}

char convertperm()
/* procedure to convert a permutation in nauty format to one in gap format.
   this proc assumes initial '(' has just been read. 
   returns the first character on the next line after the permutation. */
{
char prev,current;
current='(';
do 
   {
   printf("%c",current);
   do
      {
      prev=current; current=(char)getchar();
      if(current=='\n')break;
      if(current==' ' && prev!='(' && prev!=' ' && prev!=',' && prev!=')')
         current=',';
      if(current==')' && (prev==' ' || prev==','))
        {fprintf(stderr," *** error interpreting nauty output\n"); exit(0);}
      printf("%c",current);
      }
   while(1);
   current=(char)getchar();
   if(current!=' ')return current;
   current=skipwhite();
   if(current!=')' && prev!=',' && prev!=' ' && prev!='(' &&  prev!=')')
      printf(",");
   if(current==')' && (prev==' ' || prev==','))
     {fprintf(stderr," *** error interpreting nauty output\n"); exit(0);}
   printf("\n");
   }
while(1);
}

int getbasept()
{
char c,s1[MAXSTRING],s2[MAXSTRING];
int pt;
do scanf("%s%s",s1,s2); while(s2[0]!='f');
sscanf(s1,"%d",&pt);
return pt; 
}
   
main()
{
char c;
int i,nbase,base[MAXBASE+1];
nbase=0;
printf("GRAPE_dr_sgens:=[\n");
c=(char)getchar(); 
do 
   {
   if(c=='['){skipline(); while((c=(char)getchar())=='l')skipline();}
   else if(c=='('){c=convertperm(); if(c=='(')printf(",\n");}
   else if(c=='l')
      {
      if(++nbase>MAXBASE)
         {fprintf(stderr," *** error, MAXBASE too small\n"); exit(0);}
      base[nbase]=getbasept();
      skipline(); 
      while((c=(char)getchar())=='l')skipline();
      if(c=='(')printf(",\n");
      }
   else break;
   }
while(1);
printf("];\n");
printf("GRAPE_dr_base:=[\n");
if(nbase>0)printf("%d",base[nbase]);
for(i=nbase-1;i>=1;i--)printf(",\n%d",base[i]);
printf("];\n");
}
