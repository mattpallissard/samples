#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>



void nearest_small(int *list, size_t len) {
	int smallest = list[0];
	int buf[len];
	buf[0] = -1;
	int i = 1;
	do{
		if (smallest < list[i])
			buf[i] = smallest;
		else {
			smallest = list[i];
			buf[i] =  -1;
		}
	} while(++i < len);

	memcpy(list, buf, sizeof(buf));

}

int main(void) {
	int i[] = {4, 5, 2, 10, 8};
	size_t len = sizeof(i)/sizeof(int);

	nearest_small(i, len);

	int j = 0;
	do {
		printf("%d ", i[j]);
	}while(++j < len);
}
