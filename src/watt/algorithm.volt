//! Generally applicable algorithms.
module watt.algorithm;


//! Takes to indicies of elements to compare.
alias CmpDg = scope dg(size_t, size_t) bool;
//! Takes to indicies of elements to swap.
alias SwapDg = scope dg(size_t, size_t);

/*!
 * Runs a sorting algorithm on the given delegates.
 *
 * They are given indicies on an array you manage.
 */
fn runSort(numElements: size_t, cmp: CmpDg, swap: SwapDg)
{
	qsort(0, numElements-1, cmp, swap);
}

//! Sort an array of integers in place.
fn sort(ints: i32[])
{
	fn cmp(ia: size_t, ib: size_t) bool
	{
		return ints[ia] < ints[ib];
	}

	fn swap(ia: size_t, ib: size_t)
	{
		tmp: i32 = ints[ia];
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

//! Return the maximum of two values.
fn max(a: i32, b: i32) i32
{
	return a > b ? a: b;
}

//! Return the minimum of two values.
fn min(a: i32, b: i32) i32
{
	return a < b ? a: b;
}

//! Return the maximum of two values.
fn max(a: i64, b: i64) i64
{
	return a > b ? a: b;
}

//! Return the minimum of two values.
fn min(a: i64, b: i64) i64
{
	return a < b ? a: b;
}

//! Return the maximum of two values.
fn max(a: u32, b: u32) u32
{
	return a > b ? a: b;
}

//! Return the minimum of two values.
fn min(a: u32, b: u32) u32
{
	return a < b ? a: b;
}

//! Return the maximum of two values.
fn max(a: u64, b: u64) u64
{
	return a > b ? a: b;
}

//! Return the minimum of two values.
fn min(a: u64, b: u64) u64
{
	return a < b ? a: b;
}

//! Return the maximum of two values.
fn max(a: f64, b: f64) f64
{
	return a > b ? a: b;
}

//! Return the minimum of two values.
fn min(a: f64, b: f64) f64
{
	return a < b ? a: b;
}


/*
 *
 * Sort helpers.
 *
 */

private fn qsort(lo: size_t, hi: size_t, cmp: CmpDg, swap: SwapDg)
{
	if (lo < hi) {
		p := partition(lo, hi, cmp, swap);
		mid1 := p == 0 ? 0: p - 1;
		mid2 := p == size_t.max ? size_t.max: p + 1;
		qsort(lo, mid1, cmp, swap);
		qsort(mid2, hi, cmp, swap);
	}
}

private fn partition(lo: size_t, hi: size_t, cmp: CmpDg, swap: SwapDg) size_t
{
	pivotIndex := choosePivot(lo, hi);
	swap(pivotIndex, hi);
	storeIndex := lo;
	for (i: size_t = lo; i <= hi - 1; ++i) {
		if (cmp(i, hi)) {
			swap(i, storeIndex);
			storeIndex++;
		}
	}
	swap(storeIndex, hi);
	return storeIndex;
}

private fn choosePivot(lo: size_t, hi: size_t) size_t
{
	return lo + ((hi - lo) / 2);
}
