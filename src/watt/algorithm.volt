//! Functions implementing generally applicable algorithms.
module watt.algorithm;


//! Takes two indices of elements to compare. Return `true` if the first parameter should go before the second.
alias CmpDg = scope dg(size_t, size_t) bool;
//! Takes two indices of elements to swap.
alias SwapDg = scope dg(size_t, size_t);

/*!
 * Sort something via delegates.
 * @param numElements The number of elements being sorted. If this is `1` or `0`, `runSort` will return immediately.
 * @param cmp A delegate that takes two indices. Compare two elements,
 * return `true` if the first parameter should be given precedence over
 * the second.
 * @param swap A delegate that gives two indices to swap.
 */
fn runSort(numElements: size_t, cmp: CmpDg, swap: SwapDg)
{
	if (numElements <= 1) {
		return;
	}
	qsort(0, numElements-1, cmp, swap);
}

/*!
 * Sort an array of integers in place.
 * ### Example
 * ```volt
 * a := [3, 1, 2];
 * sort(a);
 * assert(a == [1, 2, 3]);
 * ```
 */
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

/*!
 * Return the maximum of two values.
 * ### Examples
 * ```volt
 * assert(max(32, 16) == 32);
 * assert(max(32, 32) == 32);
 * assert(max(-32, 0) == 0);
 * ```
 * @{
 */
fn max(a: i32, b: i32) i32
{
	return a > b ? a: b;
}

fn max(a: i64, b: i64) i64
{
	return a > b ? a: b;
}

fn max(a: u32, b: u32) u32
{
	return a > b ? a: b;
}

fn max(a: u64, b: u64) u64
{
	return a > b ? a: b;
}

@mangledName("llvm.maxnum.f64") fn max(f64, f64) f64;
//! @}

/*!
 * Return the minimum of two values.
 * ### Examples
 * ```volt
 * assert(min(2, 4) == 2);
 * assert(min(2, 2) == 2);
 * assert(min(-2, 4) == -2);
 * ```
 * @{
 */
fn min(a: i32, b: i32) i32
{
	return a < b ? a: b;
}

fn min(a: i64, b: i64) i64
{
	return a < b ? a: b;
}

fn min(a: u32, b: u32) u32
{
	return a < b ? a: b;
}

fn min(a: u64, b: u64) u64
{
	return a < b ? a: b;
}

@mangledName("llvm.minnum.f64") fn min(f64, f64) f64;
//! @}


/*
 *
 * Sort implementation.
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
