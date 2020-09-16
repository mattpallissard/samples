#include <stdbool.h>
#include<stdint.h>
#include <string.h>
#include <stdio.h>

typedef uint64_t type;
typedef uint8_t bs;
enum {
	TYPE_SIZE = sizeof(type),
	MAX = 254,
};

struct o {
	bool (*lt)(type i, type j);
	bool (*eq)(type i, type j);
	bool (*set)(type i, type j);
};


struct t {
	uint8_t l, r;
	type d;
};

struct r {
	bs n;
	bs ld;
	type d[MAX];
	struct t t[MAX];
	bool (*lt)(type i, type j);
	bool (*eq)(type i, type j);
};



bool lt(type i, type j)
{
	return i < j;
}

bool eq(type i, type j)
{
	return i == j;
}


struct t init_node(type i)
{
	struct t t;
	t.l = 0;
	t.r = 0;
	t.d = i;
	return t;
}

struct r init_root()
{
	struct r r;
	r.eq = eq;
	r.lt = lt;
	r.n = 0;
	r.ld = 0;
	r.t[0].l = 0;
	r.t[0].r= 0;
	return r;
}


bool member(type i, struct r r)
{
	uint8_t j = 0;
	while(r.t[j].l || r.t[j].r) {
		if(r.eq(i, r.t[j].d))
			return true;

		else if(r.lt(i, r.t[j].d))
			j = r.t[j].l;

		else
			j = r.t[j].r;
	}
	return r.eq(r.t[j].d, i);

}

uint8_t get_next(struct r *r)
{
	int i;
	if(r->ld) {
		i = r->ld;
		r->d[r->ld--] = 0;
	} else {
		i = r->n++;
	}
	return i;
}

struct r insert(type i, struct r r)
{

	uint8_t j = 0, k = 0;
	bool l;

	do {
		if(r.eq(i, r.t[j].d))
			goto out;
		else if (r.lt(i, r.t[j].d)){
			l = true;
			j = r.t[j].l;
			k = j;
		}
		else {
			l = false;
			j = r.t[j].r;
			k = j;
		}
	} while(j || k);

	j = get_next(&r);
	r.t[j] = init_node(i);

	if(l)
		r.t[k].l = j;
	else
		r.t[k].r = j;

out:
	return r;
}


void display_s(struct t *t, bs i, bs j) {
	while(i <= j)
		printf("%lu, ", t[i++].d);
	printf("\n");
}
void display(type *t, bs i, bs j) {
	while(i <= j)
		printf("%lu, ", t[i++]);
	printf("\n");
}


int main(void) {
	type i[] = {9,4,6,32,5,9,8,2,1,7};
	size_t h = sizeof(i) / sizeof(type);
	bs j = 0, k = 0, rl = h;
	struct r r = init_root();
	display(i, 0, h - 1);
	do {
		if(!member(i[j], r)) {
			i[k++] = i[j];
			r = insert(i[j], r);
		}
		else
			rl--;
	} while(j++ <= h);

	display(i, 0, rl - 1);
	display_s(r.t, 0, rl - 1);
}
