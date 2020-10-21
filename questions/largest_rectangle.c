#include <stdlib.h>
#include <stdio.h>
/*

tag: sliding window
Given an array of integers A of size N. A represents a histogram i.e A[i] denotes height of the ith histogram’s bar. Width of each bar is 1.



*/

/*
	we'll need a function that checks if the next item is less than the current, incrementing appropriately and rercurring if true
   */

int area(int *i, size_t len, int incr, int sum){
	if(!len)
		return sum;

	int cursor = i[0];
	int next = i[1];

	if(cursor <= next)
		return area(i+1, len-1, incr, sum+incr);
	return sum;
}

/*
   then we'll need a function to compare the area to the previously known max, resetting the max if necissary
   */

int aux(int *i, size_t len, int max)
{
	int j = 1;
	int res = i[0];
	int cursor = i[0];

	if(!len)
		return max;

	res = area(i, len, cursor, res);

	if(res > max)
		max = res;

	return aux(i+1, len-1, max);

}

int main(void) {

	//int i[] = {1, 3, -1, -3, 5, 3, 6, 7};
	int i[] = {2, 1, 5, 6, 6, 3};
	int w = 3;
	size_t len = sizeof(i)/sizeof(int) - 1;

	printf("%d\n", aux(i, len, 0));


	printf("\n");
}
