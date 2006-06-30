/* labelg.c version 1.1; B D McKay, Feb 23 2000 */

#define USAGE "labelg [-qsg] [-fxxx] [-i# -k:#:# -K#] [infile [outfile]]"

#define HELPTEXT \
" Canonically label a file of graphs.\n\
\n\
    -s  force output to sparse6 format\n\
    -g  force output to graph6 format\n\
        If neither -s or -g are given, the output format is\n\
        determined by the header or, if there is none, by the\n\
        format of the first input graph.\n\
\n\
    The output file will have a header if and only if the input file does.\n\
\n\
    -fxxx  Specify a partition of the point set.  xxx is any\n\
        string of ASCII characters except nul.  This string is\n\
        considered extended to infinity on the right with the\n\
        character 'z'.  One character is associated with each point,\n\
        in the order given.  The labelling used obeys these rules:\n\
         (1) the new order of the points is such that the associated\n\
        characters are in ASCII ascending order\n\
         (2) if two graphs are labelled using the same string xxx,\n\
        the output graphs are identical iff there is an\n\
        associated-character-preserving isomorphism between them.\n\
        No option can be concatenated to the right of -f.\n\
\n\
    -i#  select an invariant (1 = twopaths, 2 = adjtriang(K), 3 = triples,\n\
        4 = quadruples, 5 = celltrips, 6 = cellquads, 7 = cellquins,\n\
        8 = distances(K), 9 = indsets(K), 10 = cliques(K), 11 = cellcliq(K),\n\
       12 = cellind(K), 13 = adjacencies, 14 = cellfano, 15 = cellfano2)\n\
    -k#:#  select mininvarlevel and maxinvarlevel (default 1:1)\n\
    -K#   select invararg (default 3)\n\
\n\
    -q  suppress auxiliary information\n"


/*************************************************************************/

#include "gtools.h"
#include "nautinv.h"

static struct invarrec
{
    void (*entrypoint)(graph*,int*,int*,int,int,int,permutation*,
                      int,boolean,int,int);
    char *name;
} invarproc[]
    = {{NULL, "none"},
       {twopaths,    "twopaths"},
       {adjtriang,   "adjtriang"},
       {triples,     "triples"},
       {quadruples,  "quadruples"},
       {celltrips,   "celltrips"},
       {cellquads,   "cellquads"},
       {cellquins,   "cellquins"},
       {distances,   "distances"},
       {indsets,     "indsets"},
       {cliques,     "cliques"},
       {cellcliq,    "cellcliq"},
       {cellind,     "cellind"},
       {adjacencies, "adjacencies"},
       {cellfano,    "cellfano"},
       {cellfano2,   "cellfano2"}};
#define NUMINVARS ((int)(sizeof(invarproc)/sizeof(struct invarrec)))

static long orbtotal;
static double unorbtotal;
extern int gt_numorbits;

/**************************************************************************/

