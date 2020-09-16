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

static inline bool gt(type i, type j) {
	return i > j;
}

static inline bool eq(type i, type j) {
	return i == j;
}


static inline void swap(type *i, type *j) {
	type k = *i;
	*i = *j;
	*j = k;
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
		//else if(eq(l[i], r[j])) {  // uncomment for dedup
		//	k++;
		//	j++;
		//}
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

buf_size min(buf_size i, buf_size j) {
	return i < j ? i : j;
}

void ms(type *t,buf_size s) {

	if (s < 2)
		return;

	buf_size m = s / 2;
	type l[BUF_MAX] = {}, r[BUF_MAX] = {};

	memcpy(l, t, m * TYPE_SIZE - 1);
	memcpy(r, t + m, (s - m) * TYPE_SIZE - 1);

	ms(l, m);
	ms(r, s - m);

	merge(t, l, r, m, s - m);
}


int main(void) {
	type i[] = {9,4,6,32,5,9,8,2,1,7};
	size_t h = sizeof(i) / sizeof(type);
	display(i, 0, h - 1);
	ms(i, h);
	display(i, 0, h - 1);
}
