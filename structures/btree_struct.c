#include <stdbool.h>
#include <stdint.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct data {
	int id;
	char v [6];
};

typedef struct data type;
typedef uint8_t max_type;
enum {
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
	max_type n;
	max_type ld;
	max_type d[MAX];
	struct t t[MAX];
	bool (*lt)(type i, type j);
	bool (*eq)(type i, type j);
};



bool lt(type i, type j)
{
	return i.id < j.id;
}

bool eq(type i, type j)
{
	return strcmp(i.v, j.v);
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

type get(type i, struct r r)
{
	uint8_t j = 0;
	while(r.t[j].l || r.t[j].r) {
		if(r.eq(i, r.t[j].d))
			return r.t[j].d;

		else if(r.lt(i, r.t[j].d))
			j = r.t[j].l;

		else
			j = r.t[j].r;
	}
	if(r.eq(r.t[j].d, i))
		return r.t[j].d;
	else
	{
		type i = {};
		return i;
	}
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

	while(r.t[j].l || r.t[j].r) {
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
	}

	j = get_next(&r);
	r.t[j] = init_node(i);

	if(l)
		r.t[k].l = j;
	else
		r.t[k].r = j;

out:
	return r;
}

int main(void)
{
	struct r r = init_root();

	struct data v = {4, "lol\0"};
	struct r r2 = insert(v, r);
	struct data j = {4, ""};
	printf("%s\n", get(j, r2).v);
}
