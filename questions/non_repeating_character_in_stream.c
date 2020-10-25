#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

/*
Problem Description

Given a string A denoting a stream of lowercase alphabets. You have to make new string B.

B is formed such that we have to find first non-repeating character each time a character is inserted to the stream and append it at the end to B. If no non-repeating character is found then append '#' at the end of B.

Example Input
Input 1:
 A = "abadbc"

Input 2:
 A = "abcabc"



Example Output
Output 1:
 "aabbdd"

Output 2:
 "aaabc#"


*/

/*

   We're going to need a way to see if an item has been seen multiple times.  We could go with a tree of sorts, keeping a tally of the nuber of times an element has been seen.

   we're going to store everything as a single bit in an unsigned integer array.

   It'll be really effecient in terms of memory.  It also has the added bonus of being faster to implement.

*/

// start with some constats, all 26 letters of the alphabet should fit in here 1 64bit uint

enum { LEN = 1, MAX = 100000, NONE = '#' };

/*
   We'll need to get the bitmask for a given char.
    turn it into it's corresponding integer and raise it to the power of 2
*/
uint64_t get_mask(char i)
{
	// sub optimal, we can implement a _really_ stripped down verion of pow with a switch/fallthrough/bit-shift later.
	return (pow(2, i - '0'));
}

/*
   now we can use the bitmask by locically OR'ing it with our storage
   */
void insert(char i, uint64_t *b)
{
	*b |= (get_mask(i));
}

// getting the member is easier we can just convert to an int, bit shift and check least significant bit
bool member(char i, uint64_t *b)
{
	return (*b >> (i - '0')) & 1;
}

void display(char *t, int i, int j)
{
	while (i <= j)
		printf("%c", t[i++]);
	printf("\n");
}

/*
   now for our approach.
*/

struct s {
	char *original; // pointer to the original string, we'll use that for checking for new characters
	char *input; // pointer too keep track of our location in the original string
	char r[MAX * sizeof(char)]; // return buffer
	char *ret; // pointer for our location in the return data
	uint64_t seen[LEN]; // storage for seen once
	uint64_t twice[LEN]; // storage for seen twice
};

/*
   we'll need a function to get the next character
   run through the original string, returning the first character that hasn't been seen more than once.
   If we've hit the end of the string return '#'

   */
char get_next(struct s s, char *i)
{
	if (!*i)
		return NONE;

	if (!member(*i, s.twice))
		return *i;

	return get_next(s, i + 1);
}

// now we run it
void run(struct s s, char res)
{
	// base case end of string
	if (!*s.input) {
		*s.ret = '\0';
		return;
	}

	// if we haven't seen a member, insert it into the first
	if (!member(*s.input, s.seen))
		insert(*s.input, s.seen);
	else
		// if we have, insert it into the second
		if (!member(*s.input, s.twice))
		insert(*s.input, s.twice);

	// if we don't have a result yet, take the first character
	if (!res)
		res = *s.input;
	// if we've seen this input before, get the next character in the original string
	else if (res == *s.input) {
		res = get_next(s, s.original);
	}

	// increment our buffer and working string, recur
	*s.ret++ = res;
	s.input++;
	run(s, res);
}
int main(void)
{
	uint64_t b[LEN] = {};
	struct s s = {};
	//s.original = "abcabc";
	s.original = "abadbc";
	s.input = s.original;
	s.ret = s.r;
	run(s, '\0');
	printf("%s\n", s.r);
}
