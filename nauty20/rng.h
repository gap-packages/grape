/* rng.h : definitions for using Don Knuth's random number generator.

   To use it:
     1.  Call rng_init(seed) with any long seed.  (Optional!)
     2.  Use NEXTRAN to get the next number (0..2^30-1).
         Alternatively, use KRAN(k) to get a random number 0..k-1.

   These definitions are also in naututil.h.
*/

extern long *ran_arr_ptr;
long ran_arr_cycle();
void ran_init(long seed);
void ran_array(long *aa, int n);

#define NEXTRAN (*ran_arr_ptr>=0 ? *ran_arr_ptr++ : ran_arr_cycle())
#define KRAN(k) (NEXTRAN%(k))
