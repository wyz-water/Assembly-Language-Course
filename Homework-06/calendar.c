#include <stdio.h>

static int is_leap(int y)
{
    return (y % 400 == 0) || (y % 4 == 0 && y % 100 != 0);
}

static int days_in_month(int y, int m)
{
    static const int md[] = {31,28,31,30,31,30,31,31,30,31,30,31};
    int d = md[m - 1];
    if (m == 2 && is_leap(y))
        d = 29;
    return d;
}

static int day_of_week(int y, int m)
{
    static const int t[] = {0,3,2,5,0,3,5,1,4,6,2,4};
    if (m < 3)
        y--;
    return (y + y / 4 - y / 100 + y / 400 + t[m - 1] + 1) % 7;
}

int main(void)
{
    int y, m, w, d, i, day;
    static const char *names[] = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    };

    printf("year(1900-2099):");
    scanf("%d", &y);
    printf("month(1-12):");
    scanf("%d", &m);

    printf("   %s %d\n", names[m - 1], y);
    printf("Su Mo Tu We Th Fr Sa\n");

    w = day_of_week(y, m);
    d = days_in_month(y, m);
    for (i = 0; i < w * 3; i++)
        printf(" ");
    for (day = 1; day <= d; day++) {
        printf("%3d", day);
        if ((w + day) % 7 == 0)
            printf("\n");
    }
    printf("\n");
    return 0;
}