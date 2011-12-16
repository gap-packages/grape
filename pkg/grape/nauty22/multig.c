/* multig.c version 1.0; B D McKay, Oct 25, 2004 */

#define USAGE \
   "multig [-q] [-u|-T|-G|-A|-B] [-e#|-e#:#] [-m#] [-f#] [infile [outfile]]"

#define HELPTEXT \
" Read undirected loop-free graphs and replace their edges with multiple\n\
  edges in all possible ways (multiplicity at least 1).\n\
  Isomorphic multigraphs derived from the same input are suppressed.\n\
  If the input graphs are non-isomorphic then the output graphs are also.\n\
\n\
    -e# | -e#:#  specify a value or range of the total number of edges\n\
                 counting multiplicities\n\
    -m# maximum edge multiplicity (minimum is 1)\n\
	Either -e or -m with a finite maximum must be given\n\
    -f#  Use the group that fixes the first # vertices setwise\n\
    -T  use a simple text output format (nv ne {v1 v2 mult})\n\
    -G  like -T but includes group size as third item (if less than 10^10)\n\
	  The group size does not include exchange of isolated vertices.\n\
    -A  write as the upper triangle of an adjacency matrix, row by row,\n\
        including the diagonal, and preceded by the number of vertices\n\
    -B  write as an integer matrix preceded by the number of rows and\n\
        number of columns, where -f determines the number of rows\n\
    -u  no output, just count them\n\
    -q  suppress auxiliary information\n"

/*************************************************************************/

#include "gtools.h"
#include "naugroup.h"

typedef struct
{
    long hi,lo;
} bigint;

#define ZEROBIG(big) big.hi = big.lo = 0L
#define ADDBIG(big,extra) if ((big.lo += (extra)) >= 1000000000L) \
    { ++big.hi; big.lo -= 1000000000L;}
#define PRINTBIG(file,big) if (big.hi == 0) \
 fprintf(file,"%ld",big.lo); else fprintf(file,"%ld%09ld",big.hi,big.lo)

static bigint nin,ngen,nout;
FILE *outfile;

#define MAXNV 128 
#define MAXNE 1024
static int v0[MAXNE],v1[MAXNE];
static int edgeno[MAXNV][MAXNV];

#define MAXME ((MAXNE+WORDSIZE-1)/WORDSIZE)

static int ix[MAXNE],nix;
static boolean first;
static permutation lastreject[MAXNV];
static boolean lastrejok;
static int rejectlevel;
static unsigned long groupsize;
static unsigned long newgroupsize;
static boolean Gswitch,Tswitch,Aswitch,Bswitch;
static int Brows;

/* #define GROUPTEST */
#ifdef GROUPTEST
static long long totallab;
#endif

/**************************************************************************/

void
writeautom(permutation *p, int n)
/* Called by allgroup. */
{
    int i;

    for (i = 0; i < n; ++i) printf(" %2d",p[i]);
    printf("\n");
}

/**************************************************************************/

static boolean
ismax(permutation *p, int n)
/* test if x^p <= x */
{
    int i,k;

    for (i = 0; i < nix; ++i)
    {
        k = edgeno[p[v1[i]]][p[v0[i]]];

	if (ix[k] > ix[i])
	    return FALSE;
	else if (ix[k] < ix[i])
	    return TRUE;
    }

    ++newgroupsize;
    return TRUE;
}

/**************************************************************************/

void
testmax(permutation *p, int n, int *abort)
/* Called by allgroup2. */
{
    int i,j,k;

    if (first)
    {                       /* only the identity */
	first = FALSE;
	return;
    }

    if (!ismax(p,n))
    {
	*abort = 1;
	for (i = 0; i < n; ++i) lastreject[i] = p[i];
	lastrejok = TRUE;
    }
}

/**************************************************************************/

void
printam(FILE *f, int n, int ne, int *ix)
/* Write adjacency matrix formats */
{
    int i,j,k;

    if (Aswitch)
    {
	fprintf(f,"%d ",n);
	for (i = 0; i < n; ++i)
	    for (j = i; j < n; ++j)
                 fprintf(f," %d",ix[edgeno[i][j]]);
	fprintf(f,"\n");
    }
    else
    {
	if (Brows <= 0 || Brows > n)
	{
	    fprintf(stderr,">E multig: impossible matrix size for output\n");
	    exit(1);
	}
	fprintf(f,"%d %d",Brows,n-Brows);

	for (i = 0; i < Brows; ++i)
	{
	    fprintf(f," ");
            for (j = Brows; j < n; ++j)
                 fprintf(f," %d",ix[edgeno[i][j]]);
	}
        fprintf(f,"\n");
     }
}

/**************************************************************************/

