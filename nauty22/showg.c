/* showg.c  version 1.2; B D McKay, Oct 2000.
   Formerly called readg.c.
 
   This is a stand-alone edition of listg.c that does not
   need nauty or any other files.  Use listg in preference
   if you have installed it.  */

#define USAGE "showg [-p#:#l#o#Ftq] [-a|-A|-c|-d|-e] [infile [outfile]]"

#define HELPTEXT \
" Write graphs in human-readable format.\n\
\n\
   infile is the input file in graph6 or sparse6 format\n\
   outfile is the output file\n\
   Defaults are standard input and standard output.\n\
\n\
    -p#, -p#:#, -p#-# : only display one graph or a sequence of\n\
          graphs.  The first graph is number 1.  A second number\n\
          which is empty or zero means infinity.\n\
\n\
    -a  : write the adjacency matrix\n\
    -A  : same as -a with a space between entries\n\
    -d  : write output to satisfy dreadnaut\n\
    -c  : write compact dreadnaut form with minimal line-breaks\n\
    -e  : write a list of edges, preceded by the order and the\n\
          number of edges\n\
\n\
    -o# : specify number of first vertex (default is 0)\n\
    -t  : write upper triangle only (affects -a, -A, -d and default)\n\
    -F  : write a form-feed after each graph except the last\n\
    -l# : specify screen width limit (default 78, 0 means no limit)\n\
          This is not currently implemented with -a or -A.\n\
    -q  : suppress auxiliary output\n\
\n\
    -a, -A, -c, -d and -e are incompatible.\n"

/*
 Version 1.1: Fixed sparse6 input for powers of 2.  May 9, 1998.
 Version 1.3: Declared errno according to ISO C.  August 22, 1998.
*/

/*************************************************************************/

#include <stdio.h>

/* gtools.h : General header for gtools programs. */

#ifndef MAXN 
#define MAXN  0
#endif
#define G6LEN(n)  (((n)*((n)-1)/2+5)/6+(n<=SMALLN?1:4))
		/* Exact length of graph6 code except for \n\0 */

#if defined(__unix) || defined(__unix__) || defined(unix) || \
    defined(__ppc__)
#include <errno.h>
#else
int errno = 0;
#endif
#define ABORT(msg) {if (errno != 0) perror(msg); exit(1);}

extern long ftell(FILE*);

#define BIAS6 63
#define MAXBYTE 126
#define SMALLN 62
#define TOPBIT6 32
#define C6MASK 63

#define GRAPH6_HEADER ">>graph6<<"
#define SPARSE6_HEADER ">>sparse6<<"

#define GRAPH6         1
#define SPARSE6        2
#define UNKNOWN_TYPE 256
#define HAS_HEADER   512

#define ARG_OK 0
#define ARG_MISSING 1
#define ARG_TOOBIG 2
#define ARG_ILLEGAL 3

#define MAXARG 2000000000L
#define NOLIMIT (MAXARG+1L)

#define SWBOOLEAN(c,bool) if (sw==c) bool=TRUE;
#define SWINT(c,bool,val,id) if (sw==c) \
        {bool=TRUE;arg_int(&arg,&val,id);}
#define SWRANGE(c,bool,val1,val2,id) if (sw==c) \
	{bool=TRUE;arg_range(&arg,&val1,&val2,id);}

#define FREES free
#define ALLOCS calloc

#define DYNALLSTAT(type,name,name_sz) static type *name; static size_t name_sz=0
#define DYNALLOC1(type,name,name_sz,sz,msg) \
 if ((size_t)(sz) > name_sz) \
 { if (name_sz) FREES(name); name_sz = (sz); \
 if ((name=(type*)ALLOCS(sz,sizeof(type))) == NULL) alloc_error(msg);}
#define DYNALLOC2(type,name,name_sz,sz1,sz2,msg) \
 if ((size_t)(sz1)*(size_t)(sz2) > name_sz) \
 { if (name_sz) FREES(name); name_sz = (size_t)(sz1)*(size_t)(sz2); \
 if ((name=(type*)ALLOCS((sz1),(sz2)*sizeof(type))) == NULL) alloc_error(msg);}
