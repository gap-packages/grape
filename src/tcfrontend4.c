/* Output from p2c, the Pascal-to-C translator */


#include <p2c/p2c.h>


/* Program to process the input for  enum  Coset Enumeration version 2.1,
   and also the Praeger-Soicher book format for Coxeter relators.
   Copyright L.H.Soicher, 1992-1998.

   This version expects ASCII input.

   The input presentation (in the form described in enum.doc)
   is read from GRAPE_tcfein, error messages go to output,
   and the output for the FORTRAN enumerator goes to file GRAPE_tcfeout. */

#define maxexpr         200
#define maxword         2000


typedef long charset[9];

typedef Char expression[maxexpr];
typedef char word[maxword];
typedef enum {
  badmaxexpr, badmaxword, illchar, illgen, syntax
} errortype;


Static FILE *tcfein, *tcfeout;
Static char num['z' + 1 - 'A'];
Static char inv[104];


Static jmp_buf _JL999;


Static Void error(err, ch)
errortype err;
Char ch;
{
  putchar('\n');
  switch (err) {

  case badmaxexpr:
    printf(" *** constant maxexpr too small\n");
    break;

  case badmaxword:
    printf(" *** constant maxword too small\n");
    break;

  case illchar:
    printf(" *** illegal character '%c'\n", ch);
    break;

  case illgen:
    printf(" *** undeclared generator '%c'\n", ch);
    break;

  case syntax:
    printf(" *** syntax error - did not expect '%c'\n", ch);
    break;
  }
  longjmp(_JL999, 1);   /* error exit */
}


Static Void readexpr(f, e, valid, stop, ignore)
FILE **f;
Char *e;
long *valid, *stop, *ignore;
{
  long j;
  long brackets;
  Char ch;
  charset SET;

  j = 0;
  brackets = 0;   /* brackets = 0 iff all brackets are matched */
  do {
    do {
      while (P_eoln(*f)) {
	fscanf(*f, "%*[^\n]");
	getc(*f);
      }
      ch = getc(*f);
      if (ch == '\n')
	ch = ' ';
      if (!P_inset(ch, valid)) {
	if (isalpha(ch))
	  error(illgen, ch);
	else
	  error(illchar, ch);
      }
    } while (!P_inset(ch, P_setdiff(SET, valid, ignore)));
    j++;
    if (j > maxexpr)
      error(badmaxexpr, ' ');
    e[j - 1] = ch;
    if (ch == '[' || ch == '(')
      brackets--;
    else if (ch == ']' || ch == ')')
      brackets++;
  } while (!(P_inset(ch, stop) && brackets == 0));
}


Static long value(e, front, back)
Char *e;
long front, *back;
{
  /* returns the value of the unsigned integer in e[front]...e[back] */
  long mpr, val, j;

  j = front;
  while (isdigit(e[j - 1]))
    j++;
  *back = j - 1;
  mpr = 1;
  val = 0;
  for (j = *back; j >= front; j--) {
    val += mpr * (e[j - 1] - '0');
    if (j > front)
      mpr *= 10;
  }
  return val;
}


Static Void invert(w, front, back)
char *w;
long front, back;
{
  /* inverts w[front]...w[back] */
  long temp;

  while (front <= back) {
    temp = w[front - 1];
    w[front - 1] = inv[w[back - 1] - 1];
    w[back - 1] = inv[temp - 1];
    front++;
    back--;
  }
}


Static Void power(w, front, back, n)
char *w;
long front, *back, n;
{
  /* puts (w[front]...w[back])**n into w[front]... */
  long i, j, k, FORLIM1;

  if (n == 0) {
    *back = front - 1;
    return;
  }
  k = *back;
  for (i = 2; i <= n; i++) {
    FORLIM1 = *back;
    for (j = front - 1; j < FORLIM1; j++) {
      k++;
      if (k > maxword)
	error(badmaxword, ' ');
      w[k - 1] = w[j];
    }
  }
  *back = k;
}


Static Void writeword(f, w, front, back)
FILE **f;
char *w;
long front, back;
{
  long j;

  fprintf(*f, "%ld\n", back - front + 1);
  for (j = front - 1; j < back; j++)
    fprintf(*f, "%d\n", w[j]);
}


Static Void commutate PP((Char *e, long *last, char *w, long front,
			  long *back));


Static Void process(e, last, w, front, back)
Char *e;
long *last;
char *w;
long front, *back;
{
  /* translates the next word in e[last+1]... into w[front]...w[back]. */
  *back = front - 1;
  (*last)++;
  if (e[*last - 1] == '=' || e[*last - 1] == '.' || e[*last - 1] == ';' ||
      e[*last - 1] == ',' || e[*last - 1] == ']' || e[*last - 1] == ')')
    goto _L99;
  if (e[*last - 1] == '1') {
    process(e, last, w, front, back);
    goto _L99;
  }
  if (isalpha(e[*last - 1])) {
    (*back)++;
    if (*back > maxword)
      error(badmaxword, ' ');
    w[*back - 1] = num[e[*last - 1] - 'A'];
  } else if (e[*last - 1] == '[' || e[*last - 1] == '(') {
    process(e, last, w, front, back);
    if (e[*last - 1] == ';' || e[*last - 1] == ',')
      commutate(e, last, w, front, back);
  } else
    error(syntax, e[*last - 1]);
  if (e[*last] == '-') {
    invert(w, front, *back);
    (*last)++;
  }
  if (isdigit(e[*last]))
    power(w, front, back, value(e, *last + 1, last));
  process(e, last, w, *back + 1, back);
_L99: ;
}


