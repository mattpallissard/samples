#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

/*
tag: queue
*/
typedef uint64_t dtype;

typedef struct node {
	dtype d, v;
	struct node *l, *r, *p;
} type;
typedef type type;
typedef int bs; //buffer size
enum {
	BUF_MAX = 248000,
	IN_MAX = 512,
	TYPE_SIZE = sizeof(type),
	ERR = -1,
};

struct string {
	uint64_t l;
	char v[IN_MAX];
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

dtype get_max(type *i)
{
	if (!i->r)
		return i->v;

	return get_max(i->r);
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
		printf("%lu\n", i->v);
	if (i->l)
		dump(i->l);
	if (i->r)
		dump(i->r);
}

int main(int argc, char **argv)
{
	/*
	*
	* 6
	* a b c aa d b
	* 1 2 3 4 5 6
	* 3
	* 1 5 caaab
	* 0 4 xyz
	* 2 4 bcdybc
	*/

	bool first = true;
	int rc = 0;
	type *tree;

	int count_line = 0;
	uint64_t count_word = 0;
	uint64_t count_char = 0;
	uint8_t c = 0;
	;
	uint64_t w, p = 1;
	uint64_t num_entries = 0;

	struct string *str = malloc(BUF_MAX * sizeof(struct string));
	uint64_t *weight = malloc(BUF_MAX * sizeof(uint64_t));
	char *buf = malloc(BUF_MAX * sizeof(char));
	memset(buf, '\0', BUF_MAX * sizeof(char));
	memset(weight, '\0', BUF_MAX * sizeof(uint64_t));
	memset(str, '\0', BUF_MAX * sizeof(struct string));

	uint64_t start = 0;

	rc = read(0, buf, BUF_MAX);
	if ((rc = (errno) ? errno : 0))
		exit(1);

	uint64_t l = 0, r = 0, t = 0, foo = 0;

	struct string s;
	memset(s.v, 0, 512);
	start = 0;
	uint64_t len = 0;

	// get length
	while ((c = buf[count_line++]) != '\n') {
		if (c == ' ') {
			buf[count_line++] = '\0';
			len = atoll(buf + start);
			break;
		}
	}

	// get words
	while ((c = buf[count_line++]) != '\n') {
		if (c == ' ') {
			s.l = count_char;
			str[count_word++] = s;
			count_char = 0;
		} else {
			s.v[count_char++] = c;
		}
	}
	count_word = 0;
	start = count_line;

	// get weights
	while ((c = buf[count_line]) != '\n') {
		if (c == ' ') {
			buf[count_line++] = '\0';
			weight[count_word] = atoll(buf + start);
			start = count_line;
			count_word++;
		}
		count_line++;
	}

	// get num entries
	start = ++count_line;
	while ((c = buf[count_line]) != '\n') {
		count_line++;
	}
	buf[count_line++] = '\0';
	num_entries = atoll(buf + start);

	for (int i = 0; i < num_entries; i++) {
		uint64_t pos = 0;
		uint64_t acc = 0;
		start = count_line;

		while ((c = buf[count_line]) != ' ') {
			count_line++;
		}
		buf[count_line++] = '\0';

		l = atoll(buf + start);
		start = count_line;

		while ((c = buf[count_line]) != ' ') {
			count_line++;
		}
		buf[count_line++] = '\0';
		r = atoll(buf + start);

		t = 0;

		while (l != r) {
			start = count_line;
			str[l].v[1] = '\0';
			while (t++ < str[l].l) {
				for (int j = 0; j < str[l].l; j++) {
					printf("%d %lu\n", j, str[l].l);
					printf("buf\n-%s-\nbuf",buf+start+j);
					if (buf + start + j == (str[l].v) + j) {
							printf("here\n");
						if (j+1 == str[l].l){
							printf("there\n");
							acc += weight[l];
						}
					}
				}
				start++;
			}
			l++;
		}
		if (!i)
			tree = init(acc);
		else
			tree = insert(tree, acc);
	}
	printf("%lu %lu\n", get_min(tree), get_max(tree));
	exit(0);
}
