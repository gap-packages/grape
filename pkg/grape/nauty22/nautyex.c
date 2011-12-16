/* This program prints generators for the automorphism group of an
   n-vertex polygon, where n is a number supplied by the user.
   It needs to be linked with nauty.c, nautil.c and naugraph.c.

   This version uses a fixed limit for MAXN.
*/

#define MAXN 100
#include "nauty.h"   /* which includes <stdio.h> */

int
main(int argc, char *argv[])
{
    graph g[MAXN*MAXM];
    int lab[MAXN],ptn[MAXN],orbits[MAXN];
    static DEFAULTOPTIONS_GRAPH(options);
    statsblk(stats);
    setword workspace[50*MAXM];

    int n,m,v;
    set *gv;

    options.writeautoms = TRUE;

    while (1)
    {
        printf("\nenter n : ");
        if (scanf("%d",&n) == 1 && n > 0)
        {
            if (n > MAXN)
            {
                printf("n must be in the range 1..%d\n",MAXN);
                exit(1);
            }

            m = (n + WORDSIZE - 1) / WORDSIZE;
            nauty_check(WORDSIZE,m,n,NAUTYVERSIONID);

            for (v = 0; v < n; ++v)
            {
                gv = GRAPHROW(g,v,m);

                EMPTYSET(gv,m);
                ADDELEMENT(gv,(v+n-1)%n);
                ADDELEMENT(gv,(v+1)%n);
            }

            printf("Generators for Aut(C[%d]):\n",n);
            nauty(g,lab,ptn,NULL,orbits,&options,&stats,
                                            workspace,50*MAXM,m,n,NULL);
        }
        else
            break;
    }

    exit(0);
}
