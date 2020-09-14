#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>


typedef uint64_t type;
typedef int buf_size;
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

int bs(type *t, buf_size l, buf_size i) {

	buf_size ls = 0, lr = l, m;

	while(ls <= lr) {
		m = (ls + lr) / 2;

		if(t[m] == i)
			return m;
		else if(lt(t[m], i)) {
			ls = m + 1;
		} else {
			lr = m - 1;
		}
	}
	return -1;
}


int main(void) {
	type i[] = {1,2,3,4,5,6,7,8,9,20,21,22};
	buf_size l = sizeof(i)/TYPE_SIZE - 1;
	buf_size j = bs(i, l , 4);
	printf("%d\n", j);

}
