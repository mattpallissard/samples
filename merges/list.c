#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

typedef uint64_t type;
typedef uint8_t buf_size;
enum {
	BUF_MAX = 254,
	TYPE_SIZE = sizeof(type)
};

static inline bool lt(type i, type j) {
	return i < j;
}

void display(type *t, buf_size i, buf_size j) {
	while(i <= j)
		printf("%lu, ", t[i++]);
	printf("\n");
}

void merge(type *t, type *l, type *r, buf_size ls, buf_size rs) {
	buf_size i = 0, j = 0, k = 0, m;
	while(i < ls && j < rs)
		if(lt(l[i], r[j]))
			t[k++] = l[i++];
		else
			t[k++] = r[j++];

	if(i < ls) {
		m = ls - i;
		memcpy(t+k, l+i, m * TYPE_SIZE);
		k+=m;
	}

	if(j < rs) {
		m = rs - j;
		memcpy(t+k, r+j, m * TYPE_SIZE);
	}
}

int main(void)
{
	type i[] = {1,3,5,6,10};
	type j[] = {1,2,4,5,11};

	buf_size is = sizeof(i)/sizeof(type);
	buf_size js = sizeof(j)/sizeof(type);

	type t[is + js];
	memset(t, 0, (is+js) * TYPE_SIZE);
	merge(t, i, j, is, js);
	display(t, 0, is + js - 1);

}
