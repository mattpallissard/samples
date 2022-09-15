
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

enum { BUF_MAX = 254, TYPE_SIZE = sizeof(uint64_t) };

// just a few boolean functions for readability

static inline bool lt(uint64_t i, uint64_t j)
{
	return i < j;
}


void display(uint64_t *t, uint8_t i, uint8_t j)
{
	while (i <= j)
		printf("%lu, ", t[i++]);
	printf("\n");
}

// merge, the meat and potatoes
void merge(uint64_t *t, uint64_t *l, uint64_t *r, uint8_t ls, uint8_t rs)
{
	uint8_t i = 0, j = 0, k = 0, m;
	// iterate over arrays, merging appropriately.
	while (i < ls && j < rs)
		if (lt(l[i], r[j]))
			t[k++] = l[i++];
		else
			t[k++] = r[j++];

	// take care of any stragglers not yet merged
	if (i < ls) {
		m = ls - i;
		memcpy(t + k, l + i, m * TYPE_SIZE);
		k += m;
	} else if (j < rs) {
		m = rs - j;
		memcpy(t + k, r + j, m * TYPE_SIZE);
	}
}

// the divide and conquor part of the exam  WE DONT NEED THIS FOR MEDIAN OF ARRAY
void ms(uint64_t *t, uint8_t s)
{
	if (s < 2)
		return;

	uint8_t m = s / 2;
	uint64_t l[BUF_MAX] = {}, r[BUF_MAX] = {};

	memcpy(l, t, m * TYPE_SIZE - 1);
	memcpy(r, t + m, (s - m) * TYPE_SIZE - 1);

	ms(l, m);
	ms(r, s - m);

	merge(t, l, r, m, s - m);
}

int main(void)
{
	uint64_t i[] = { 1, 4, 5 };
	uint64_t j[] = { 2, 3 };
	size_t ih = sizeof(i) / sizeof(uint64_t);
	size_t jh = sizeof(j) / sizeof(uint64_t);
	int sh = ih + jh;
	int median = sh / 2;
	uint64_t r[sh];
	//display(i, 0, ih - 1);
	//ms(i, j, ih, jh);
	merge(r, i, j, ih, jh);
	//printf("%d\n", median);
	if ((ih + jh) % 2)
		printf("%lu\n", r[median]);
	else
		printf("%f\n", (double)(r[median] + r[median + 1]) / 2);

	display(r, 0, ih + jh - 1);
}
