#include <stdbool.h>
#include <stdint.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint64_t type;
typedef int max_type;
enum {
	MAX = 254,
};

enum { Gt, Lt, Eq };

struct t {
	int l, r;
	type d;
};

struct r {
	max_type n;
	max_type ld;
	max_type d[MAX];
	struct t t[MAX];
	int (*cmp)(type i, type j);
};

int cmp(type i, type j)
{
	if (i < j)
		return Lt;
	else if (i > j)
		return Gt;
	else if (i == j)
		return Eq;
	else
		return -1;
}

struct t init_node(type i)
{
	struct t t;
	t.l = -1;
	t.r = -1;
	t.d = i;
	return t;
}

struct r init_root()
{
	struct r r;
	r.cmp = cmp;
	r.n = 1;
	r.ld = 0;
	memset(r.t, -1, MAX * sizeof(struct t));
	return r;
}

bool member(type i, struct r r)
{
	uint8_t j = 0;
	while (r.t[j].l != -1 || r.t[j].r != -1) {
		switch (r.cmp(i, r.t[j].d)) {
		case Eq:
			return true;
		case Lt:
			j = r.t[j].l;
			break;
		case Gt:
			j = r.t[j].r;
			break;
		}
	}
	return r.cmp(r.t[j].d, i) == Eq ? true : false;
}

int get_next(struct r *r)
{
	int i;
	if (r->ld) {
		i = r->ld;
		r->d[r->ld--] = 0;
	} else
		i = r->n++;

	return i;
}

struct r insert(type i, struct r r)
{
	int j = 0, k = 0;
	bool l;

	for (;;) {
		switch (r.cmp(i, r.t[j].d)) {
		case Eq:
			goto end;
		case Lt:
			l = true;
			if ((j = r.t[j].l) < 0) // if we hit negative from initialization
				goto out;
			k = j;
                        break;
		case Gt:
			l = false;
			if ((j = r.t[j].r) < 0)
				goto out;
			k = j;
                        break;
		}
	}

out:
	j = get_next(&r);
	r.t[j] = init_node(i);
	if (l)
		r.t[k].l = j;
	else
		r.t[k].r = j;

end:
	return r;
}

int main(void)
{
	struct r r = init_root();

	struct r r2 = insert(4, r);
	struct r r3 = insert(5, r2);

	printf("%d\n%d\n\n", member(4, r2), member(5, r2));

	printf("%d\n%d\n", member(4, r3), member(5, r3));
}
