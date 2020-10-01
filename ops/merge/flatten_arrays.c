#include <stdio.h>
#include <string.h>
int main(void)
{

	int ar[2][3]= {{1,2,3},{4,5,6}};
	int buf[6];

	memcpy(buf, ar, sizeof(ar));

	for (int i = 0; i < 6; i++)
		printf("%d", buf[i]);
}
