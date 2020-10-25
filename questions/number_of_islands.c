#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>


enum { R = 10, C = 10, SIDES = 8 };

// hard coded coordinates
int r[] = { -1, -1, -1, 0, 1, 0, 1, 1 };
int c[] = { -1, 1, 0, -1, -1, 1, 0, 1 };


/*
   we need a function that checks that a coordinate is valid
   are they non negative and inside the bounds
   have we seen it already?
   is it a positive integer in the source array
*/
bool is_valid(int m[R][C], bool s[R][C], int x, int y)
{
	return (x >= 0) && (x < R) && (y >= 0) && (y < C) && (!s[y][x] && m[y][x]);
}

void aux(int m[R][C], bool s[R][C], int x, int y)
{
	s[y][x] = true;
	for (int k = 0; k < SIDES; k++) {
		if (is_valid(m, s, r[k] + x, c[k] + y))
			aux(m, s, r[k] + x, c[k] + y);
	}
}

int find_iter(int m[R][C])
{
	int sum = 0;
	bool seen[R][C] = {};
	memset(seen, 0, sizeof(seen));

	for (int x = 0; x < R; x++)
		for (int y = 0; y < C; y++) {
			if (m[y][x] && !seen[y][x]) {
				aux(m, seen, x, y);
				sum++;
			}
		}
	return sum;
}

/*
 we need to walk around the perimeter of a cooordinate
 if the perimiter coordinate is valid, check it as if it were the center.
 then chekc the next perimiter coordinate
*/

void walk_perimeter(int m[R][C], bool s[R][C], int p, int x, int y)
{
	if (p == SIDES)
		return;

	s[y][x] = true;

	if (is_valid(m, s, r[p] + x, c[p] + y))
		walk_perimeter(m, s, 0, r[p] + x, c[p] + y);

	walk_perimeter(m, s, p + 1, x, y);
}

/*
 given a x coordinate, walk the y axis
*/

int iter_y(int m[R][C], bool s[R][C], int sum, int x, int y)
{
	if (y == R)
		return sum;

	if (m[y][x] && !s[y][x]) {
		walk_perimeter(m, s, 0, x, y);
		sum++;
	}

	return iter_y(m, s, sum, x, y + 1);
}

/*
   walk the x axis, handing each coordinate to the function that walks the y axis
*/
int iter_x(int m[R][C], bool s[R][C], int sum, int x)
{
	if (x == C)
		return sum;

	return iter_y(m, s, sum, x, 0) + iter_x(m, s, sum, x + 1);
}


// do the thing
int find(int m[R][C])
{
	bool seen[R][C] = {};
	memset(seen, 0, sizeof(seen));
	return iter_x(m, seen, 0, 0);
}

int main(void)
{
	int matrix[][C] = { { 1, 0, 1, 0, 0, 0, 1, 1, 1, 1 },
		            { 0, 0, 1, 0, 1, 0, 1, 0, 0, 0 },
			    { 1, 1, 1, 1, 0, 0, 1, 0, 0, 0 },
			    { 1, 0, 0, 1, 0, 1, 0, 0, 0, 0 },
			    { 1, 1, 1, 1, 0, 0, 0, 1, 1, 1 },
			    { 0, 1, 0, 1, 0, 0, 1, 1, 1, 1 },
			    { 0, 0, 0, 0, 0, 1, 1, 1, 0, 0 },
			    { 0, 0, 0, 1, 0, 0, 1, 1, 1, 0 },
			    { 1, 0, 1, 0, 1, 0, 0, 1, 0, 0 },
			    { 1, 1, 1, 1, 0, 0, 0, 1, 1, 1 } };

	printf("%d\n", find(matrix));
	printf("%d\n", find_iter(matrix));
}
