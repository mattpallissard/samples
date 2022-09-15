#import <stdio.h>
#import <stdlib.h>
#import <string.h>

enum { R = 10, C = 10, SIDES = 8 };

// hard coded coordinates
int r[] = {-1, -1, -1, 0, 1, 0, 1, 1 };
int c[] = {-1, 1, 0, -1, -1, 1, 0, 1 };

int is_coords(int x, int y) {
	return (x >=0) && (x < R) && (y>= 0) && (y < C);
}

int is_valid(int (*m)[R], int pos, int x, int y){
		return is_coords(x, y) && m[x][y];
}


int walk_vector(int (*m)[R], int pos, int len, int x, int y){
	if (is_valid(m, pos, x, y))
		return walk_vector(m, pos, ++len, x+r[pos], y+c[pos]);
	return len;

}

int walk_perimeter(int (*m)[R], int pos, int len, int x, int y){
	int ret = 0;
	if(pos == SIDES)
		return len;

	if(m[x][y]){
		ret = walk_vector(m, pos, 0, x, y);
	}
	
	return walk_perimeter(m, ++pos, ret > len ? ret  : len, x, y);
}


int iter_y(int (*m)[R], int sum, int x, int y){
	int ret = 0;
	if (y == R)
		return sum;
	
	ret = walk_perimeter(m, 0, 0, x, y);

	return iter_y(m, ret > sum ? ret: sum, x, ++y);
}


int iter_x(int (*m)[R], int sum, int x){
	if (x == C)
		return sum;

	sum = iter_y(m, sum, x, 0);
	return iter_x(m, sum, ++x);
}

int main(void)
{
	ssize_t i = sizeof(int) * R * C;
	int (*m)[R] = malloc(i);
	memset(m, 0, i);

	int matrix[][R] = { { 0, 1, 0, 1, 1, 1, 1, 1, 1, 1 },
		            { 0, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
			    { 1, 1, 1, 1, 0, 0, 1, 1, 0, 0 },
			    { 1, 0, 0, 1, 0, 1, 1, 0, 0, 0 },
			    { 1, 1, 1, 1, 0, 1, 0, 0, 1, 1 },
			    { 0, 1, 0, 1, 0, 0, 1, 1, 1, 1 },
			    { 0, 0, 0, 1, 0, 1, 1, 1, 0, 0 },
			    { 0, 0, 1, 1, 0, 0, 1, 1, 1, 0 },
			    { 1, 1, 1, 0, 1, 0, 1, 1, 0, 0 },
			    { 1, 1, 1, 1, 0, 0, 1, 1, 1, 1 } };
	memcpy(m, matrix, i);


	int foo = iter_x(m, 0, 0);
	printf("=%d\n",foo);
	free(m);
}