#define DYNFREE(name,name_sz) if (name_sz) {FREES(name); name_sz = 0;}
#define DYNREALLOC(type,name,name_sz,sz,msg) \
 {if ((size_t)(sz) > name_sz) \
 { if ((name = (type*)realloc(name,(sz)*sizeof(type))) == NULL) \
      alloc_error(msg); else name_sz = (sz);}}

#define alloc_error gt_abort

#ifdef __STDC__
#include <stddef.h>
#include <stdlib.h>
#else
#include <sys/types.h>
extern char *calloc();
extern char *malloc();
extern char *realloc();
#endif

#ifdef __alpha
typedef unsigned int setword;
#else
typedef unsigned long setword;
#endif
typedef setword set;
typedef setword graph;
typedef int boolean;

static setword bit[32]=
  {020000000000,010000000000,04000000000,02000000000,
   01000000000,0400000000,0200000000,0100000000,040000000,
   020000000,010000000,04000000,02000000,01000000,0400000,
   0200000,0100000,040000,020000,010000,04000,02000,01000,
   0400,0200,0100,040,020,010,04,02,01};
static int leftbit[] =
  {8,7,6,6,5,5,5,5,4,4,4,4,4,4,4,4,
   3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
   2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
   2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
static int labelorg = 0;

#define WORDSIZE 32
#define FIRSTBIT(x) ((x) & 037777600000 ? ((x) & 037700000000 ? \
                     leftbit[((x)>>24) & 0377] : 8+leftbit[(x)>>16]) \
                    : ((x) & 0177400 ? 16+leftbit[(x)>>8] : 24+leftbit[x]))
#define BITMASK(x)  (017777777777 >> (x)) /* setword whose rightmost
  WORDSIZE-x-1 (numbered) bits are 1 and the rest 0 (0 <= x < WORDSIZE) */
#define TIMESWORDSIZE(w) ((w)<<5)
#define SETWD(pos) ((pos)>>5)
#define SETBT(pos) ((pos)&037)
#define ISELEMENT(setadd,pos)  (((setadd)[SETWD(pos)] & bit[SETBT(pos)]) != 0)
#define ADDELEMENT(setadd,pos)  ((setadd)[SETWD(pos)] |= bit[SETBT(pos)])
#define GRAPHROW(g,v,m) ((set*)(g) + (long)(v) * (long)(m))

#define FALSE 0
#define TRUE  1

/************************************************************************/

#ifndef SEEK_SET
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#endif

#ifndef SEEK_CUR
#define SEEK_CUR SEEK_CURRENT
#endif

static long ogf_linelen;

/************************************************************************/

static void
gt_abort(msg)     /* Write message and halt. */
char *msg;
{
	if (msg) fprintf(stderr,msg);
	ABORT(">E gtools");
}

/*****************************************************************************
*                                                                            *
*  itos(i,s) converts the int i to a nul-terminated decimal character        *
*  string s.  The value returned is the number of characters excluding       *
*  the nul.                                                                  *
*                                                                            *
*  GLOBALS ACCESSED: NONE                                                    *
*                                                                            *
*****************************************************************************/

static int
itos(i,s)
register int i;
register char *s;
{
        register int digit,j,k;
        register char c;
        int ans;

        if (i < 0)
        {
            k = 0;
            i = -i;
            j = 1;
            s[0] = '-';
        }
        else
        {
            k = -1;
            j = 0;
        }

        do
        {
            digit = i % 10;
            i = i / 10;
            s[++k] = digit + '0';
        }
        while (i);

        s[k+1] = '\0';
        ans = k + 1;

        for (;j < k; ++j, --k)
        {
            c = s[j];
            s[j] = s[k];
            s[k] = c;
        }

        return(ans);
}

