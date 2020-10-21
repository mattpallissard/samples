#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
Given an array of integers A. There is a sliding window of size B which is
moving from the very left of the array to the very right.  You can only see the
w numbers in the window. Each time the sliding window moves rightwards by one
position. You have to find the maximum for each window.

Input Format

The first argument given is the integer array A.
The second argument given is the integer B.

Output Format

Return an array C, where C[i] is the maximum value of from A[i] to A[i+B-1]

For Example

Input 1:
    A = [1, 3, -1, -3, 5, 3, 6, 7]
    B = 3
Output 1:
    C = [3, 3, 5, 5, 6, 7]


*/
void aux(int *i, int w, size_t len)
{
	int j = 1;
	int res = i[0];
	do{
		if(i[j] > res)
			res = i[j];
	}while(++j < w);

	i[0] = res;
	printf("r - %d:%d\n", res, i[0]);
	if(--len < w)
		return;
	return aux(++i, w, len);
}



int main(void) {

	int i[] = {1, 3, -1, -3, 5, 3, 6, 7};
	int w = 3;
	size_t len = sizeof(i)/sizeof(int);
	int res[len-w];

	aux(i, w, len);


	for(int c = 0; c <= len - w; c++)
		res[c] = i[c];
	for(int c = 0; c <= len - w; c++)
		printf("%d ", res[c]);
	printf("\n");
}
