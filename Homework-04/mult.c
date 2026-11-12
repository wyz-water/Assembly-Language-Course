#include <stdio.h>

int main(void)
{
    int a, b;
    for (a = 9; a >= 1; a--) {
        for (b = 9; b >= 1; b--)
            printf("%d*%d=%d ", a, b, a * b);
        printf("\n");
    }
    return 0;
}