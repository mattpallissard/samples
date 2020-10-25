#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
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
	/*
	   we have the general direction of our movment which is up, down or not determined (init)
	*/
	INIT,
	UP,
	DOWN
};

enum {

	/* we'll move from point to point, using the state of where we're at compared with our previous location to derive the locaion, which is a bit more nuanced */
	PEAK,
	VALLEY,
	INCLINE,
	DECLINE,
	PLATEAU,
	NONE,
};

struct s {
	/* and we'll need some sort of 'object' to keep track of the 'state */
	int direction; // direction
	int sum; // sum of the area to date, well if iterations were ticks of some sort
	int num; // number of steps since the last peak

	// left and right
	int l; // last peak
	int r; // previous location
};

int what(struct s s, int i);
void print_direction(struct s s)
{
	switch (s.direction) {
	case UP:
		printf("up");
		return;
	case DOWN:
		printf("down");
		return;
	case INIT:
		printf("init");
		return;
	}
	printf("error");
}
void print_type(struct s s, int i)
{
	switch (what(s, i)) {
	case INCLINE:
		printf("INCLINE");
		return;
	case PEAK:
		printf("PEAK");
		return;
	case DECLINE:
		printf("DECLINE");
		return;
	case VALLEY:
		printf("VALLEY");
		return;
	}
	printf("NONE");
}

void display_debug(struct s s, int *i)
{
	printf("s.l:%d i:%d s.sum:%d s.num:%d\n", s.l, i[0], s.sum, s.num);
	int cursor = i[0];
	print_direction(s);
	printf(":");
	print_type(s, cursor);
	printf("\n");
}

/* we'll walk along, carrying the total area of all spaces below our last position as we go */
struct s carry(struct s s, int i)
{
	s.sum += s.l - i;
	return s;
}

/* but then when we reach the top, we'll need to account for all of the difference between the cursor and the smaller of the two peaks */
struct s sum(struct s s)
{
	bool down = s.r > s.l;
	s.sum += (down ? s.l - s.r : s.r - s.l) * s.num;
	s.num = 0; // mark it zero dude
	return s;
}

/* we'll need a function to toggle the directoin */

struct s direction(struct s s)
{
	if (s.direction == UP)
		s.direction = DOWN;
	else
		s.direction = UP;
	return s;
}

/* another to derive the location from a direction, last position and current position */

int what(struct s s, int i)
{
	bool up = s.r < i;
	bool down = s.r > i;
	bool flat = s.r == i;
	if (s.direction == UP && up)
		return INCLINE;
	else if (s.direction == UP && down)
		return PEAK;
	else if (s.direction == DOWN && down)
		return DECLINE;
	else if (s.direction == DOWN && up)
		return VALLEY;
	else if (flat)
		return PLATEAU;
	else
		return NONE; // our init case
}

/*
   base case of flat land, do nothing, we'll catch that with sum function

   valley and peak we'll need to swap directions.
   valley, decline and incline we will carry area, on valley and decline it's from the previous postiion, on the incline it's from the current.

   at the peak, we sum area above known positions, we also reset previous peak to current 
   */
int aux(int *i, struct s s, size_t len)
{
	display_debug(s, i);
	int cursor = i[0];
	bool up = s.r < cursor;
	switch (what(s, cursor)) {
	case PLATEAU:
		break;
	case VALLEY:
		s = direction(s);
	case DECLINE:
		cursor = s.r;
	case INCLINE:
		s.num++;
		s = carry(s, cursor);
		break;
	case PEAK:
		s.l = s.r;
		s = direction(s);
		s = sum(s);
		break;
	case NONE:
		if (up) {
			s.direction = UP;
			s.l = cursor;
			break;
		}
		// I technically don't need to account for this,
		//but 1. it should at least be noted in the comments
		//    2. someone will probably change this requirement someday
		s.direction = DOWN;
		s.num++;
	}
	// we need a termination state
	if (!len)
		return s.sum;
	// set last known postion to current
	s.r = i[0];
	// recur
	return aux(i + 1, s, len - 1);
}
int main(void)
{
	//	int i[] = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1}; // 6
	//	int i[] = {0, 3, 0, 3, 1, 0, 1, 3, 2, 1, 2, 1}; // 11
	int i[] = { 3, 1, 0, 3, 1, 0, 1, 3, 2, 1, 2, 1 }; // 11
	size_t len = sizeof(i) / sizeof(int) - 1;
	struct s s = { INIT, 0, 0, i[0], 0 };
	printf("%d\n", aux(i, s, len));
}

/*

int aux1(int *i, struct s s, size_t len){

	int cursor = i[0];
	bool up = s.r < cursor;
	bool down = s.r > cursor;
	switch (s.direction) {
		case INIT:
			if(up){
				s.direction = UP;
				s.l = i[0];
			}
			else if (down){
				s.direction = DOWN;
				s.num++;
			}
			break;
		case UP:
			if(up){
				//incr
				s.num++;
				s = carry(s, cursor);
			} else if (down){
				//peak
				s.l = s.r;
				s = direction(s);
				s = sum(s);
			}
			break;
		case DOWN:
			if(up || down){
				// decr and valley
				s.num++;
				s = carry(s, s.r);
			}
			if(up){
				// valley
				s = direction(s);
			}
			break;
	}
	if(!len)
		return s.sum;
	s.r = cursor;
	return aux1(i+1, s, len-1);
}
*/
