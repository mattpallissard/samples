#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

/*
tag: queue
*/
typedef int dtype;
typedef struct node {
	dtype d, v;
	struct node *l, *r, *p;
} type;
typedef type type;
typedef int bs; //buffer size
enum { BUF_MAX = 254,
       TYPE_SIZE = sizeof(type),
       ERR = -1,
};

static inline bool lt(type *i, type *j)
{
	return i->v < j->v;
}

static inline bool eq(type *i, type *j)
{
	return i->v == j->v;
}

static inline void swap(type *i, type *j)
{
	type k = *i;
	*i = *j;
	*j = k;
}

bs distance(type *i)
{
	if (i)
		return (i->d);
	return -1;
}
type *merge(type *i, type *j)
{
	if (!i)
		return j;
	if (!j)
		return i;

	if (lt(j, i))
		swap(i, j);

	if (!i->l)
		i->l = j;
	else
		i->r = merge(i->r, j);

	if (distance(i->r) > distance(i->l))
		swap(i->r, i->l);

	if (!i->r)
		i->d = 0;
	else
		i->d = i->r->d + 1;

	return i;
}

type *init(dtype v)
{
	type *n;
	if (!(n = malloc(sizeof(type))))
		goto out;

	n->p = NULL;
	n->l = NULL;
	n->r = NULL;
	n->d = 0;
	n->v = v;
	return n;
out:
	fprintf(stderr, "%s: fail \n", __func__);
	exit(1);
}

type *insert(type *i, dtype v)
{
	return (merge(i, init(v)));
}

void *rm_root(type **i)
{
	type *l, *r;
	if (!i)
		return *i;
	l = (*i)->l;
	r = (*i)->r;
	free(*i);
	*i = merge(l, r);
	return *i;
}

dtype get_min(type *i)
{
	return i->v;
}

dtype pop(type **i)
{
	dtype ret = ERR;
	if (!i)
		return ret;
	ret = (*i)->v;
	rm_root(i);
	return ret;
}

void dump(type *i)
{
	if (i)
		printf("%d\n", i->v);
	if (i->l)
		dump(i->l);
	if (i->r)
		dump(i->r);
}

int main(void)
{
	type *i = init(0);
	i = insert(i, 2);
	i = insert(i, 3);
	i = insert(i, 4);
	i = insert(i, 5);
	//dump(i);
	printf("\n");
	printf("%d\n", pop(&i));
	printf("%d\n", pop(&i));
	printf("%d\n", pop(&i));
	printf("\n");
	//dump(i);
}
