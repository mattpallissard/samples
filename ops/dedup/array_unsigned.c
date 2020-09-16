#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>

typedef uint64_t type;
typedef int bs;
enum {
	TYPE_SIZE = sizeof(type),
	LEN = 8
};

#define pf "%ld"

type get_mask(type i)
{
	return(pow(2, i));
}

type member(type i, type *b)
{
	return (*b >> i) & 1;
}

void insert(type i, type *b) {
	*b |= (get_mask(i));
}

void display(type *t, bs i, bs j) {
	while(i <= j)
		printf(""pf", ", t[i++]);
	printf("\n");
}


int main(void) {
	type i[] = {9,4,6,32,5,9,8,2,1,7};
	type b[LEN] = {};
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
