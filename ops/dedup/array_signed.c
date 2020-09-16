#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>

typedef long int type;
typedef int bs;
enum {
	TYPE_SIZE = sizeof(type),
	BS_SIZE = 32,
	MAX = 8,
	HALF = MAX / 2 - 1
};

#define pf "%ld"

type get_mask(type i)
{
	return(pow(2, labs(i)));
}

type member(type i, type *b)
{
	uint8_t s = HALF;
	if(i < 0)
		s = 0;
	return (*b >> labs(i)) >> s & 1;
}

void insert(type i, type *b) {
	uint8_t s = HALF;
	if(i < 0)
		s = 0;
	*b |= (get_mask(i) << s);
}

void display(type *t, bs i, bs j) {
	while(i <= j)
		printf(""pf", ", t[i++]);
	printf("\n");
}


int main(void) {
	type i[] = {9,4,6,32,5,9,8,2,1,7};
	i[8]=-1;
	i[9]=-1;
	type b[8] = {};
	size_t h = sizeof(i) / sizeof(type);
	bs j = 0, k = 0, rl = h - 1;
	display(i, 0, h - 1);
	do {
		if(!member(i[j], b)) {
			i[k++] = i[j];
			insert(i[j], b);
		}
		else
			rl--;
	} while(j++ <= h);
	display(i, 0, rl);
}
