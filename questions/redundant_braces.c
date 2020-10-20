#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>


int get_open(char *expr, int i) {
	if(!expr[0])
		return i;

	if(expr[0] == '(' && expr[1] == '(')
		i++;
	else if(expr[0] ==')' && expr[1] == ')')
		i++;

	return get_open(expr+1, i);
}



int main(void) {

	char *expr = "(a + b)\0";
	int i;

	if(!(i = get_open(expr, 0)))
		i = 1;


	printf("%d\n", (i % 2 ? 0 : 1));
}
