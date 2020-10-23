#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>


// we know that the square root is between 0 and i; so we binary searth the range
uint64_t aux(uint64_t i, uint64_t h, uint64_t l){
	if(l <= h){
		int m = (l + h) / 2;

		// square of m is < i and (m+1)^ >= i
		if(m * m <= i && (m + 1) * (m + 1) > i)
				return m;
		else if (m * m < i)
			return aux(i, h, m + 1);
		else
			return aux(i, m - 1, l);
	}
	return l;
}
uint64_t square_root(uint64_t i){
	return aux(i, i, 0);

}

int main(void){
	printf("%lu\n", square_root(11));
}
