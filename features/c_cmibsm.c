#include "mex.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>


int isInsideInfluenceArea(x, y, xf, yf, rw, rh) {
	int rw2, rh2;
	rw2 = floor(rw/2);
	rh2 = floor(rh/2);
	
	if ((x>=xf-rw2 && x<=xf+rw2) && (y>=yf-rh2 && y<=yf+rh2))
		return 1;
	else
		return 0;
}


// In->  (data)         raw int* flat image data (beware, by columns)
//       (focuses)      coordinates (x,y) of the focuses
//       (height)       image height
//       (width)        image width
//       (K)            number of regions per dimension
//       (infA)         sets focuses' influence area
//       (norm)         Normalization: 0-> No normalization
//                                     1-> L1 Norm
//                                     2-> L2 Norm
//                                     3-> L1_sqrt Norm
//                                     5-> Normalization by maximum value possible + NO D
//                                     6-> No normalization + NO D
// Out-> (v)            cmibsm vector
void mexFunction(int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[]) {
	
	mxArray *pData;
	mxArray *pFocuses;
	mxArray *pH;
	mxArray *pW;
	mxArray *pK;
	mxArray *pInfA;
	mxArray *pNorm;
	
	double *v;
	
	int p;
	int i;
	double *data;
	double *focuses;
	int height;
	int width;
	float infA;
	int norm;
	int y, x, yf, xf;
	int K, K2;
	int rW;
	int rH;
	int region;
	int *neighbours;
	int n;
	int z;
	int found;
	
	double D;
	double *d;
	double t;
	double acc;
	double acc2;
	double maxFocusValue;
	
	pData = prhs[0];
	pFocuses = prhs[1];
	pH = prhs[2];
	pW = prhs[3];
	pK = prhs[4];
	pInfA = prhs[5];
	pNorm = prhs[6];
	
	data = mxGetPr(pData);
	focuses = mxGetPr(pFocuses);
	height = (int)mxGetScalar(pH);
	width = (int)mxGetScalar(pW);
	K = (int)mxGetScalar(pK);
	infA = (float)mxGetScalar(pInfA);
	norm = (int)mxGetScalar(pNorm);
	K2=K*K;
	d=(double*)calloc(K2,sizeof(double));
	rW = floor(width/K * infA);
	if (rW%2==0)
		rW++;
	rH = floor(height/K * infA);
	if (rH%2==0)
		rH++;
	
	plhs[0] = mxCreateDoubleMatrix(1, K2, mxREAL);
	v = mxGetPr(plhs[0]);
	memset(v, 0, K2*sizeof*v);
	
	
	/* Computing the focuses value */
	for (y=0; y < height; y++) {
		for (x=0; x < width; x++) {
			if ((data[y*width+x]!=0)) {
				D=0;
				for (n=0; n < K2; n++) {
					yf = focuses[n*2]-1;
					xf = focuses[n*2+1]-1;
					if (isInsideInfluenceArea(x, y, xf, yf, rW, rH)) {
						if (x-xf==0 && y-yf==0)
							d[n]=1;
						else
							d[n] = 1/sqrt((x-xf)*(x-xf)+(y-yf)*(y-yf));
						D += d[n];
					}
					else {
						d[n] = 0;
					}
				}
				if (D!=0) {
					for (n=0; n < K2; n++) {
						if (norm != 5 && norm != 6)
							t = d[n]/D;
						else
							t = d[n];
						v[n] += t;
					}
				}
			}
		}
	}
	
	// Normalization (optional)
	acc = 0;
	acc2 = 0;
	for (i=0; i < K2;i++) {
		acc += v[i];
		acc2 += v[i]*v[i];
	}
	if (norm==1) {
		for (i=0; i < K2;i++) {
			v[i] = v[i]/acc;
		}
	}
	else if (norm==2) {
		acc2=sqrt(acc2);
		for (i=0; i < K2;i++) {
			v[i] = v[i]/acc2;
		}
	}
	else if (norm==3) {
		for (i=0; i < K2;i++) {
			v[i] = sqrt(v[i]/acc);
		}
	}
	if (norm == 5) {
		/* Computing the maximum value */
		xf = floor(rW/2);
		yf = floor(rH/2);
		maxFocusValue=0;
		for (y=0; y < rH; y++) {
			for (x=0; x < rW; x++) {
				if (x-xf==0 && y-yf==0)
					maxFocusValue+=1;
				else
					maxFocusValue+=1/sqrt((x-xf)*(x-xf)+(y-yf)*(y-yf));
			}
		}
		for (i=0; i < K2;i++)
			v[i] /= maxFocusValue;
	}
	free(d);
}
