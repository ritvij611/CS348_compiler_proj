static int global_a = 10, global_b, global_arr[3] = { [0] = 1, 2, 3 };
unsigned long flags;
_Bool ok;

int sum(int a, int b) {
    int r;
    r = a + b;
    return r;
}

int variadic_demo(int first, ...) {
    int i = 0;
    int t = first;

start_label:
    if (i < 2) {
        i++;
        t += i;
        goto_like: t = t;
    } else {
        t -= 1;
    }

    while (i < 5) {
        ++i;
        if (i == 3) continue;
        if (i > 4) break;
        t = t + i;
    }

    do {
        t--;
    } while (t > 100);

    for (i = 0; i < 3; i = i + 1) {
        t = t + global_arr[i];
    }

    for (int j = 0; j < 3; j += 1) {
        t = t + j;
    }

    t = (t > 0) ? t : -t;
    t = (t, t + 1);

    t *= 2;
    t /= 2;
    t %= 5;
    t += 1;
    t -= 1;
    t <<= 1;
    t >>= 1;
    t &= 7;
    t ^= 1;
    t |= 2;

    t = t + (+i) - (-i);
    t = t + (~i);
    t = t + (!ok);

    case 0: t = t + 0;
    default: t = t + 1;

    return t;
}

int oldstyle(a, b)
int a;
int b;
{
    return a + b;
}

int main() {
    int x = 3;
    int y = 4;
    int z;
    char c = 'A';
    float f = 1.5e+2;
    z = sum(x, y);
    z = variadic_demo(z, 1, 2, 3);
    z = oldstyle(z, 2);
    z = z + c + f;
    if ((z > 0 && z < 1000) || z == 0) {
        z = z << 1;
    } else {
        z = z >> 1;
    }
    return z;
}