/*****************************************************************************
*                                                                            *
*  nextelement(set1,m,pos) = the position of the first element in set set1   *
*  which occupies a position greater than pos.  If no such element exists,   *
*  the value is -1.  pos can have any value less than n, including negative  *
*  values.                                                                   *
*                                                                            *
*  GLOBALS ACCESSED: none                                                    *
*                                                                            *
*****************************************************************************/

static int
nextelement(set1,m,pos)
register set *set1;
int m,pos;
{
        register setword setwd;
        register int w;

        if (pos < 0)
        {
            w = 0;
            setwd = set1[0];
        }
        else
        {
            w = SETWD(pos);
            setwd = set1[w] & BITMASK(SETBT(pos));
        }

        for (;;)
        {
            if (setwd != 0)
                return(TIMESWORDSIZE(w) + FIRSTBIT(setwd));
            if (++w == m) return -1;
            setwd = set1[w];
        }
}

/*********************************************************************
opengraphfile(filename,codetype,assumefixed,position) 
          opens and positions a file for reading graphs.

  filename = the name of the file to open 
		(NULL means stdin, assumed already open)
  codetype   = returns a code for the format.
		This is a combination of SPARSE6, GRAPH6,
		UNKNOWN_TYPE and HAS_HEADER.  If a header is
		present, that overrides the data.  If there is
                no header, the first graph is examined.
  assumefixed = nonzero if files other than stdin should be assumed to
		be seekable and have equal record sizes.
		Ignored if there is a sparse6 header or the first
		graph has sparse6 format.
  position = the number of the record to position to
		(the first is number 1; 0 and -NOLIMIT also mean
                 to position at start)

  If the file starts with ">", there must be a header, either
  GRAPH6_HEAD or SPARSE6_HEAD.  Otherwise opengraphfile() fails.

  The value returned is a file pointer or NULL.  
  If assumedfixed is not zero and position > 1, the global variable
  ogf_linelen is set to the length (including \n) of the length of the 
  first record.

**********************************************************************/

static FILE*
opengraphfile(filename,codetype,assumefixed,position)
char *filename;
int *codetype,assumefixed;
long position;
{
	FILE *f;
	int c,firstc;
	long i,l,pos,pos1,pos2;
	boolean bad_header;

	if (filename == NULL)
	    f = stdin;
	else
	{
	    f = fopen(filename,"r");
	    if (f == NULL)
	    {
		fprintf(stderr,">E opengraphfile: can't open %s\n",filename);
		return NULL;
	    }
	}

	firstc = c = getc(f);
	if (c == EOF)
	{
	    *codetype = GRAPH6;
	    return f;
	}

	if (c != '>')
	{
	    *codetype = firstc == ':' ? SPARSE6 : GRAPH6;
	    ungetc(c,f);
	}
	else
	{
	    bad_header = FALSE;
	    if ((c = getc(f)) == EOF || c != '>')
	        bad_header = TRUE;
	    if (!bad_header && ((c = getc(f)) == EOF || c != 'g' && c != 's'))
		bad_header = TRUE;	
	    if (!bad_header && c == 'g')
	    {
		if ((c = getc(f)) == EOF || c != 'r' ||
		    (c = getc(f)) == EOF || c != 'a' ||
		    (c = getc(f)) == EOF || c != 'p' ||
		    (c = getc(f)) == EOF || c != 'h' ||
		    (c = getc(f)) == EOF || c != '6' ||
		    (c = getc(f)) == EOF || c != '<' ||
		    (c = getc(f)) == EOF || c != '<')
			bad_header = TRUE;
		else
		    *codetype = GRAPH6 | HAS_HEADER;
	    }
	    else if (!bad_header && c == 's')
	    {
		if ((c = getc(f)) == EOF || c != 'p' ||
		    (c = getc(f)) == EOF || c != 'a' ||
		    (c = getc(f)) == EOF || c != 'r' ||
		    (c = getc(f)) == EOF || c != 's' ||
		    (c = getc(f)) == EOF || c != 'e' ||
		    (c = getc(f)) == EOF || c != '6' ||
		    (c = getc(f)) == EOF || c != '<' ||
		    (c = getc(f)) == EOF || c != '<')
			bad_header = TRUE;
		else
		    *codetype = SPARSE6 | HAS_HEADER;
	    }
	    if (bad_header)
	    {
		fprintf(stderr,">E opengraphfile: illegal header in %s\n",
			filename == NULL ? "stdin" : filename);
		*codetype = UNKNOWN_TYPE | HAS_HEADER;
		return NULL;
	    }
	}

	if (position <= 1) return f;

	if (filename == NULL || !assumefixed || (*codetype&SPARSE6)
			     || firstc == ':')
	{
	    l = 1;
	    while ((c = getc(f)) != EOF)
	    {
	        if (c == '\n')
		{
		    ++l;
		    if (l == position) break;
		}
	    }
	    if (l == position) return f;

	    fprintf(stderr,
               ">E opengraphfile: can't find line %ld in %s\n",position,
		filename == NULL ? "stdin" : filename);
	    return NULL;
	}
	else
	{
	    pos1 = ftell(f);
	    if (pos1 < 0)
	    {
		fprintf(stderr,">E opengraphfile: error on first ftell\n");
		return NULL;
	    }

	    for (i = 1; (c = getc(f)) != EOF && c != '\n'; ++i) {}
	    ogf_linelen = i;

	    if (c == EOF)
	    {
		fprintf(stderr,
		        ">E opengraphfile: required record no present\n");
		return NULL;
	    }
	    
	    pos2 = ftell(f);
	    if (pos2 < 0)
            {
                fprintf(stderr,">E opengraphfile: error on second ftell\n");
                return NULL;
            }

	    pos = pos1 + (position-1)*(pos2-pos1);
	    if (fseek(f,pos,SEEK_SET) < 0)
	    {
		fprintf(stderr,">E opengraphfile: seek failed\n");
		return NULL;
	    }
	}

	return f;
}

