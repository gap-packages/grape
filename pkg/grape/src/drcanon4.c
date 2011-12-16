#include <stdio.h>

/* Program to read the number of vertices, followed by the nauty 
   canonical labelling of a graph, and to convert this labelling 
   into a  gap 4 permutation  GRAPE_dr_canon .  */

main()
{
int n,i,im;
scanf("%d",&n);
printf("GRAPE_dr_canon:=PermList([\n");
for(i=1;i<=n-1;i++){scanf("%d",&im); printf("%d,\n",im);}
scanf("%d",&im); printf("%d]);\n",im);
}
