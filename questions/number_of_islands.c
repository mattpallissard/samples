#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

typedef struct type {
	int x;
	int y;
} type_t;


typedef struct node {
	type_t v; // value
	struct node *n; // next
} node_t;

#define EMPTY {}
enum {
	R = 10,
	C = 10,
	NODE_SIZE = sizeof(node_t),
	SIDES = 8
};
// hard coded coordinates
int r[] = { -1, -1, -1, 0, 1, 0, 1, 1 };
int c[] = { -1, 1, 0, -1, -1, 1, 0, 1 };


void push(node_t ** h, type_t v) {
	node_t * n;
	if(!(n = malloc(sizeof(node_t))))
		goto out;

	n->v = v;
	n->n = *h;
	*h = n;
	return;
out:
	fprintf(stderr, "%s: fail\n", __func__);
	exit(1);
}

type_t pop(node_t **h) {
	// set current to next, free current
	type_t r = EMPTY;
	node_t * n = NULL;

	// base case, null
	if (!h)
		return r;

	n = (*h)->n;
	r = (*h)->v;
	free(*h);
	*h = n;

	return r ;
}

bool is_valid(int m[R][C], bool s[R][C], int x, int y){
	return (x>=0) && (x < R) && (y >= 0) && (y < C) && (!s[y][x] && m[y][x]);
}

void aux(int m[R][C], bool s[R][C], node_t **h) {
	type_t t; // coordinate
	type_t tn; // new t
	int x;
	int y;
	while((*h)->n){
		t = pop(h);
		printf("%d,%d\n", t.x, t.y);
		for(int k = 0; k < SIDES; k++){
			printf("\n");
			int x = r[k] + t.x;
			int y = c[k] + t.y;

			printf("%s\n", s[y][x] ? "true" : "false");
			printf("%d,%d\n", x, y);
			if(is_valid(m, s, x, y)){
				s[y][x] = true;
				tn.x = x;
				tn.y = y;
				push(h, tn);
			}
		}
	}
	pop(h);
}

node_t *init_queue(){
	node_t * h = NULL; // queue head

	if(!(h = malloc(NODE_SIZE)))
		goto out;

	h -> v.x = -1;
	h -> v.y = -1;
	h -> n = NULL;
	return h;
out:
	// do the failure thing
	exit(1);
}

int find(int m[R][C]){
	int sum = 0;
	bool seen[R][C] = {};
	memset(seen, 0, sizeof(seen));

	node_t * h = init_queue();


	for(int x = 0; x < R; x++)
		for(int y = 0; y < C; y++){
			if(m[y][x] && !seen[y][x]){
				printf("howdy\n");
				type_t coord = { x=x, y=y};
				seen[y][x] = true;
				push(&h, coord);
				aux(m, seen, &h);
				sum++;
			}
		}
	return sum;
}

int main(void){

	int matrix[R][C] = {
		{ 1, 0, 1, 0, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 1, 0, 1, 0, 1, 0, 0, 0 },
		{ 1, 1, 1, 1, 0, 0, 1, 0, 0, 0 },
		{ 1, 0, 0, 1, 0, 1, 0, 0, 0, 0 },
		{ 1, 1, 1, 1, 0, 0, 0, 1, 1, 1 },
		{ 0, 1, 0, 1, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 1, 1, 1, 0, 0 },
		{ 0, 0, 0, 1, 0, 0, 1, 1, 1, 0 },
		{ 1, 0, 1, 0, 1, 0, 0, 1, 0, 0 },
		{ 1, 1, 1, 1, 0, 0, 0, 1, 1, 1 }
	};

	printf("-%d\n", find(matrix));

}