/*********************************************************************/

static char*
getline(f)     /* read a line with error checking */
FILE *f;       /* includes \n (if present) and \0.
                  Immediate EOF causes NULL return. */
{
	DYNALLSTAT(char,s,s_sz);
	int c;
	long i;

	DYNALLOC1(char,s,s_sz,500,"getline");

	i = 0;
	while ((c = getc(f)) != EOF && c != '\n')
	{
	    if (i == s_sz-2) DYNREALLOC(char,s,s_sz,s_sz+1000,"getline");
	    s[i++] = c;
	}

	if (i == 0 && c == EOF) return NULL;

	if (c == '\n') s[i++] = '\n';
	s[i] = '\0';
	return s;
}

/****************************************************************************/

static int
graphsize(s)
char *s;         /* Get size of graph out of graph6 or sparse6 string. */
{
	char *p;
	int n;

	if (s[0] == ':') p = s+1;
	else             p = s;
	n = *p++ - BIAS6;

	if (n > SMALLN) 
	{
	    n = *p++ - BIAS6;
	    n = (n << 6) | (*p++ - BIAS6);
	    n = (n << 6) | (*p++ - BIAS6);
        }
	return n;
}

/****************************************************************************/

static void
stringtograph(s,g,m)
char *s;          /* Convert string (graph6 or sparse6 format) to graph. */
graph *g;         /* Assumes g is big enough to hold it.                 */
int m;
{
	char *p;
	int n,i,j,k,v,x,nb;
	long ii;
	set *gi,*gj;

	n = graphsize(s);

	p = s + 1 + (s[0] == ':');
	if (n > SMALLN) p += 3;

	if (TIMESWORDSIZE(m) < n)
	    gt_abort(">E stringtograph: impossible m value\n");

	for (ii = (long)m*n; --ii >= 0;)
	    g[ii] = 0;

	if (s[0] != ':')       /* graph6 format */
	{
	    k = 1;
	    for (j = 1; j < n; ++j)
	    {
	        gj = GRAPHROW(g,j,m);
    
	        for (i = 0; i < j; ++i)
	        {
	            if (--k == 0)
	            {
		        k = 6;
		        x = *(p++) - BIAS6;
	            }
	    
	            if (x & TOPBIT6)
	            {
		        gi = GRAPHROW(g,i,m);
		        ADDELEMENT(gi,j);
		        ADDELEMENT(gj,i);
	            }
	            x <<= 1;
	        }
	    }
	}
	else    /* sparse6 format */
	{
	    for (i = n-1, nb = 0; i != 0 ; i >>= 1, ++nb)
	    {}

	    k = 1;
	    v = 0;
	    for (;;)
	    {
		if (--k == 0)
		{
		    k = 6;
		    if (*p == '\n' || *p == '\0') break;
		    else x = *p - BIAS6;
		    ++p;
		}
		else
		    x <<= 1;

		if (x & TOPBIT6) ++v;
		j = 0;
		for (i = 0; i < nb; ++i)
		{
		    if (--k == 0)
		    {
		 	k = 6;
			if (*p == '\n' || *p == '\0') break;
			else x = *p - BIAS6;
			++p;
		    }
		    else
			x <<= 1;
		    if (x & TOPBIT6) j = (j << 1) | 1;
		    else             j <<= 1;
	 	}
		if (i < nb) break;
		if (j > v)
		    v = j;
		else if (v < n)
		{
		    ADDELEMENT(GRAPHROW(g,v,m),j);
		    ADDELEMENT(GRAPHROW(g,j,m),v);
		}
	    }
	}
}

