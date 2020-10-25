#include <stdint.h>
#include <stdio.h>

uint64_t square_root(uint64_t i)
{
	uint64_t o = i;
	uint64_t res = 0;
	uint64_t one = 1uL << 62; // set second to top bit

	// shift bit down dividing by 4.  We're left with the highest power of 4 that is <= i
	while (one > o)
		one >>= 2;

	printf("here %lu\n", one);

	while (one) {
		if (o >= res + one) {
			o = o - (res + one);
			res = res + 2 * one;
		}
		res >>= 1;
		one >>= 2;
	}
	return res;
}

int main(void)
{
	printf("%lu\n", square_root(4));
}
