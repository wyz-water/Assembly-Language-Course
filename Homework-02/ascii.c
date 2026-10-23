#include <stdio.h>

int main(void)
{
    char ch = 'a';
    int row, col;

    for (row = 0; row < 2; row++) {
        for (col = 0; col < 13; col++) {
            printf("%c ", ch++);
        }
        printf("\n");
    }
    return 0;
}