#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

typedef int type;

typedef struct node {
	type v;
	struct node * n;
} node_t;

enum {
	NODE_SIZE = sizeof(node_t)
};

void append(node_t * h, type v) {
	node_t * c = h;
	while (c -> n) {
		c = c -> n ;
	}

	if(!(c->n = malloc(sizeof(node_t))))
		goto out;
	c->n->v = v;
	c->n->n = NULL;
	return;
out:
	fprintf(stderr, "%s: fail\n", __func__);
	exit(1);
}

void push(node_t ** h, type v) {
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

type pop(node_t **h) {
	int r = -1;
	node_t * n = NULL;

	if (!h)
		return r;

	n = (*h)->n;
	r = (*h)->v;
	free(*h);
	*h = n;

	return r ;
}


void dump(node_t * h) {
	node_t * c= h;

	while (c){
		printf("%d\n", c->v);
		c = c->n;
	}
}


type ri(node_t **h, type n) {
	int r = -1;
	node_t *c = *h;
	node_t *t = NULL;

	if (!n)
		return pop(h);
	n--;

	for (int i = 0; i < n; i++) {
		if (!c -> n || c -> v)
			return -1;
		c = c -> n;

	}

	t = c -> n;
	r = t -> v;
	c -> n = t -> n;
	free(t);

	return r;
}


type rl(node_t * h) {
	type r = 0;
	node_t * c = h;
	if (!c -> n) {
		r = c -> v;
		goto r;
	}

	while (c ->n ->n)
		c = c -> n;

	r = c -> n -> v;
r:
	free(c -> n);
	c -> n = NULL;
	return r;

}

int main(void){
	node_t * h = NULL;
	if(!(h = malloc(NODE_SIZE)))
		goto out;

	h->v = 1;
	h ->n = NULL;

	push(&h, 2);
	push(&h, 3);
	push(&h, 4);
	dump(h);
	printf("\n");
	ri(&h, 3);
	dump(h);

	return 0;
out:
	fprintf(stderr, "%s: fail\n", __func__);
	exit(1);
}
