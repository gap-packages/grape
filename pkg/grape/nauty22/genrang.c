/* genrang.c  version 1.2; B D McKay, Apr 2003 */

#define USAGE \
   "genrang [-P#|-P#/#|-e#|-r#] [-a] [-s|-g] [-S#] [-q] n num [outfile]"

#define HELPTEXT \
" Generate random graphs.\n\
     n  : number of vertices\n\
    num : number of graphs\n\
\n\
    -s  : Write in sparse6 format\n\
    -g  : Write in graph6 format\n\
    -P#/# : Give edge probability; -P# means -P1/#.\n\
    -e# : Give the number of edges\n\
    -r# : Make regular of specified (0-8) degree\n\
    -a  : Make invariant under a random permutation\n\
    -S# : Specify random generator seed (default nondeterministic)\n\
    -q  : suppress auxiliary output\n\
\n\
    -P, -e and -r are incompatible.\n"

#define MAXREG 8   /* Max value for -r switch */

/*************************************************************************

   Oct 27, 2004 : corrected handling of -P values
**************************************************************************/

/*************************************************************************/

#include "gtools.h"

/*************************************************************************/

static void
perminvar(graph *g, permutation *perm, int m, int n)
/* Add to g the least number of edges needed to make perm
   an automorphism. */
{
	int i,j,ii,jj;
	set *gi,*gpi;

	for (i = 0, gi = (set*)g; i < n; ++i, gi += m)
	{
	    gpi = g + m * 1L * perm[i];
	    for (j = -1; (j = nextelement(gi,m,j)) >= 0; )
		if (!ISELEMENT(gpi,perm[j]))
		{
		    ii = perm[i];
		    jj = perm[j];
		    while (ii != i || jj != j)
		    {
			ADDELEMENT(g+m*1L*ii,jj);
			ii = perm[ii];
			jj = perm[jj];
		    }
		}
	}
}

/**************************************************************************/

static void
ranedges(long e, graph *g, int m, int n)
/* Random graph with n vertices and e edges */
{
	long li,nc2,ned,sofar;
	set *gi,*gj;
	int i,j;

	nc2 = n * (long)(n-1) / 2;

	if (e + e > nc2) ned = nc2 - e;
        else             ned = e;
	sofar = 0;

	for (li = m*(long)n; --li >= 0;) g[li] = 0;

	while (sofar < ned)
	{
	    i = KRAN(n);
	    do { j = KRAN(n); } while (i == j);
	    gi = GRAPHROW(g,i,m);
	    if (!ISELEMENT(gi,j))
	    {
		ADDELEMENT(gi,j);
		gj = GRAPHROW(g,j,m);
		ADDELEMENT(gj,i);
	 	++sofar;
	    }
	}

	if (ned != e) complement(g,m,n);
}

/**************************************************************************/

static void
ranreg(int degree, graph *g, int m, int n)
{
        int i,j,k,v,w;
        boolean ok;
	set *gi;
#if MAXN
        int deg[MAXN],p[MAXREG*MAXN],cub[MAXREG*MAXN];
#else
	DYNALLSTAT(int,deg,deg_sz);
	DYNALLSTAT(int,p,p_sz);
	DYNALLSTAT(int,cub,cub_sz);

	DYNALLOC1(int,deg,deg_sz,degree*n,"genrang");
	DYNALLOC1(int,p,p_sz,degree*n,"genrang");
	DYNALLOC1(int,cub,cub_sz,degree*n,"genrang");
#endif

        for (i = j = 0; i < n; ++i)
	    for (k = 0; k < degree; ++k)
               p[j++] = i;

        do
        {
            ok = TRUE;

            for (j = degree*n-1; j >= 1; j -= 2)
            {
                i = KRAN(j);
                k = p[j-1];
                p[j-1] = p[i];
                p[i] = k;
            }

            for (i = 0; i < n; ++i)
                deg[i] = 0;

            for (j = degree*n-1; j >= 1;)
            {
                v = p[j--];
                w = p[j--];
                if (v == w)
                {
                    ok = FALSE;
                    break;
                }
                for (i = deg[w]; --i >= 0;)
                    if (cub[degree*w+i] == v) break;
                if (i >= 0)
                {
                    ok = FALSE;
                    break;
                }
                cub[degree*w+deg[w]++] = v;
                cub[degree*v+deg[v]++] = w;
            }
        }
        while (!ok);

	j = 0;
	for (i = 0, gi = (set*)g; i < n; ++i, gi += m)
	{
	    EMPTYSET(gi,m);
	    for (k = 0; k < degree; ++k)
	    {
	        ADDELEMENT(gi,cub[j]);
	        j++;
	    }
	}
}

/**************************************************************************/
/**************************************************************************/

