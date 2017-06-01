module watt.text.diff;

import watt.io.std;
import watt.text.string;

/*!
 * Print the difference between two strings, line-by-line, to stdout.
 */
fn diff(a: const(char)[], b: const(char)[]) void
{
	c: size_t[];
	w: size_t;
	A := [" "] ~ split(a, '\n');
	B := [" "] ~ split(b, '\n');
	lcs(A, B, out c, out w);
	printDiff(c, w, A, B, A.length-1, B.length-1);
}

private:

fn printDiff(c :size_t[], w: size_t,
             a: const(char)[][], b: const(char)[][], i: size_t, j: size_t) void
{
	if (i > 0 && j > 0 && a[i] == b[j]) {
		printDiff(c, w, a, b, i-1, j-1);
		writefln(" %s", a[i]);
	} else if (j > 0 && (i == 0 || c[i*w+(j-1)] >= c[(i-1)*w+j])) {
		printDiff(c, w, a, b, i, j-1);
		writefln("+%s", b[j]);
	} else if (i > 0 && (j == 0 || c[i*w+(j-1)] < c[(i-1)*w+j])) {
		printDiff(c, w, a, b, i-1, j);
		writefln("-%s", a[i]);
	}
}

/*!
 * Generate a longest common substring (LCS) matrix.
 * c contains the values, w contains the width of the matrix.
 */
fn lcs(a: const(char)[][], b: const(char)[][],
       out c :size_t[], out w: size_t) void
{
	w = b.length;
	c = new size_t[](a.length * b.length);
	foreach (i; 1 .. a.length) {
		foreach (j; 1 .. b.length) {
			if (a[i] == b[j]) {
				c[i*w+j] = c[(i-1)*w+(j-1)]+1;
			} else {
				l := c[i*w+(j-1)];
				r := c[(i-1)*w+j];
				c[i*w+j] = l > r ? l: r;
			}
		}
	}
}

