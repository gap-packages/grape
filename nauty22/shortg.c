/* shortg.c  version 1.4; B D McKay, August 20, 2002. */

/* TODO:  temporary file placement, search for sort program */

#define USAGE "shortg [-qvkdu] [-fxxx] [infile [outfile]]"

#define HELPTEXT \
"  Remove isomorphs from a file of graphs.\n\
\n\
    If outfile is omitted, it is taken to be the same as infile\n\
    If both infile and outfile are omitted, input will be taken\n\
            from stdin and written to stdout\n\
\n\
    The output file has a header if and only if the input file does.\n\
\n\
    -s  force output to sparse6 format\n\
    -g  force output to graph6 format\n\
        If neither -s or -g are given, the output format is\n\
        determined by the header or, if there is none, by the\n\
        format of the first input graph.\n\
    -k  output graphs have the same labelling and format as the inputs.\n\
        Otherwise, output graphs have canonical labelling.\n\
	-s and -g are ineffective if -k is given.  If none of -sgk are\n\
	given, the output format is determined by the header or, if there\n\
        is none, by the format of the first input graph.\n\
\n\
    -v  write to stderr a list of which input graphs correspond to which\n\
        output graphs. The input and output graphs are both numbered\n\
        beginning at 1.  A line like\n\
           23 : 30 154 78\n\
        means that inputs 30, 154 and 78 were isomorphic, and produced\n\
        output 23.\n\
\n\
    -d  include in the output only those inputs which are isomorphic\n\
        to another input.  If -k is specified, all such inputs are\n\
        included in their original labelling.  Without -k, only one\n\
        member of each nontrivial isomorphism class is written,\n\
        with canonical labelling.\n\
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
\n\
    -u  Write no output, just report how many graphs it would have.\n\
        In this case, outfile is not permitted.\n\
\n\
    -q  Suppress auxiliary output\n"


/*************************************************************************/

#include "gtools.h" 

#if (HAVE_PIPE==0) || (HAVE_WAIT==0)
 #error Forget it, either pipe() or wait() are not available
#endif

#if HAVE_SIGNAL_H
#include <signal.h>
#endif
#if HAVE_SYS_WAIT_H
#include <sys/wait.h>
#else
#if !HAVE_PID_T
typedef int pid_t;
#endif
#endif

#if !PIPE_DEC
int pipe(int*);
#endif

#if !FDOPEN_DEC
FILE *fdopen(int, const char*);
#endif

#define SORTCOMMAND  SORTPROG,SORTPROG,"-u","+0","-1"
#define VSORTCOMMAND1  SORTPROG,SORTPROG
#define VSORTCOMMAND2  SORTPROG,SORTPROG,"+0","-1","+2"

/**************************************************************************/

static pid_t
beginsort(FILE **sortin, FILE **sortout, boolean vdswitch, boolean keep)
/* begin sort process, open streams for i/o to it, and return its pid */
{
        int pid;
        int inpipe[2],outpipe[2];

        if (pipe(inpipe) < 0 || pipe(outpipe) < 0)
            gt_abort(">E shortg: can't create pipes to sort process\n");

        if ((pid = fork()) < 0) gt_abort(">E shortg: can't fork\n");

        if (pid > 0)            /* parent */
        {
            close(inpipe[0]);
            close(outpipe[1]);
            if ((*sortin = fdopen(inpipe[1],"w")) == NULL)
                gt_abort(">E shortg: can't open stream to sort process\n");
            if ((*sortout = fdopen(outpipe[0],"r")) == NULL)
                gt_abort(">E shortg: can't open stream from sort process\n");
        }
        else                   /* child */
        {
            close(inpipe[1]);
            close(outpipe[0]);
            if (dup2(inpipe[0],0) < 0 || dup2(outpipe[1],1) < 0)
                gt_abort(">E shortg: dup2 failed\n");

            if (vdswitch)
                if (keep) execlp(VSORTCOMMAND2,(char*)NULL);
                else      execlp(VSORTCOMMAND1,(char*)NULL);
            else
                execlp(SORTCOMMAND,(char*)NULL);
            gt_abort(">E shortg: can't start sort process\n");
        }

        return pid;
}

/**************************************************************************/

static void
tosort(FILE *f, char *cdstr, char *dstr, long index)
/* write one graph to sort process 
   cdstr = canonical string 
   dstr = optional original string
   index = optional index number */
{
        register int i;
	char buff[20];

        for (i = 0; cdstr[i] != '\n'; ++i) {}
	cdstr[i] = '\0';
	writeline(f,cdstr);

        if (dstr != NULL)
        {
            writeline(f," ");
            for (i = 0; dstr[i] != '\n'; ++i) {}
	    dstr[i] = '\0';
	    writeline(f,dstr);
        }

        if (index > 0)
        {
            sprintf(buff,"\t%09ld\n",index);
            writeline(f,buff);
        }
        else
	    writeline(f,"\n");
}

/**************************************************************************/

