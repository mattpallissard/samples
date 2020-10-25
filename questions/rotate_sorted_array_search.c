#include <stdlib.h>
#include <stdio.h>

enum { MAX = 1000000 };

struct s {
	int *i;
	size_t index;
	size_t len;
	int l; // last seen digit
};

int aux(struct s s, int find)
{
	// make sure we're in bounds

	// we can optimize a bit.  If the last digit is greater than the
	// current index, we've hit the pivot point, if the integer we're
	// searching for is greater than the index we can be certain that we'll
	// never find it

	if (!s.len-- || ((s.l > *s.i) && (find > *s.i)))
		return -1;

	// found the thing
	if (*s.i == find)
		return s.index;

	// note the digit, increment, and recur
	s.l = *s.i++;
	s.index++;
	return aux(s, find);
}

int main(void)
{
	struct s s = {};
	int i[] = { 4, 5, 6, 7, 0, 1, 2, 3 };
	s.len = sizeof(i) / sizeof(int);
	s.index = 0i;
	s.i = i;
	printf("%d\n", aux(s, 8));
}