/***********************************************************************/

static graph*                 /* read graph into nauty format */
readg(f,g,reqm,pm,pn)  /* graph6 and sparse6 formats are supported */
FILE *f;      /* an open file */
graph *g;     /* place to put the answer (NULL for dynamic allocation) */
int reqm;     /* the requested value of m (0 => compute from n) */
int *pm;      /* the actual value of m */
int *pn;      /* the value of n */
{
	char *s,*p,*readg_line;
	int m,n,readg_code;

	if ((readg_line = getline(f)) == NULL) return NULL;

	s = readg_line;
	if (s[0] == ':')
	{
	    readg_code = SPARSE6;
	    p = s + 1;
	}
	else
	{
	    readg_code = GRAPH6;
            p = s;
	}

	while (*p >= BIAS6 && *p <= MAXBYTE) 
	    ++p;
	if (*p == '\0')
	    gt_abort(">E showg: missing newline\n");
	else if (*p != '\n')
	    gt_abort(">E showg: illegal character\n");

	n = graphsize(s);
	if (readg_code == GRAPH6 && p - s != G6LEN(n))
	{
	    fprintf(stderr,"p-s=%d G6LEN(%d)=%d\n",(int)(p-s),n,G6LEN(n));
	    gt_abort(">E showg: truncated graph6 line\n");
	}

	if (reqm > 0 && TIMESWORDSIZE(reqm) > n)
	    gt_abort(">E showg: reqm too small\n");
	else if (reqm > 0)
	    m = reqm;
	else
	    m = (n + WORDSIZE - 1) / WORDSIZE;

	if (g == NULL)
	{
	    if ((g = (graph*)ALLOCS(n,m*sizeof(graph))) == NULL)
		gt_abort(">E showg: malloc failed\n");
	}

	*pn = n;
	*pm = m;

	stringtograph(s,g,m);
	return g;
}

/**************************************************************************/

static int
longvalue(ps,l)
char **ps;
long *l;
{
	boolean neg,pos;
	long sofar,last;
	char *s;

	s = *ps;
	pos = neg = FALSE;
	if (*s == '-')
	{
	    neg = TRUE;
	    ++s;
	}
	else if (*s == '+')
	{
	    pos = TRUE;
	    ++s;
	}

	if (*s < '0' || *s > '9') 
	{
	    *ps = s;
	    return (pos || neg) ? ARG_ILLEGAL : ARG_MISSING;
	}

	sofar = 0;

	for (; *s >= '0' && *s <= '9'; ++s)
	{
	    last = sofar;
	    sofar = sofar * 10 + (*s - '0');
	    if (sofar < last || sofar > MAXARG)
	    {
		*ps = s;
		return ARG_TOOBIG;
	    }
	}
	*ps = s;
	*l = neg ? -sofar : sofar;
	return ARG_OK;
}
	