int
main(int argc, char *argv[])
{
	int m,n,codetype;
	int argnum,j;
	char *arg,sw;
	boolean badargs;
	boolean gswitch,sswitch,qswitch,Sswitch;
	boolean aswitch,P1switch,P2switch,eswitch,rswitch;
	long numgraphs,nout,P1value,P2value,evalue,rvalue;
	int Svalue;
        static FILE *outfile;
	char *outfilename;

#if MAXN
	graph g[MAXM*1L*MAXN];
	permutation perm[MAXN];
#else
	DYNALLSTAT(graph,g,g_sz);
	DYNALLSTAT(permutation,perm,perm_sz);
#endif

	HELP;

	gswitch = sswitch = qswitch = Sswitch = FALSE;
	aswitch = P1switch = P2switch = eswitch = rswitch = FALSE;
	outfilename = NULL;

	argnum = 0;
	badargs = FALSE;
	for (j = 1; !badargs && j < argc; ++j)
	{
	    arg = argv[j];
	    if (arg[0] == '-' && arg[1] != '\0')
	    {
		++arg;
		while (*arg != '\0')
		{
		    sw = *arg++;
			 SWBOOLEAN('g',gswitch)
		    else SWBOOLEAN('s',sswitch)
		    else SWBOOLEAN('a',aswitch)
		    else SWBOOLEAN('q',qswitch)
		    else SWLONG('P',P1switch,P1value,"genrang -P")
		    else SWLONG('/',P2switch,P2value,"genrang -P")
		    else SWLONG('e',eswitch,evalue,"genrang -e")
		    else SWLONG('r',rswitch,rvalue,"genrang -r")
		    else SWINT('S',Sswitch,Svalue,"genrang -S")
		    else badargs = TRUE;
		}
	    }
	    else
	    {
		++argnum;
		if      (argnum == 1)
		{
		    if (sscanf(arg,"%d",&n) != 1 || n < 1) badargs = TRUE;
		}
		else if (argnum == 2)
		{
		    if (sscanf(arg,"%ld",&numgraphs) != 1 || numgraphs < 1)
			badargs = TRUE;
		}
		else if (argnum == 3) outfilename = arg;
		else                  badargs = TRUE;
	    }
	}

	if ((gswitch!=0) + (sswitch!=0) > 1)
	    gt_abort(">E genrang: -gs are incompatible\n");

	if (gswitch) codetype = GRAPH6;
	else         codetype = SPARSE6;

	if (P1switch && !P2switch)
	{
	    P2value = P1value;
	    P1value = 1;
	}
	else if (P2switch && !P1switch)
	{
	    P1value = 1;
	    P1switch = TRUE;
	}

	if (P1switch && (P1value < 0 || P2value <= 0 || P1value > P2value))
	    gt_abort(">E genrang: bad value for -P switch\n");
	 

	if ((P1switch!=0) + (eswitch!=0) + (rswitch!=0) > 1)
	    gt_abort(">E genrang: -Per are incompatible\n");

	if (argnum < 2 || argnum > 3) badargs = TRUE;

	if (badargs)
	{
	    fprintf(stderr,">E Usage: %s\n",USAGE);
	    GETHELP;
	    exit(1);
	}

	if (!Sswitch)
	{
#ifdef INITSEED
	    INITSEED;
	    ran_init(seed);
#endif
	}
	else
	    ran_init(Svalue);

	if (!outfilename || outfilename[0] == '-')
	{
	    outfilename = "stdout";
	    outfile = stdout;
	}
	else if ((outfile = fopen(outfilename,"w")) == NULL)
	{
	    fprintf(stderr,"Can't open output file %s\n",outfilename);
	    gt_abort(NULL);
	}

	m = (n + WORDSIZE + 1) / WORDSIZE;
#if !MAXN
	DYNALLOC2(graph,g,g_sz,n,m,"genrang");
	if (aswitch) DYNALLOC1(permutation,perm,perm_sz,n,"genrang");
#endif

	if (rswitch && rvalue > MAXREG)
	{
	    fprintf(stderr,
		    ">E -r is only implemented for degree <= %d\n",MAXREG);
	    exit(1);
	}

	if (eswitch && evalue > n*(long)(n-1)/2)
	{   
            fprintf(stderr,
                 ">E There are no graphs of order %d and %ld edges\n",
                 n,evalue);
            exit(1);
        }

	if (rswitch && ((n&1) != 0 && (rvalue&1) != 0 || rvalue >= n))
	{
	    fprintf(stderr, 	
		 ">E There are no graphs of order %d and degree %ld\n",
		 n,rvalue);
	    exit(1);
	}

	if (!P1switch)
        {
	    P1value = 1;
	    P2value = 2;
	}

	for (nout = 1; nout <= numgraphs; ++nout)
	{
	    if (eswitch) ranedges(evalue,g,m,n);
	    else if (rswitch) ranreg(rvalue,g,m,n);
            else rangraph2(g,FALSE,P1value,P2value,m,n);

	    if (aswitch)
	    {
		ranperm(perm,n);
		perminvar(g,perm,m,n);
	    }
	    if (codetype == SPARSE6) writes6(outfile,g,m,n);
	    else                     writeg6(outfile,g,m,n);
	}

	exit(0);
}