main(int argc, char *argv[])
{
	graph *g;
	int m,n,codetype;
	int argnum,j,outcode;
	char *arg,sw,*fmt;
	boolean badargs;
	boolean sswitch,gswitch,qswitch,fswitch,Oswitch;
	boolean iswitch,kswitch,Kswitch,Mswitch;
	int inv,mininvarlevel,maxinvarlevel,invararg;
	long minil,maxil;
	double t;
	char *infilename,*outfilename;
	FILE *infile,*outfile;
	long nin;
	int ii,secret;
#if MAXN
	graph h[MAXN*MAXM];
#else
	DYNALLSTAT(graph,h,h_sz);
#endif

	HELP;

	nauty_check(WORDSIZE,1,1,NAUTYVERSIONID);

	sswitch = gswitch = qswitch = FALSE;
	fswitch = Oswitch = Mswitch = FALSE;
	iswitch = kswitch = Kswitch = FALSE;
	infilename = outfilename = NULL;
	inv = 0;

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
		         SWBOOLEAN('s',sswitch)
		    else SWBOOLEAN('g',gswitch)
		    else SWBOOLEAN('q',qswitch)
		    else SWBOOLEAN('O',Oswitch)
		    else SWINT('i',iswitch,inv,"labelg -i")
		    else SWINT('K',Kswitch,invararg,"labelg -K")
		    else SWRANGE('k',":-",kswitch,minil,maxil,"labelg -k")
		    else if (sw == 'f')
		    {
			fswitch = TRUE;
			fmt = arg;
			break;
		    }
		    else SWINT('M',Mswitch,secret,"labelg -M")
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

	if (sswitch && gswitch) 
            gt_abort(">E labelg: -s and -g are incompatible\n");

	if (iswitch && (inv > 15))
	    gt_abort(">E labelg: -i value must be 0..15\n");

	if (iswitch && inv == 0) iswitch = FALSE;

	if (iswitch)
	{
	    if (kswitch)
	    {
		mininvarlevel = minil;
		maxinvarlevel = maxil;
	    }
	    else
		mininvarlevel = maxinvarlevel = 1;
	    if (!Kswitch) invararg = 3;
	}

	if (!Mswitch) secret = 1;

	if (badargs || argnum > 2)
	{
	    fprintf(stderr,">E Usage: %s\n",USAGE);
	    GETHELP;
	    exit(1);
	}

	if (!qswitch)
	{
	    fprintf(stderr,">A labelg");
	    if (sswitch || gswitch || fswitch || iswitch)
		fprintf(stderr," -");
	    if (sswitch) fprintf(stderr,"s");
	    if (gswitch) fprintf(stderr,"g");
	    if (fswitch) fprintf(stderr,"f%s",fmt);
	    if (iswitch)
		fprintf(stderr,"i=%s[%d:%d,%d]",invarproc[inv].name,
		        mininvarlevel,maxinvarlevel,invararg);
	    if (argnum > 0) fprintf(stderr," %s",infilename);
	    if (argnum > 1) fprintf(stderr," %s",outfilename);
	    fprintf(stderr,"\n");
	    fflush(stderr);
	}

	if (infilename && infilename[0] == '-') infilename = NULL;
	infile = opengraphfile(infilename,&codetype,FALSE,1);
	if (!infile) exit(1);
	if (!infilename) infilename = "stdin";

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

	if (sswitch || !gswitch && (codetype&SPARSE6)) outcode = SPARSE6;
	else                                           outcode = GRAPH6;

	if (!fswitch) fmt = NULL;

	if (codetype&HAS_HEADER)
	{
	    if (outcode == SPARSE6) writeline(outfile,SPARSE6_HEADER);
	    else    		    writeline(outfile,GRAPH6_HEADER);
	}

	nin = 0;
	orbtotal = 0;
	unorbtotal = 0.0;
	t = CPUTIME;
	while (TRUE)
	{
	    if ((g = readg(infile,NULL,0,&m,&n)) == NULL) break;
	    ++nin;
#if !MAXN
	    DYNALLOC2(graph,h,h_sz,n,m,"labelg");
#endif
	    for (ii = 0; ii < secret; ++ii)
	        fcanonise_inv(g,m,n,h,fmt,invarproc[inv].entrypoint,
			      mininvarlevel,maxinvarlevel,invararg);
	    orbtotal += gt_numorbits;
	    unorbtotal += 1.0 / gt_numorbits;
	    if (outcode == SPARSE6) writes6(outfile,h,m,n);
	    else                    writeg6(outfile,h,m,n);
	    FREES(g);
	}
	t = CPUTIME - t;

	if (Oswitch)
	    fprintf(stderr,">C orbit totals = %ld %15.8f\n",
			   orbtotal,unorbtotal);

        if (!qswitch)
            fprintf(stderr,
                    ">Z  %ld graphs labelled from %s to %s in %3.2f sec.\n",
                    nin,infilename,outfilename,t);

	exit(0);
}