/*************************************************************************/

static void
arg_int(ps,val,id)
char **ps;
int *val;
char *id;
{
	int code;
	long longval;

	code = longvalue(ps,&longval);
	*val = longval;
	if (code == ARG_MISSING || code == ARG_ILLEGAL)
	{
	    fprintf(stderr,">E %s: missing argument value\n",id);
	    gt_abort(NULL);
	}
	else if (code == ARG_TOOBIG || *val != longval)
	{
	    fprintf(stderr,">E %s: argument value too large\n",id);
	    gt_abort(NULL);
	}
}

/************************************************************************/

static void
arg_range(ps,val1,val2,id)
char **ps;
long *val1,*val2;
char *id;
{
	int code;
	char *s;

	s = *ps;
	code = longvalue(&s,val1);
	if (code != ARG_MISSING)
	{
	    if (code == ARG_ILLEGAL)
	    {
		fprintf(stderr,">E %s: bad range\n",id);
		gt_abort(NULL);
	    }
	    else if (code == ARG_TOOBIG)
	    {
		fprintf(stderr,">E %s: value too big\n",id);
		gt_abort(NULL);
	    }
	}
	else if (*s != ':' && *s != '-')
	{
	    fprintf(stderr,">E %s: missing value\n",id);
	    gt_abort(NULL);
	}
	else
	    *val1 = -NOLIMIT;

	if (*s == ':' || *s == '-')
	{
	    ++s;
	    code = longvalue(&s,val2);
	    if (code == ARG_MISSING)
		*val2 = NOLIMIT;
	    else if (code == ARG_TOOBIG)
	    {
		fprintf(stderr,">E %s: value too big\n",id);
		gt_abort(NULL);
	    }
	    else if (code == ARG_ILLEGAL)
	    {
		fprintf(stderr,">E %s: illegal range\n",id);
		gt_abort(NULL);
	    }
	}
	else
	    *val2 = *val1;

	*ps = s;
}

/************************************************************************/

#define LABELORG 0   /* number of first vertex (any integer >= 0) */
#define LINELEN 78   /* max characters per line (0 = no limit) */

static FILE *infile,*outfile;
static long nin;
extern int labelorg;

/*****************************************************************************
*                                                                            *
*  putsetx(f,set1,curlenp,linelength,m,compress,start)   writes the set      *
*  set1 to file f using at most linelength characters per line (excluding    *
*  '\n').   Set elements less than or equal to start are ignored.            *
*  *curlenp is the number of characters on the line so far; it is updated.   *
*  A range j1,j1+1,...,j2 for j2-j1>=2 is written as "j1:j2" if compress     *
*  is nonzero (eg. TRUE); otherwise each element is written separately.      *
*  No final '\n' is written.  labelorg is used.                              *
*                                                                            *
*  FUNCTIONS CALLED: nextelement(),itos()                                    *
*                                                                            *
*****************************************************************************/

void
putsetx(f,set1,curlenp,linelength,m,compress,start)
FILE *f;
set *set1;
int linelength,m,*curlenp;
boolean compress;
{
        int slen,j1,j2;
        char s[40];
	boolean first;

	first = TRUE;
        j1 = start;
        while ((j1 = nextelement(set1,m,j1)) >= 0)
        {
            j2 = j1;
            if (compress)
            {
                while (nextelement(set1,m,j2) == j2 + 1)
                    ++j2;
                if (j2 == j1+1)
                    j2 = j1;
            }
            slen = itos(j1 + labelorg,s);
            if (j2 >= j1 + 2)
            {
                s[slen] = ':';
                slen += 1 + itos(j2 + labelorg,&s[slen+1]);
            }

            if (*curlenp + slen + 1 >= linelength)
            {
                fprintf(f,"\n ");
                *curlenp = 1;
            }
	    if (first)
	    {
                fprintf(f,"%s",s);
                *curlenp += slen;
		first = FALSE;
	    }
	    else
            {    
                fprintf(f," %s",s);
                *curlenp += slen + 1;
            }
            j1 = j2;
        }
}

