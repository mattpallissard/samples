#include <stdlib.h>
#include <stdio.h>

enum{
	MAX = 1000000
};

struct s {
	int *i;
	size_t index;
	size_t len;
	int l; // last seen digit
};

int aux(struct s s, int find){
	if(!s.len-- || ((s.l > *s.i) && (find > *s.i)))
		return -1;

	if(*s.i == find)
		return s.index;

	s.l = *s.i++;
	s.index++;
	return aux(s, find);
}

int main(void){
	struct s s ={};
	int i[] = {4, 5, 6, 7, 0, 1, 2, 3};
	s.len = sizeof(i)/sizeof(int);
	s.index = 0i;
	s.i = i;
	printf("%d\n", aux(s, 8));
}
