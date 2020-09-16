//Insertion sort Implementation in C:
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

typedef uint64_t type;
typedef uint8_t buf_size;
enum {
	BUF_MAX = 254,
	TYPE_SIZE = sizeof(type)
};

void display(type *t, buf_size i, buf_size j) {
	while(i <= j)
		printf("%lu, ", t[i++]);
	printf("\n");
}

static inline bool lt(type i, type j) {
	return i < j;
}

void is(type *t, buf_size l) {

	buf_size i = 0, j;
	type v;

	while(i++ < l) {
		v = t[i];
		j = i;
		while (j && lt(v, t[j - 1])) {
			t[j] = t[j - 1];
			j--;
		}
		if(j != i )
			t[j] = v ;
	}
}

int main(void) {
	type t[] = {4,3,5,6,3,7,9,34,0};
	buf_size l = sizeof(t)/TYPE_SIZE - 1;
	display(t, 0, l);
	is(t, l);
	display(t, 0, l);

}
