#include "mex.h"
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <time.h>
#include <string.h> // need to access memcpy

using namespace std;

#define pi (3.141592653589793)
#define EPS (.000000000001)  // 1e-12


/* Input Arguments */
#define    Topics_IN    prhs[0]
#define    Terms_IN    prhs[1]
#define    Ndk_IN    prhs[2]
#define    Nkt_IN    prhs[3]
#define    Nk_IN     prhs[4]
#define    V_IN          prhs[5]
#define    D_IN          prhs[6]
#define    K_IN          prhs[7]
#define    ALPHA_IN      prhs[8]
#define    BETA_IN      prhs[9]
#define    doc_IN       prhs[10]
#define    Nd_IN       prhs[11]

/* Output Arguments */
#define    Topics_OUT    plhs[0]
#define    Ndk_OUT    plhs[1]
#define    Nkt_OUT    plhs[2]
#define    Nk_OUT    plhs[3]

extern void _main();

const int numInputArgs  = 12;
const int numOutputArgs = 1;

// Function declarations.
// -----------------------------------------------------------------
double  getMatlabScalar    (const mxArray* ptr);
double& createMatlabScalar (mxArray*& ptr);
void    copyMatlabMatrix ( const mxArray* ptr, mxArray* ptr2);
// Function definitions.
// -----------------------------------------------------------------
/* =================================================================
 * Generate random integer uniformly distr. between 0 and N (incl.)
 * =================================================================
 */
double randdouble( double N)
{
  return N*(double)rand()/(double)RAND_MAX;
}

/* =================================================================
 * Generate random integer uniformly distr. between a and b (incl.)
 *
 * =================================================================
 */
int randint( int a, int b )
{
  return ( rand() % (b-a+1) ) + a;
}

/* =================================================================
 * Generate a random permutation of integers 0,1,2, ... N-1, N
 * Inputs:
 *    N      size of desired permutation
 *    perm   pointer to array where result should be stored
 * =================================================================
 */
void getRandPerm( int N, int *perm )
{
  for (int n=0; n<N; n++) {
    perm[n] = n;
  }
  for (int n=0; n<N; n++) {
    int randIdx = randint(0,N-1);
    int temp = perm[n];
    perm[n] = perm[randIdx];
    perm[randIdx] = temp;
  }
}



/* =================================================================
                     GIBBS SAMPLER MAIN LOOP
  Runs sampler for prescribed number of iterations
  Modifies Ndk,Nkt,Nk params in place
  
  Each iteration, scans through randomly generated permutation

  Can enable run-time validation by ensuring Nkt,Ndk,etc always track same # tokens
  =================================================================
*/
void run( mxArray *Terms, mxArray *Topics, mxArray *NdkArr, mxArray *NktArr, mxArray *NkArr, int V, int D, int K, double ALPHA, double BETA, int d, int Ntoken) {

  //mexPrintf( "run d=%d\n", d );

  double *ts =  mxGetPr( Terms );
  double *zs =  mxGetPr( Topics );
  double *Ndk = mxGetPr( NdkArr );
  double *Nkt = mxGetPr( NktArr );
  double *Nk = mxGetPr( NkArr );

  double BETASUM = (double) (V*BETA);
  double *ps = new double[K];

    for (int nn=0; nn<Ntoken; nn++) {
      int n = nn;
      int t = (int) ts[n];
      int k = (int) zs[n];

      if ( k < 0 || k >= K ) {
        mexPrintf(  "  ERROR: k out of bounds at token %d | %d\n", n, k);
        mexErrMsgTxt( "   somethings not right here.");
        return;
      }

      if ( d < 0 || d >= D ) {
        mexPrintf(  "  ERROR: d out of bounds at token %d | %d\n", n, d);
        mexErrMsgTxt( "   somethings not right here.");
        return;
      }
      if ( t < 0 || t >= V ) {
        mexPrintf(  "  ERROR: t out of bounds at token %d | %d\n", n, t);
        mexErrMsgTxt( "   somethings not right here.");
        return;
      }
      // --------------  decrement counts at token
      Ndk[d+D*k ] -= 1;
      Nkt[k+K*t ] -= 1;
      Nk[k] -= 1;

      // --------------  generate probs for this token
      double total=0;
      for (int kk=0; kk<K; kk++) {        
        ps[kk] = ( Nkt[kk+K*t] + BETA ) * ( Ndk[d+D*kk] + ALPHA ) / (Nk[kk] + BETASUM);
        total += ps[kk];
      }

      // --------------  choose new topic for this token
      double r = randdouble( total );
      double cursum = ps[0];
      int newk = 0;
      while ( r >= cursum && newk < K-1) {
        newk++;
        cursum += ps[newk];
      }
      if ( newk < 0 || newk >= K ) {
        mexPrintf(  "  ERROR: newk out of bounds at token %d | %d\n", n, newk);
        mexErrMsgTxt( "   somethings not right here.");
        return;
      }
      // --------------  increment counts for token
      zs[n] = newk;
      Ndk[d+D*newk ] += 1;
      Nkt[newk+K*t ] += 1;
      Nk[newk] += 1;
    }
    
/*
    // -------------- double check addition
    int NdkSum = 0;
    for (int d=0; d<D; d++) {
      for (int k=0; k<K; k++) {
        NdkSum += Ndk[d+D*k ];
      }
    }
    int NktSum = 0;
    for (int t=0; t<V; t++) {
      for (int k=0; k<K; k++) {
        NktSum += Nkt[k+K*t ];
      }
    }

    if ( NdkSum != NktSum ) {
      mexPrintf(  "  ERROR: Ndk!=Nkt  | %d | %d \n", NdkSum, NktSum);
      mexErrMsgTxt( "   somethings not right here.");
      return;
    }
*/
  delete [] ps;
  ps = NULL;

}



