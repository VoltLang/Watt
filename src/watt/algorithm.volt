module watt.algorithm;


/// Takes to indicies of elements to compare.
alias CmpDg = scope bool delegate(size_t, size_t);
/// Takes to indicies of elements to swap.
alias SwapDg = scope void delegate(size_t, size_t);

/**
 * Runs a sorting algorithm on the given delegates.
 *
 * They are given indicies on an array you manage.
 */
fn runSort(numElements : size_t, cmp : CmpDg, swap : SwapDg)
{
	qsort(0, numElements-1, cmp, swap);
}

fn sort(ints : i32[])
{
	fn cmp(ia : size_t, ib : size_t) bool
	{
		return ints[ia] < ints[ib];
	}

	fn swap(ia : size_t, ib : size_t)
	{
		i32 tmp = ints[ia];
		ints[ia] = ints[ib];
		ints[ib] = tmp;
	}

	runSort(ints.length, cmp, swap);
}


/*
 *
 * Compare functions.
 *
 */

fn max(a : size_t, b : size_t) size_t
{
	return a > b ? a : b;
}

fn min(a : size_t, b : size_t) size_t
{
	return a < b ? a : b;
}

fn max(a : i32, b : i32) i32
{
	return a > b ? a : b;
}

fn min(a : i32, b : i32) i32
{
	return a < b ? a : b;
}

fn max(a : f64, b : f64) f64
{
	return a > b ? a : b;
}

fn min(a : f64, b : f64) f64
{
	return a < b ? a : b;
}


/*
 *
 * Sort helpers.
 *
 */

private fn qsort(lo : size_t, hi : size_t, cmp : CmpDg, swap : SwapDg)
{
	if (lo < hi) {
		p := partition(lo, hi, cmp, swap);
		mid1 := p == 0 ? 0 : p - 1;
		mid2 := p == size_t.max ? size_t.max : p + 1;
		qsort(lo, mid1, cmp, swap);
		qsort(mid2, hi, cmp, swap);
	}
}

private fn partition(lo : size_t, hi : size_t, cmp : CmpDg, swap : SwapDg) size_t
{
	pivotIndex := choosePivot(lo, hi);
	swap(pivotIndex, hi);
	storeIndex := lo;
	for (size_t i = lo; i <= hi - 1; ++i) {
		if (cmp(i, hi)) {
			swap(i, storeIndex);
			storeIndex++;
		}
	}
	swap(storeIndex, hi);
	return storeIndex;
}

private fn choosePivot(lo : size_t, hi : size_t) size_t
{
	return lo + ((hi - lo) / 2);
}