static void
trythisone(grouprec *group, int ne, int n)
{
    int i,k;
    boolean accept;

    ADDBIG(ngen,1);
    nix = ne;
    newgroupsize = 1;

    if (!group || groupsize == 1)
	accept = TRUE;
    else if (lastrejok && !ismax(lastreject,n))
	accept = FALSE;
    else if (lastrejok && groupsize == 2)
	accept = TRUE;
    else
    {
	newgroupsize = 1;
        first = TRUE;

	if (allgroup2(group,testmax) == 0)
	    accept = TRUE;
        else
	    accept = FALSE;
    }

    if (accept)
    {

#ifdef GROUPTEST
	if (groupsize % newgroupsize != 0)
			gt_abort("group size error\n");
	totallab += groupsize/newgroupsize;
#endif

	ADDBIG(nout,1);

	if (outfile)
	{
	    if (Aswitch || Bswitch)
		printam(outfile,n,ne,ix);

	    else
	    {
	        fprintf(outfile,"%d %ld",n,ne);
	        if (Gswitch) fprintf(outfile," %lu",newgroupsize);

                for (i = 0; i < ne; ++i)
	            fprintf(outfile," %d %d %d",v0[i],v1[i],ix[i]);
                fprintf(outfile,"\n");
	    }
	}
        return;
    }
    else
	return;
}

/**************************************************************************/

static void
scan(int level, int ne, int minedges, int maxedges, int sofar,
	int maxmult, grouprec *group, int n)
/* Main recursive scan; returns the level to return to. */
{
    int k;
    int min,max,left;

    if (level == ne)
    {
	trythisone(group,ne,n);
	return;
    }

    left = ne - level - 1;
    min = minedges - sofar - maxmult*left;
    if (min < 1) min = 1;
    max = maxedges - sofar - left;
    if (max > maxmult) max = maxmult;

    for (k = min; k <= max; ++k)
    {
        ix[level] = k;
	scan(level+1,ne,minedges,maxedges,sofar+k,maxmult,group,n);
    }

    return;
}

/**************************************************************************/

static void
multi(graph *g, int nfixed, long minedges, long maxedges, long maxmult,
      int m, int n)
{
    static DEFAULTOPTIONS_GRAPH(options);
    statsblk(stats);
    setword workspace[100];
    grouprec *group;
    long ne;
    int i,j,k,j0,j1,deg;
    set *gi;
    int lab[MAXNV],ptn[MAXNV],orbits[MAXNV];
    set active[(MAXNV+WORDSIZE-1)/WORDSIZE];

    nauty_check(WORDSIZE,m,n,NAUTYVERSIONID);

    j0 = -1;  /* last vertex with degree 0 */
    j1 = n;   /* first vertex with degree > 0 */
 
    ne = 0;
    for (i = 0, gi = g; i < n; ++i, gi += m)
    {
	deg = 0;
	for (j = 0; j < m; ++j) deg += POPCOUNT(gi[j]);
	if (deg == 0) lab[++j0] = i;
	else          lab[--j1] = i;
	ne += deg;
    }
    ne /= 2;

    if (ne == 0 && minedges <= 0)
    {
	trythisone(NULL,0,n);
	return;
    }

    if (maxedges == NOLIMIT) maxedges = ne*maxmult;
    if (maxmult == NOLIMIT) maxmult = maxedges - ne + 1;
    if (maxedges < ne || ne*maxmult < minedges) return;

    if (n > MAXNV || ne > MAXNE)
    {
	fprintf(stderr,">E multig: MAXNV or MAXNE exceeded\n");
	exit(1);
    }

    for (i = 0; i < n; ++i) ptn[i] = 1;
    ptn[n-1] = 0;
    EMPTYSET(active,m);
    if (j0 != n-1) ADDELEMENT(active,j0+1);

    for (i = 0; i <= j0; ++i) ptn[i] = 0;

    for (i = j0+1; i < n; ++i)
	if (lab[i] < nfixed) break;

    if (i != j0+1 && i != n)
    {
	ptn[i-1] = 0;
	ADDELEMENT(active,i);
    }

    options.defaultptn = FALSE;
    options.userautomproc = groupautomproc;
    options.userlevelproc = grouplevelproc;

    nauty(g,lab,ptn,active,orbits,&options,&stats,workspace,100,m,n,NULL);

    if (stats.grpsize2 == 0)
	groupsize = stats.grpsize1 + 0.1;
    else
	groupsize = 0;

    group = groupptr(FALSE);
    makecosetreps(group);

    if (Aswitch || Bswitch)
	for (i = 0; i < n; ++i)
	for (j = 0; j < n; ++j)
	    edgeno[i][j] = -1;

    k = 0;
    for (i = 0, gi = g; i < n; ++i, gi += m)
    {
        for (j = i; (j = nextelement(gi,m,j)) >= 0; )
	{
	    v0[k] = i;
	    v1[k] = j;
	    edgeno[i][j] = edgeno[j][i] = k;
	    ++k;
	}
    }

    lastrejok = FALSE;

    scan(0,ne,minedges,maxedges,0,maxmult,group,n);
}

/**************************************************************************/