Static Void commutate(e, last, w, front, back)
Char *e;
long *last;
char *w;
long front, *back;
{
  /* calculates the commutator [ w[front]...w[back] , ... ].
     commutators are left normed, so that [a,b,c,...] means [[a,b],c...]. */
  long i, backsave, FORLIM;

  backsave = *back;
  process(e, last, w, backsave + 1, back);
  FORLIM = *back * 2 - front + 1;
  for (i = *back + 1; i <= FORLIM; i++) {
    if (i > maxword)
      error(badmaxword, ' ');
    w[i - 1] = w[i - *back + front - 2];
  }
  invert(w, front, backsave);
  invert(w, backsave + 1, *back);
  *back = *back * 2 - front + 1;
  if (e[*last - 1] == ';' || e[*last - 1] == ',')
    commutate(e, last, w, front, back);
}


Static Void mainproc(tcfein, tcfeout)
FILE **tcfein, **tcfeout;
{
  expression e;
  word w, ww;
  short a[52][52];   /* stores Coxeter rels */
  long i, j, k, ngen, x, y, v, min, imin, jmin, back, last, firstlength;
  charset valid, gens;
  boolean flag;
  long SET[3];
  long SET1[3];
  charset SET2;
  long SET3[5];
  long SET4[4];
  long SET5[3];
  long SET6[3];

  P_addset(P_expset(valid, 0L), ' ');
  P_addsetr(valid, 'A', 'Z');
  P_addsetr(valid, 'a', 'z');
  P_addset(valid, ',');
  P_addset(valid, ';');
  P_addset(valid, '.');
  P_addset(P_expset(SET1, 0L), ' ');
  P_addset(SET1, ',');
  /* read generators */
  readexpr(tcfein, e, valid, P_addset(P_expset(SET, 0L), '.'),
	   P_addset(SET1, ';'));
  j = 1;
  P_expset(gens, 0L);
  while (e[j - 1] != '.') {
    P_addset(gens, e[j - 1]);
    num[e[j - 1] - 'A'] = j;
    j++;
  }
  P_addsetr(P_expset(SET3, 0L), 'A', 'Z');
  P_setdiff(valid, valid, P_setdiff(SET2, P_addsetr(SET3, 'a', 'z'), gens));
  ngen = j - 1;
  for (j = 1; j <= ngen; j++)
    inv[j - 1] = j;
  P_addset(P_expset(SET1, 0L), ' ');
  P_addset(SET1, ',');
  /* read non-involutions */
  readexpr(tcfein, e, valid, P_addset(P_expset(SET, 0L), '.'),
	   P_addset(SET1, ';'));
  j = 1;
  while (e[j - 1] != '.') {
    inv[num[e[j - 1] - 'A'] - 1] = ngen + j;
    inv[ngen + j - 1] = num[e[j - 1] - 'A'];
    j++;
  }
  fprintf(*tcfeout, "%ld\n", ngen + j - 1);
  for (k = 0; k <= ngen + j - 2; k++)
    fprintf(*tcfeout, "%d\n", inv[k]);
  P_addsetr(valid, '0', '9');
  P_addset(valid, '(');
  P_addset(valid, ')');
  P_addset(valid, '[');
  P_addset(valid, ']');
  P_addset(valid, '+');
  P_addset(valid, '-');
  /* read subgroup generators */
  do {
    P_addset(P_expset(SET1, 0L), ',');
    P_addset(SET1, ';');
    P_addset(P_expset(SET5, 0L), ' ');
    readexpr(tcfein, e, valid, P_addset(SET1, '.'), P_addset(SET5, '+'));
    last = 0;
    process(e, &last, w, 1L, &back);
    writeword(tcfeout, w, 1L, back);
  } while (e[last - 1] != '.');
  fprintf(*tcfeout, "%d\n", -1);   /* indicate start of relators */
  P_remset(valid, '(');
  P_remset(valid, ')');
  P_remset(valid, '[');
  P_remset(valid, ']');
  P_remset(valid, '+');
  P_remset(valid, '-');
  P_addset(P_expset(SET1, 0L), ' ');
  P_addset(SET1, ',');
  /* check for Coxeter relators */
  readexpr(tcfein, e, valid, P_addset(P_expset(SET, 0L), '.'),
	   P_addset(SET1, ';'));
  if (e[0] != '.') {
    /* process Coxeter relators */
    for (i = 0; i < ngen; i++) {
      for (j = 0; j < ngen; j++)
	a[i][j] = 2;
    }
    j = 1;
    if (!isdigit(e[1])) {
      /* normal enum format for Coxeter relators */
      do {
	while (!isdigit(e[j + 1])) {
	  x = num[e[j - 1] - 'A'];
	  y = num[e[j] - 'A'];
	  a[x - 1][y - 1] = 3;
	  a[y - 1][x - 1] = 3;
	  j++;
	}
	x = num[e[j - 1] - 'A'];
	j++;
	do {
	  y = num[e[j - 1] - 'A'];
	  v = value(e, j + 1, &j);
	  a[x - 1][y - 1] = v;
	  a[y - 1][x - 1] = v;
	  if (e[j] != '.')
	    j++;
	} while (isdigit(e[j]));
      } while (e[j] != '.');
    } else {
      /* Praeger-Soicher book format for Coxeter relators */
      do {
	/* process a path in the Coxeter graph */
	x = num[e[j - 1] - 'A'];
	while (isdigit(e[j])) {
	  v = value(e, j + 1, &j);
	  j++;
	  y = num[e[j - 1] - 'A'];
	  a[x - 1][y - 1] = v;
	  a[y - 1][x - 1] = v;
	  x = y;
	}
	j++;
      } while (e[j - 1] != '.');
    }
    min = 0;
    do {
      flag = true;
      for (i = 1; i < ngen; i++) {
	for (j = i + 1; j <= ngen; j++) {
	  if (a[i - 1][j - 1] > 0 && (a[i - 1][j - 1] < min || flag)) {
	    flag = false;
	    imin = i;
	    jmin = j;
	    min = a[i - 1][j - 1];
	  }
	}
      }
      if (!flag) {
	a[imin - 1][jmin - 1] = 0;
	fprintf(*tcfeout, "%ld\n", min * 2);
	for (j = 1; j <= min; j++) {
	  fprintf(*tcfeout, "%ld\n", imin);
	  fprintf(*tcfeout, "%ld\n", jmin);
	}
      }
    } while (!flag);
  }
  P_addset(valid, '(');
  P_addset(valid, ')');
  P_addset(valid, '[');
  P_addset(valid, ']');
  P_addset(valid, '+');
  P_addset(valid, '-');
  P_addset(valid, '=');
  /* read other relators */
  do {
    P_addset(P_expset(SET6, 0L), '.');
    P_addset(SET6, ',');
    P_addset(SET6, ';');
    P_addset(P_expset(SET5, 0L), ' ');
    readexpr(tcfein, e, valid, P_addset(SET6, '='), P_addset(SET5, '+'));
    last = 0;
    process(e, &last, w, 1L, &firstlength);
    if (e[last - 1] == '=')
      invert(w, 1L, firstlength);
    else
      writeword(tcfeout, w, 1L, firstlength);
    while (e[last - 1] == '=') {
      P_addset(P_expset(SET6, 0L), '.');
      P_addset(SET6, ',');
      P_addset(SET6, ';');
      P_addset(P_expset(SET5, 0L), ' ');
      readexpr(tcfein, e, valid, P_addset(SET6, '='), P_addset(SET5, '+'));
      last = 0;
      process(e, &last, ww, 1L, &back);
      fprintf(*tcfeout, "%ld\n", firstlength + back);
      for (j = 0; j < firstlength; j++)
	fprintf(*tcfeout, "%d\n", w[j]);
      for (j = 0; j < back; j++)
	fprintf(*tcfeout, "%d\n", ww[j]);
    }
  } while (e[last - 1] != '.');
  for (j = 1; j <= ngen; j++) {
    fprintf(*tcfeout, "%d\n", 2);
    fprintf(*tcfeout, "%ld\n", j);
    fprintf(*tcfeout, "%d\n", inv[j - 1]);
    if (j != inv[j - 1]) {
      fprintf(*tcfeout, "%d\n", 2);
      fprintf(*tcfeout, "%d\n", inv[j - 1]);
      fprintf(*tcfeout, "%ld\n", j);
    }
  }
  fprintf(*tcfeout, "%d\n", -2);
}


main(argc, argv)
int argc;
Char *argv[];
{  /* main program */
  PASCAL_MAIN(argc, argv);
  if (setjmp(_JL999))
    goto _L999;
  tcfeout = NULL;
  tcfein = NULL;
  if (tcfein != NULL)
    tcfein = freopen("GRAPE_tcfein", "r", tcfein);
  else
    tcfein = fopen("GRAPE_tcfein", "r");
  if (tcfein == NULL)
    _EscIO(FileNotFound);
  if (tcfeout != NULL)
    tcfeout = freopen("GRAPE_tcfeout", "w", tcfeout);
  else
    tcfeout = fopen("GRAPE_tcfeout", "w");
  if (tcfeout == NULL)
    _EscIO(FileNotFound);
  mainproc(&tcfein, &tcfeout);
_L999:
  if (tcfein != NULL)
    fclose(tcfein);
  if (tcfeout != NULL)
    fclose(tcfeout);
  exit(EXIT_SUCCESS);
}




/* End. */
