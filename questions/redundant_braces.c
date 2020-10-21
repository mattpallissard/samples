#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

/*
   check whether or not an expression has redundant braces.
   assumes that there is an even number of braces
*/

bool check_em(char *i){
	return (i[0] == '(' && i[1] == '(') || (i[0] == ')' && i[1] == ')');
}

int aux(char *expr, int i) {
	int incr = 2;
	if(!expr[0])
		return i;

	if(check_em(expr))
		i++;
	else
		incr = 1;

	return aux(expr+incr, i);
}


int main(void) {

	char *expr = "((a + b)+c)\0";
	int i;

	if(!(i = aux(expr, 0)))
		i = 1;

	printf("%s\n", i & 1 ? "no extra" : "extra");
}