/* =================================================================
 *                    GATEWAY FUNCTION
 * Syntax:
 *      LDA_sampler( ts, ds, Ndk, Nkt, Nk, V, D, K, ALPHA, BETA, d, Nd)
 * =================================================================
 */
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  //Declarations
  int Nrow, Ncol;
  int Ntoken;
  int V, D, K;
  double ALPHA, BETA;
  int Nd, d;
  mxArray *NdkArr, *NktArr, *NkArr;
  mxArray *Topics;

  // Check to see if we have the correct number of input args
  if (nrhs != numInputArgs) {
    mexErrMsgTxt("Incorrect number of input arguments.\n"
      "Syntax: LDA_sampler( ts, ds, Ndk, Nkt, Nk, V, D, K, ALPHA, BETA, d, Nd)");
  }

  // --------------------   parse constants  ------------------------------
  V = (int) getMatlabScalar(V_IN);
  D = (int) getMatlabScalar(D_IN);
  K = (int) getMatlabScalar(K_IN);
  ALPHA = getMatlabScalar(ALPHA_IN);
  BETA = getMatlabScalar(BETA_IN);
  d = (int) getMatlabScalar(doc_IN);
  Nd = (int) getMatlabScalar( Nd_IN );  

  // --------------------   create Ndk,Nkt, Nk ------------------------------
  //  remember define statements up top set things up so
  //    Topics_OUT => plhs[0], etc.

  Topics_OUT = mxDuplicateArray( Topics_IN );
  Nkt_OUT = mxDuplicateArray( Nkt_IN );
  Ndk_OUT = mxDuplicateArray( Ndk_IN );
  Nk_OUT = mxDuplicateArray( Nk_IN );

  run( (mxArray *) Terms_IN, Topics_OUT, Ndk_OUT, Nkt_OUT, Nk_OUT, V, D, K, ALPHA, BETA, d, Nd);
}

void copyMatlabMatrix( const mxArray* ptr_IN, mxArray* ptr_OUT) {
  int M = mxGetM( ptr_IN );
  int N = mxGetN( ptr_IN );
  double* out = mxGetPr(ptr_OUT);
  double* in = mxGetPr( ptr_IN);
  memcpy( out, in, M*N*mxGetElementSize( ptr_IN ) );
}

double getMatlabScalar (const mxArray* ptr) {
  // Make sure the input argument is a scalar in double-precision.
  if (!mxIsDouble(ptr) || mxGetNumberOfElements(ptr) != 1)
    mexErrMsgTxt("The input argument must be a double-precision scalar");
  return *mxGetPr(ptr);
}

double& createMatlabScalar (mxArray*& ptr) {
  ptr = mxCreateDoubleMatrix(1,1,mxREAL);
  return *mxGetPr(ptr);
}
