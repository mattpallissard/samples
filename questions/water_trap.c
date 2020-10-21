#include <stdlib.h>
/*
Given an integer array A of non-negative integers representing an elevation map where the width of each bar is 1, compute how much water it is able to trap after raining.


Problem Constraints

1 <= |A| <= 100000


Input Format

The only argument given is integer array A.


Output Format

Return the total water it is able to trap after raining.
Example Input

Input 1:

 A = [0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]

Input 2:

 A = [1, 2]



Example Output

Output 1:

 6

Output 2:

 0
*/
enum {
	INIT,
	UP,
	DOWN
};
struct s {
	int direction;
	int multiplier;
	int carry;
	int sum;
	int num;
	int l;
};

int aux(int *i, struct s s, size_t len){
	switch (s.direction) {
		case INIT:
			if(s.l < i[0]){
				s.direction = UP;
				s.l = i[0];
			} else if (s.l > i[0]) {
				s.direction = DOWN;
				s.num++;
			}
			break;
		case UP:
			if(s.l < i[0]){
				s.num++;
				s.sum += s.l - i[0];
			} else if (s.l > i[0]) {
				s.direction = DOWN;
				s.num = 0;
				s.sum += s.l - i[0] * s.num;
			}
			break;
		case DOWN:
			if(s.l < i[0]){
				s.num++;
				s.sum += s.l - i[0];
			}
			;
	}
}

int main(void){

	int i[] = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1};
	size_t len = sizeof(i)/sizeof(int);
	struct s s = {INIT, 0, 0, i[0]};
}
