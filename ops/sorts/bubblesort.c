#include <stdbool.h>
#include <stdint.h>

#include <stdio.h>

typedef uint64_t type;
typedef uint8_t buf_typedef;
enum {
	BUF_MAX = 254
};

static inline bool lt(type i, type j)
{
	return i < j;
}

static inline bool gt(type i, type j)
{
	return i > j;
}

static inline bool eq(type i, type j)
{
	return i == j;
}

static inline void swap(type *i, type *j)
{
	type k = *i;
	*i = *j;
	*j = k;
}

void s(type *t, buf_typedef l)
{
	// l-- // if handed array size instead of last index
	for(int i = 0; lt(i, l); i++)
		for(int j = 0; lt(j, l-i); j++)
			if(gt(t[j], t[j+1]))
				swap(&t[j], &t[j+1]);
}


int main(void)
{
	type i[] = {9,4,6,32,5,9,8,2,1,7};
	size_t h = sizeof(i)/sizeof(type) - 1;
	for(int k = 0; k <= h; k++)
	{
		printf("%lu, ", i[k]);
	}
	printf("\n");
	s(i, h);
	for(int k = 0; k <= h; k++)
	{
		printf("%lu, ", i[k]);
	}
	printf("\n");
}