/*****************************************************************************
*                                                                            *
*  STOLEN FROM naututil.c                                                    *
*  putgraphx(f,g,linelength,m,n) writes a list of the edges of g to f        *
*  using at most linelength characters per line (excluding '\n').            *
*  If triang, only write the upper triangle.                                 *
*  labelorg is used.                                                         *
*                                                                            *
*****************************************************************************/

void
putgraphx(f,g,linelength,triang,m,n)
FILE *f;
graph *g;
int linelength,m,n;
boolean triang;
{
        int i,curlen;
        set *pg;

        for (i = 0, pg = g; i < n; ++i, pg += m)
        {
            fprintf(f,"%3d : ",i + labelorg);
            curlen = 7;
            putsetx(f,pg,&curlen,linelength,m,FALSE,triang ? i-1 : -1);
            fprintf(f,";\n");
        }
}

/***************************************************************************/

void
putedges(f,g,linelength,m,n)   /* write list of edges */
FILE *f;
graph *g;
int linelength,m,n;
{
	int i,j,curlen,ne;
	char s[20];
	set *pg;

	ne = 0;
        for (i = 0, pg = g; i < n; ++i, pg += m)
	{
	    for (j = i-1; (j = nextelement(pg,m,j)) >= 0;)
		++ne;
	}

	fprintf(f,"%d %d\n",n,ne);
	curlen = 0;
        for (i = 0, pg = g; i < n; ++i, pg += m)
	{
	    for (j = i-1; (j = nextelement(pg,m,j)) >= 0;)
	    { 
		if (curlen > linelength - 10 && linelength > 0)
		{
		    fprintf(f,"\n");
		    curlen = 0;
		}
		if (curlen > 0)
		{
		    fprintf(f,"  ");
		    curlen += 2;
		}
		curlen += itos(i+labelorg,s);
		fprintf(f,s);
		fprintf(f," ");
		curlen += 1 + itos(j+labelorg,s);
		fprintf(f,s);
	    }
	}
	fprintf(f,"\n");
}

/***************************************************************************/

void
putcgraph(f,g,linelength,m,n)  /* write compressed form */
FILE *f;
graph *g;
int linelength,m,n;
{
        int i,curlen;
	int semicolons;
	char s[20];
        set *pg;

	curlen = itos(n,s)+2;
	fprintf(f,";n%sg",s);

	semicolons = 0;
        for (i = 0, pg = g; i < n; ++i, pg += m)
        {
	    if (nextelement(pg,m,i-1) >= 0)
	    {
		while (semicolons > 0)
		{
		    if (curlen >= linelength-1 && linelength > 0)
		    {
			fprintf(f,"\n ");
			curlen = 1;
		    }
		    fprintf(f,";");
		    ++curlen;
		    --semicolons;
		}
                putsetx(f,pg,&curlen,linelength,m,FALSE,i-1);
                semicolons = 1;
	    }
	    else
		++semicolons;
        }
	fprintf(f,".\n");
}

/**************************************************************************/

static void
putam(f,g,linelength,space,triang,m,n)   /* write adjacency matrix */
FILE *f;
graph *g;
int linelength,m,n;
boolean space,triang;
{
 	register set *gi;
	register int i,j;
	boolean first;

	for (i = 0, gi = (set*)g; i < n - (triang!=0); ++i, gi += m)
	{
	    first = TRUE;
	    for (j = triang ? i+1 : 0; j < n; ++j)
	    {
		if (!first && space) putc(' ',f);
		else                 first = FALSE;
		if (ISELEMENT(gi,j)) putc('1',f);
		else                 putc('0',f);
	    }
	    putc('\n',f);
	}
}

/**************************************************************************/
/**************************************************************************/

