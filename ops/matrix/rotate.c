#include <stdio.h>
enum { size = 4, };
typedef int type;

void swap(type *i, type *j){
	if(i == j)
		return;

	*i = *i ^ *j;
	*j = *i ^ *j;
	*i = *i ^ *j;
}

void display(type m[size][size]){
	for(int i = 0; i < size; i++) {
		for(int j = 0; j < size; j++)
			printf("%d,", m[i][j]);
		printf("\n");
	}
	printf("\n");

}

void transpose(type m[size][size]){
	for(int i = 0; i < size; i++)
		for(int j = 0; j < i; j++)
			swap(&m[i][j], &m[j][i]);
}

void rows(type m[size][size]){
	for(int i = 0; i < size/2; i++)
		for(int j = 0; j < size; j++)
			swap(&m[i][j], &m[size - i  - 1][j]);
}

void columns(type m[size][size]){
	for(int i = 0; i < size; i++)
		for(int j = 0; j < size/2; j++)
			swap(&m[i][j], &m[i][size - j  - 1]);

}

void right(type m[size][size]){
	transpose(m);
	columns(m);

}


void left(type m[size][size]) {
	transpose(m);
	rows(m);
}


int main(void){
int m[size][size] =	{{1,  2,  3,  4,}, {5,  6,  7,  8}, {5,  6,  7,  8}, {9,  10, 11, 12}};
//int m[size][size] =	{{1,  2,  3}, {5,  6,  7}, {5,  6,  7}};
	display(m);
	left(m);
	display(m);
	right(m);
	display(m);

}