static boolean
fromsort(FILE *f, char **cdstr, char **dstr, long *index)
/* read one graph from sort process */
{
        register int j;
        char *s;

	if ((s = getline(f)) == NULL) return FALSE;

	*cdstr = s;
        for (j = 0; s[j] != ' ' && s[j] != '\t' && s[j] != '\n'; ++j) {}

        if (s[j] == ' ')
        {
	    s[j] = '\0';
	    *dstr = &s[j+1];
            for (++j; s[j] != '\t' && s[j] != '\n'; ++j) {}
        }
        else
            *dstr = NULL;

        if (s[j] == '\t')
        {
            if (sscanf(&s[j+1],"%ld",index) != 1)
                gt_abort(">E shortg: index field corrupted\n");
        }
        else
            *index = 0;
	s[j] = '\0';

        return TRUE;
}

/**************************************************************************/

int
main(int argc, char *argv[])
{
        char *infilename,*outfilename;
        FILE *infile,*outfile;
        FILE *sortin,*sortout;
        int status;
        char *dstr,*cdstr,*prevdstr,*prevcdstr;
        char sw,*fmt;
        boolean badargs,quiet,vswitch,dswitch,keep,format,uswitch;
	boolean sswitch,gswitch;
        long numread,prevnumread,numwritten,classsize;
        int m,n,i,argnum,line;
	int outcode,codetype;
        pid_t sortpid;
	graph *g;
        char *arg;
#if MAXN
	graph h[MAXN*MAXM];
#else
	DYNALLSTAT(graph,h,h_sz);
#endif

	HELP;

	nauty_check(WORDSIZE,1,1,NAUTYVERSIONID);

        infilename = outfilename = NULL;
        dswitch = format = quiet = vswitch = keep = uswitch = FALSE;
	sswitch = gswitch = FALSE;

     /* parse argument list */

        argnum = 0;
	badargs = FALSE;

        for (i = 1; !badargs && i < argc; ++i)
        {
            arg = argv[i];
            if (arg[0] == '-' && arg[1] != '\0')
            {
		++arg;
		while (*arg != '\0')
		{
		    sw = *arg++;
		         SWBOOLEAN('q',quiet)
		    else SWBOOLEAN('v',vswitch)
		    else SWBOOLEAN('k',keep)
		    else SWBOOLEAN('d',dswitch)
		    else SWBOOLEAN('u',uswitch)
		    else SWBOOLEAN('s',sswitch)
		    else SWBOOLEAN('g',gswitch)
		    else if (sw == 'f')
		    {
		        format = TRUE;
		        fmt = arg;
		        break;
		    }
		    else badargs = TRUE;
		}
            }
            else
            {
		++argnum;
                if      (argnum == 1) infilename = arg;
		else if (argnum == 2) outfilename = arg;
                else 		      badargs = TRUE;
            }
        }

	if (strcmp(SORTPROG,"no_sort_found") == 0)
	    gt_abort(">E shortg: no sort program known\n");

	if (uswitch && outfilename != NULL)
	    gt_abort(">E shortg: -u and outfile are incompatible\n");

        if (sswitch && gswitch)
            gt_abort(">E shortg: -s and -g are incompatible\n");

        if (argnum == 1 && !uswitch) outfilename = infilename;

	if (badargs)
        {
            fprintf(stderr,">E Usage: %s\n",USAGE);
	    GETHELP;
            exit(1);
        }

	if (!quiet)
	{
	    fprintf(stderr,">A shortg");
	    if (uswitch || keep || vswitch || format
			|| sswitch || gswitch)
	    fprintf(stderr," -");
            if (sswitch) fprintf(stderr,"s");
            if (gswitch) fprintf(stderr,"g");
	    if (keep) fprintf(stderr,"k");
	    if (vswitch) fprintf(stderr,"v");
	    if (dswitch) fprintf(stderr,"d");
	    if (uswitch) fprintf(stderr,"u");
	    if (format) fprintf(stderr,"f%s",fmt);
	    if (argnum > 0) fprintf(stderr," %s",infilename);
	    if (argnum > 1) fprintf(stderr," %s",outfilename);
	    fprintf(stderr,"\n");
	}

     /* open input file */

        if (infilename && infilename[0] == '-') infilename = NULL;
	infile = opengraphfile(infilename,&codetype,FALSE,1);
	if (!infile) exit(1);
	if (!infilename) infilename = "stdin";

        if (sswitch || !gswitch && (codetype&SPARSE6)) outcode = SPARSE6;
        else                                           outcode = GRAPH6;

#ifdef SIG_IGN
        signal(SIGPIPE,SIG_IGN);        /* process pipe errors ourselves */
#endif

     /* begin sort in a subprocess */

        sortpid = beginsort(&sortin,&sortout,dswitch||vswitch,keep);

     /* feed input graphs, possibly relabelled, to sort process */

        numread = 0;

        while (TRUE)
        {
	    if ((g = readg(infile,NULL,0,&m,&n)) == NULL) break;
	    dstr = readg_line;
            ++numread;
#if !MAXN
	    DYNALLOC2(graph,h,h_sz,n,m,"shortg");
#endif
	    fcanonise(g,m,n,h,format ? fmt : NULL);
	    if (outcode == SPARSE6) cdstr = ntos6(h,m,n);
	    else                    cdstr = ntog6(h,m,n);

            tosort(sortin,cdstr,keep ? dstr : NULL,vswitch ? numread : 0);
	    FREES(g);
        }
        fclose(sortin);
        fclose(infile);

     /* open output file */

	if (uswitch)
	    outfilename = "<none>";
        else if (outfilename == NULL || outfilename[0] == '-' || is_pipe)
        {
            outfile = stdout;
            outfilename = "stdout";
        }
        else
        {
            if ((outfile = fopen(outfilename,"w")) == NULL)
            {
                fprintf(stderr,
                    ">E shortg: can't open %s for writing\n",outfilename);
                gt_abort(NULL);
            }
        }

	if (!uswitch && (codetype&HAS_HEADER))
	    if (outcode == SPARSE6) writeline(outfile,SPARSE6_HEADER);
	    else                    writeline(outfile,GRAPH6_HEADER);

        if (!quiet)
            fprintf(stderr,
                    ">Z %6ld graphs read from %s\n",numread,infilename);

     /* collect output from sort process and write to output file */

	prevcdstr = prevdstr = NULL;
        numwritten = 0;
	if (dswitch)
        {
	    classsize = 0;
            while (fromsort(sortout,&cdstr,&dstr,&numread))
            {
                if (classsize == 0 || strcmp(cdstr,prevcdstr) != 0)
		    classsize = 1;
		else
		{
		    ++classsize;
		    if (classsize == 2)
		    {
		 	++numwritten;
			if (!uswitch)
			{
                            writeline(outfile,keep ? prevdstr : prevcdstr);
                    	    writeline(outfile,"\n");
			}
			if (keep)
			{
                            ++numwritten;
			    if (!uswitch)
			    {
                                writeline(outfile,keep ? dstr : cdstr);
                                writeline(outfile,"\n");
			    }
			}
			if (vswitch)
			{
			    fprintf(stderr,"\n");
                    	    fprintf(stderr,"%3ld : %3ld %3ld",
				numwritten,prevnumread,numread);
                    	    line = 1;
			}
		    }
		    else
		    {
			if (keep)
			{
                            ++numwritten;
			    if (!uswitch)
			    {
                                writeline(outfile,keep ? dstr : cdstr);
		                writeline(outfile,"\n");
			    }
			}
                	if (vswitch)
			{
                    	    if (line == 15)
                    	    {
                                line = 0;
                                fprintf(stderr,"\n     ");
                            }
                            fprintf(stderr," %3ld",numread);
                            ++line;
			}
		    }
                }
		if (prevcdstr) FREES(prevcdstr);
                prevcdstr = stringcopy(cdstr);
		if (prevdstr) FREES(prevdstr);
                if (keep) prevdstr = stringcopy(dstr);
		prevnumread = numread;
            }
            if (vswitch) fprintf(stderr,"\n\n");
        }
        else if (vswitch)
        {
            while (fromsort(sortout,&cdstr,&dstr,&numread))
            {
                if (numwritten == 0 || strcmp(cdstr,prevcdstr) != 0)
                {
                    ++numwritten;
		    if (!uswitch)
		    {
                        writeline(outfile,keep ? dstr : cdstr);
		        writeline(outfile,"\n");
		    }
                    fprintf(stderr,"\n");
                    fprintf(stderr,"%3ld : %3ld",numwritten,numread);
                    line = 1;
                }
                else
                {
                    if (line == 15)
                    {
                        line = 0;
                        fprintf(stderr,"\n     ");
                    }
                    fprintf(stderr," %3ld",numread);
                    ++line;
                }
		if (prevcdstr) FREES(prevcdstr);
                prevcdstr = stringcopy(cdstr);
            }
            fprintf(stderr,"\n\n");
        }
        else
        {
            while (fromsort(sortout,&cdstr,&dstr,&numread))
            {
                ++numwritten;
		if (!uswitch)
		{
                    writeline(outfile,keep ? dstr : cdstr);
		    writeline(outfile,"\n");
		}
            }
        }

        fclose(sortout);
        if (!uswitch) fclose(outfile);

        if (!quiet)
	{
	    if (uswitch)
		fprintf(stderr,">Z %6ld graphs produced\n",numwritten);
	    else
                fprintf(stderr,
                        ">Z %6ld graphs written to %s\n",numwritten,outfilename);
	}

     /* check that the subprocess exitted properly */

        while (wait(&status) != sortpid) {}

#if (defined(WIFSIGNALED) || defined(WTERMSIG)) && defined(WEXITSTATUS)
#ifdef WIFSIGNALED
        if (WIFSIGNALED(status) && WTERMSIG(status) != 0)
#else
        if (WTERMSIG(status) != 0)
#endif
        {
            fprintf(stderr,">E shortg: sort process killed (signal %d)\n",
                          WTERMSIG(status)); 
            gt_abort(NULL);
        }   
        else if (WEXITSTATUS(status) != 0)
        {
            fprintf(stderr,
                    ">E shortg: sort process exited abnormally (code %d)\n",
                    WEXITSTATUS(status));
            gt_abort(NULL);
        }
#endif

        exit(0);
}
