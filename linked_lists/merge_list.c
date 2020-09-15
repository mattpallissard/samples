#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef int dtype;
typedef struct node {
	dtype v;
	struct node * n;
} type;
typedef type type;
typedef uint8_t buf_size;
enum {
	BUF_MAX = 254,
	TYPE_SIZE = sizeof(type)
};

static inline bool lt(type *i, type *j) {
	return i->v < j->v;
}


static inline bool eq(type *i, type *j) {
	return i->v == j->v;
}


static inline void swap(type *i, type *j) {
	type k = *i;
	*i = *j;
	*j = k;
}


void append(type * h, dtype v) {
	type * c = h;
	while (c -> n) {
		c = c -> n ;
	}

	if(!(c->n = malloc(sizeof(type))))
		goto out;
	c->n->v = v;
	c->n->n = NULL;
	return;
out:
	fprintf(stderr, "%s: fail\n", __func__);
	exit(1);
}

void push(type ** h, dtype v) {
	type * n;
	if(!(n = malloc(sizeof(type))))
		goto out;

	n->v = v;
	n->n = *h;
	*h = n;
	return;
out:
	fprintf(stderr, "%s: fail\n", __func__);
	exit(1);
}

dtype pop(type **h) {
	int r = -1;
	type * n = NULL;

	if (!h)
		return r;

	n = (*h)->n;
	r = (*h)->v;
	free(*h);
	*h = n;

	return r ;
}


void dump(type * h) {
	type * c= h;

	while (c){
		printf("%d\n", c->v);
		c = c->n;
	}
}


dtype ri(type **h, dtype n) {
	int r = -1;
	type *c = *h;
	type *t = NULL;

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


dtype rl(type * h) {
	dtype r = 0;
	type * c = h;
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



type *merge(type *l, type *r){
	if(!l)
		return r;
	if(!r)
		return l;

	if(lt(l, r)){
		l->n = merge(l->n, r);
		return l;
	} else {
		r->n = merge(l, r->n);
		return r;
	}

}

void dd(type *t){
	if(!t->n)
		return;
	if(eq(t, t->n)) {
		ri(&t, 1);
		dd(t);
	}
	dd(t->n);
}

void destroy(type **t) {
	if(!(*t))
		return;
	pop(t);
	destroy(t);
}


int main(void){
	int rc = 0;
	type * l = NULL;
	type * r = NULL;
	if(!(l = malloc(TYPE_SIZE)))
		goto out;
	if(!(r = malloc(TYPE_SIZE)))
		goto out;

	l->v = 1;
	l ->n = NULL;
	r->v = 2;
	r ->n = NULL;

	append(l, 2);
	append(l, 3);
	append(l, 4);
	dump(l);
	printf("\n");

	printf("\n");
	append(r, 2);
	append(r, 3);
	append(r, 5);
	dump(r);
	l = merge(l, r);
	printf("\n");
	dd(l);
	dump(l);
	printf("\n");

cleanup:
	//destroy(&r);  // don't destroy if merged
	destroy(&l);
exit:
	return rc;
out:
	fprintf(stderr, "%s: fail\n", __func__);
	exit(1);
}
