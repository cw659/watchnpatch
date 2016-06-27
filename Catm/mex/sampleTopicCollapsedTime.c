
/***********************************************************************
** sampleTopicCollapsed.c
** Partially collapsed sampling of assignments of words to topics
***********************************************************************/

#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int ii, kk, nWord, nTopic, nVocab;
  int indWord, crntWord, crntOffset, oldTopic, newTopic;
  double beta, betaSum, *values, *pi, *nkt;
  double probSum, probCum, probThresh, *probTopic;

  /* TODO: Modify type for cross-platform compatibility with int32? */
  int *order, *words, *assign, *nkw, *nkd, *nk;

/*********************************************************************
** Verify arguments and initialize variables
*********************************************************************/

  if (nrhs != 10)
    mexErrMsgTxt("Takes 8 input arguments");
  if (nlhs > 0)
    mexErrMsgTxt("No results output - modifies variables in place");

  order  = mxGetData(prhs[0]);
  values = mxGetData(prhs[1]);
  pi     = mxGetData(prhs[2]);
  beta   = mxGetScalar(prhs[3]);
  words  = mxGetData(prhs[4]);
  assign = mxGetData(prhs[5]);
  nkw    = mxGetData(prhs[6]);
  nkd    = mxGetData(prhs[7]);
  nk     = mxGetData(prhs[8]);
  
  nkt    = mxGetData(prhs[9]);
  

  nWord  = mxGetNumberOfElements(prhs[0]);
  nTopic = mxGetM(prhs[6]);
  nVocab = mxGetN(prhs[6]);
  betaSum = (double)nVocab * beta;

  probTopic = mxMalloc(nTopic*sizeof(double));

/*********************************************************************
** Resample all variables in specified random order
*********************************************************************/

  for (ii = 0; ii < nWord; ii++) {
    indWord  = order[ii];
    crntWord = words[indWord];
    oldTopic = assign[indWord];
    crntOffset = crntWord*nTopic;

    nkw[crntOffset + oldTopic]--;
    nkd[oldTopic]--;
    nk[oldTopic]--;

    probSum = 0.0;
    for (kk = 0; kk < nTopic; kk++) {
      probTopic[kk] = pi[kk] * ((double)nkw[crntOffset + kk] + beta) * nkt[indWord*nTopic + kk]
                    / (((double)nk[kk] + betaSum));
      probSum += probTopic[kk];
      //if(ii==0)
      // printf("%0.8f %0.8f %0.8f %0.8f %0.8f\n",pi[kk],((double)nkw[crntOffset + kk] + beta),nkt[indWord*nTopic + kk],(((double)nk[kk] + betaSum)),probTopic[kk]);
    }
    //printf("\n");
    probThresh = probSum*values[ii];
    //printf("%0.8f\n",probThresh);
    probCum  = probTopic[0];
    newTopic = 0;
    while (probCum < probThresh) {
      newTopic++;
      probCum += probTopic[newTopic];
    }

    nkw[crntOffset + newTopic]++;
    nkd[newTopic]++;
    nk[newTopic]++;
    assign[indWord] = newTopic;
  }

/*********************************************************************
** Free allocated memory
*********************************************************************/

  mxFree(probTopic);

}