main(int argc, char *argv[])
{
	graph *g;
	int m,n,codetype;
	int argnum,j,outcode,nfixed;
	char *arg,sw,*fmt;
	boolean badargs;
	boolean fswitch,uswitch,eswitch,qswitch,mswitch;
	long minedges,maxedges,maxmult;
	double t;
	char *infilename,*outfilename;
	FILE *infile;
#if MAXN
	graph h[MAXN*MAXM];
#else
	DYNALLSTAT(graph,h,h_sz);
#endif

	HELP;

	nauty_check(WORDSIZE,1,1,NAUTYVERSIONID);

	fswitch = Tswitch = Gswitch = FALSE;
	uswitch = eswitch = mswitch = qswitch = FALSE;
	Aswitch = Bswitch = FALSE;
	infilename = outfilename = NULL;

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
		         SWLONG('m',mswitch,maxmult,"multig -m")
		    else SWBOOLEAN('q',qswitch)
		    else SWBOOLEAN('u',uswitch)
		    else SWBOOLEAN('T',Tswitch)
		    else SWBOOLEAN('G',Gswitch)
		    else SWBOOLEAN('A',Aswitch)
		    else SWBOOLEAN('B',Bswitch)
		    else SWINT('f',fswitch,nfixed,"multig -f")
		    else SWRANGE('e',":-",eswitch,minedges,maxedges,"multig -e")
		    else badargs = TRUE;
		}
	    }
	    else
	    {
		++argnum;
		if      (argnum == 1) infilename = arg;
	        else if (argnum == 2) outfilename = arg;
		else                  badargs = TRUE;
	    }
	}

	if (badargs || argnum > 2)
	{
	    fprintf(stderr,">E Usage: %s\n",USAGE);
	    GETHELP;
	    exit(1);
	}

	if ((Gswitch!=0) + (Tswitch!=0) + (uswitch!=0)
              + (Aswitch!=0) + (Bswitch!=0) >= 2)
	    gt_abort(">E multig: -G, -T, -A, -B and -u are incompatible\n");

	if (!Tswitch && !Gswitch && !Aswitch && !Bswitch && !uswitch)
	    gt_abort(">E multig: must use -A, -B, -T, -G or -u\n");

	if (!eswitch)
	{
	    minedges = 0;
	    maxedges = NOLIMIT;
	}
	if (!mswitch) maxmult = NOLIMIT;
	if (!fswitch) nfixed = 0;

	if (Bswitch && nfixed == 0)
	    gt_abort(">E multig: -B requires -f# with #>0\n");
	if (fswitch) Brows = nfixed;

	if (maxedges >= NOLIMIT && maxmult >= NOLIMIT)
	    gt_abort(">E multig: either -e or -m must impose a real limit\n");

	if (!qswitch)
	{
	    fprintf(stderr,">A multig");
	    if (eswitch || mswitch || uswitch || fswitch && nfixed > 0
                    || Tswitch || Gswitch || Aswitch || Bswitch)
		fprintf(stderr," -");
	    if (mswitch) fprintf(stderr,"m%ld",maxmult);
	    if (uswitch) fprintf(stderr,"u");
	    if (Tswitch) fprintf(stderr,"T");
	    if (Tswitch) fprintf(stderr,"G");
	    if (Tswitch) fprintf(stderr,"A");
	    if (Tswitch) fprintf(stderr,"B");
	    if (fswitch) fprintf(stderr,"f%d",nfixed);
	    if (eswitch)
		fprintf(stderr,"e%d:%d",minedges,maxedges);
	    if (argnum > 0) fprintf(stderr," %s",infilename);
	    if (argnum > 1) fprintf(stderr," %s",outfilename);
	    fprintf(stderr,"\n");
	    fflush(stderr);
	}

	if (infilename && infilename[0] == '-') infilename = NULL;
	infile = opengraphfile(infilename,&codetype,FALSE,1);
	if (!infile) exit(1);
	if (!infilename) infilename = "stdin";

	if (uswitch)
	    outfile = NULL;
	else
	{
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
	}

	ZEROBIG(nin); ZEROBIG(ngen); ZEROBIG(nout);

	t = CPUTIME;
	while (TRUE)
	{
	    if ((g = readg(infile,NULL,0,&m,&n)) == NULL) break;
	    ADDBIG(nin,1);
	    multi(g,nfixed,minedges,maxedges,maxmult,m,n);
	    FREES(g);
	}
	t = CPUTIME - t;

        if (!qswitch)
        {
	    fprintf(stderr,">Z ");
	    PRINTBIG(stderr,nin);
            fprintf(stderr," graphs read from %s",infilename);
	 /* fprintf(stderr,"; ");
	    PRINTBIG(stderr,ngen);
            fprintf(stderr,"; %lu multigraphs tested",ngen); */
	    fprintf(stderr,"; ");
	    PRINTBIG(stderr,nout);
            if (!uswitch)
                fprintf(stderr," multigraphs written to %s",outfilename);
            else
		fprintf(stderr," multigraphs generated");
	    fprintf(stderr,"; %.2f sec\n",t);
	}

#ifdef GROUPTEST
	fprintf(stderr,"Group test = %lld\n",totallab);
#endif

	exit(0);
}
