#include <stdio.h>

char skipwhite()
/* returns the first non-whitespace character on stdin
   (assuming that such a character exists). */
{
char c;   
do c=(char)getchar(); while(c==' ' || c=='\t' || c=='\n' || c=='\r');
return c;
}

void convertgraph()
/* procedure to convert a directed graph in gap format to one in dreadnaut
   format */
{
char c;
printf("d\n"); /* directed graph */
printf("$1n");
while((c=skipwhite())!='[')printf("%c",c);
printf("g\n");
c=skipwhite();  
while(c!=']')
   {
   while(c!='[')c=skipwhite();
   while((c=skipwhite())!=']')
      {
      if(c==',')printf("\n");
      else printf("%c",c);
      }
   if((c=skipwhite())!=']')printf(";\n");
   }
printf(".\n");
/* process vertex colouring */
while((c=skipwhite())!='[');
printf("f[\n");
c=skipwhite();  
while(c!=']')
   {
   while(c!='[')c=skipwhite();
   while((c=skipwhite())!=']')
      {printf("%c",c); if(c==',')printf("\n");}
   if((c=skipwhite())!=']')printf("|\n");
   }
printf("]\n");
}

main()
{
convertgraph();
}
