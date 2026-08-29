// ===============================
// SINGLE LINE COMMENT TEST
// ===============================

// keywords test
int main() {
    break;
    default:
    return 0;
    void_func();
    case 1:
    float f = 3.14;
    short s = 10;
    double d = 99.999;
    char ch = 'a';
    for (int i = 0; i < 10; i++) {
        signed x = -5;
        while (x < 0) {
            x++;
        }
    }
    else_label:
    unsigned u = 100;
    long l = 99999;
    Bool flag = 1;
    continue;
    if (flag) {
        static int z = 0;
    }
    do {
        z--;
    } while (z > 0);
}

// ===============================
// IDENTIFIER TEST
// ===============================

int a;
int _underscore;
int var123;
int VERYLONGIDENTIFIERNAME12345;
int mix_123_name;
int a1b2c3;

// ===============================
// INTEGER CONSTANT TEST
// ===============================

int x = 1;
int y = 12345;
int z = 999999999;

// invalid (leading zero not allowed in your grammar)
int bad1 = 0123;

// ===============================
// FLOATING CONSTANT TEST
// ===============================

float f1 = 1.23;
float f2 = .45;
float f3 = 10.;
float f4 = 123.456789;

// ===============================
// CHARACTER CONSTANT TEST
// ===============================

char c1 = 'a';
char c2 = 'Z';
char c3 = '0';

// escape sequences
char c4 = '\n';
char c5 = '\t';
char c6 = '\\';
char c7 = '\'';
char c8 = '\?';

// ===============================
// STRING LITERAL TEST
// ===============================

"simple string"
"string with spaces"
"string with escape \n \t \\ \" "
"1234567890"

// ===============================
// PUNCTUATORS TEST
// ===============================

int arr[10];
a = b + c - d * e / f % g;

a++;
b--;
c += 5;
d -= 3;
e *= 2;
f /= 4;
g %= 2;

if (a == b && c != d || e < f) {
    a <<= 1;
    b >>= 1;
}

x = (a > b) ? a : b;

ptr->value;

a = b & c;
a = b | c;
a = b ^ c;
a = ~b;

a = !b;

;

// ===============================
// MULTI-LINE COMMENT TEST
// ===============================

/*
   This is a multi-line comment
   It should be completely ignored
   Even if it contains symbols like:
   + - * / == != && ||
*/

// ===============================
// MIXED COMPLEX CODE
// ===============================

int complex_function(int p1, float p2) {
    int result = p1;

    for (int i = 0; i < 10; i++) {
        result += i * (int)p2;
    }

    if (result > 100) {
        return result;
    } else {
        return 0;
    }
}

// ===============================
// ERROR TESTING
// ===============================

@
#
$
`


// invalid identifiers
int 1abc;
int @var;

// invalid char constants
char badc1 = '';
char badc2 = 'ab';

// unterminated string
"this string is not closed