main(argc,argv)
int argc;
char *argv[];
{
	graph *g;
	int m,n,codetype;
	int argnum,j;
	char *arg,sw;
	boolean badargs;
	long maxin,pval1,pval2;
	boolean fswitch,pswitch,cswitch,dswitch;
	boolean aswitch,lswitch,oswitch,Fswitch;
	boolean Aswitch,eswitch,tswitch,qswitch;
	int linelength;
	char *infilename,*outfilename;

	if (argc > 1 && strcmp(argv[1],"-help") == 0)
	{
	    printf("Usage: %s\n\n%s",USAGE,HELPTEXT);
	    exit(0);
	}

	if (sizeof(setword) < 4)
	{
	    fprintf(stderr,">E showg: setword too small\n");
	    fprintf(stderr,"   Please report this to bdm@cs.anu.edu.au\n");
	    exit(1);
	}

	fswitch = pswitch = cswitch = dswitch = FALSE;
	aswitch = lswitch = oswitch = Fswitch = FALSE;
	Aswitch = eswitch = tswitch = qswitch = FALSE;
	infilename = outfilename = NULL;
	linelength = LINELEN;
	labelorg = 0;

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
			 SWBOOLEAN('a',aswitch)
		    else SWBOOLEAN('A',Aswitch)
		    else SWBOOLEAN('c',cswitch)
		    else SWBOOLEAN('d',dswitch)
		    else SWBOOLEAN('e',eswitch)
		    else SWBOOLEAN('f',fswitch)
		    else SWBOOLEAN('F',Fswitch)
		    else SWBOOLEAN('t',tswitch)
		    else SWBOOLEAN('q',qswitch)
		    else SWRANGE('p',pswitch,pval1,pval2,"showg -p")
		    else SWINT('l',lswitch,linelength,"showg -l")
		    else SWINT('o',oswitch,labelorg,"listo -o")
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

	if (labelorg < 0) gt_abort(">E showg: negative origin forbidden.\n");

	if ((aswitch!=0) + (Aswitch!=0) + (eswitch!=0) 
	    		 + (dswitch!=0) + (cswitch!=0) > 1)
	    gt_abort(">E showg: -aAecd are incompatible\n");

	if (badargs)
	{
	    fprintf(stderr,">E Usage: %s\n",USAGE);
	    fprintf(stderr,"Use showg -help to see a list of the options.\n");
	    exit(1);
	}

	if (!pswitch || pval1 < 1) pval1 = 1;

	if (infilename && infilename[0] == '-') infilename = NULL;
	infile = opengraphfile(infilename,&codetype,fswitch,
			       pswitch ? pval1 : 1);
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

	nin = 0;
	if (!pswitch || pval2 == NOLIMIT)
	    maxin = NOLIMIT;
	else if (pval1 < 1) maxin = pval2;
	else                maxin = pval2 - pval1 + 1;
	while (nin < maxin || maxin == NOLIMIT)
	{
	    if ((g = readg(infile,NULL,0,&m,&n)) == NULL) break;
	    ++nin;

	    if (Fswitch && nin > 1) fprintf(outfile,"\f");

	    if (cswitch)
		putcgraph(outfile,g,linelength,m,n);
	    else if (dswitch)
	    {
		if (qswitch)
		    fprintf(outfile,"%d\n",n);
		else
		{
		    fprintf(outfile,"\n!Graph %ld.\n",pval1+nin-1);
		    fprintf(outfile,"n=%d $=%d g\n",n,labelorg);
		}
		putgraphx(outfile,g,linelength,tswitch,m,n);
		if (!qswitch) fprintf(outfile,"$$\n");
	    }
	    else
            {
		if (qswitch)
		{
		    if (!eswitch) fprintf(outfile,"%d\n",n);
		}
                else fprintf(outfile,"\nGraph %ld, order %d.\n",
				     pval1+nin-1,n);
	        if (aswitch|Aswitch)
		    putam(outfile,g,linelength,Aswitch,tswitch,m,n);
		else if (eswitch)
		    putedges(outfile,g,linelength,m,n);
	        else
	            putgraphx(outfile,g,linelength,tswitch,m,n);
            }
	    FREES(g);
	}

	exit(0);
}
