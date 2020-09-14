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

buf_typedef p(type *t, buf_typedef l, buf_typedef h)
{
	type p = t[l];
	for(;;){
		while(lt(t[l], p))
			l++;
		while(gt(t[h], p))
			h--;
		if (l >= h)
			return h;
		swap(&t[l++], &t[h--]);
		while(eq(t[l], t[h]))
			h--;
	}
}
void s(type *t, buf_typedef l, buf_typedef h)
{
	if(lt(l, h)){
		buf_typedef i = p(t, l, h);
		s(t, l, i);
		s(t, i+1, h);
	}
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
	s(i, 0, h);
	for(int k = 0; k <= h; k++)
	{
		printf("%lu, ", i[k]);
	}
	printf("\n");
}
