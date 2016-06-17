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
void runSort(size_t numElements, CmpDg cmp, SwapDg swap)
{
	qsort(0, numElements-1, cmp, swap);
}

void sort(int[] ints)
{
	bool cmp(size_t ia, size_t ib)
	{
		return ints[ia] < ints[ib];
	}

	void swap(size_t ia, size_t ib)
	{
		int tmp = ints[ia];
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

size_t max(size_t a, size_t b)
{
	return a > b ? a : b;
}

size_t min(size_t a, size_t b)
{
	return a < b ? a : b;
}

int max(int a, int b)
{
	return a > b ? a : b;
}

int min(int a, int b)
{
	return a < b ? a : b;
}

double max(double a, double b)
{
	return a > b ? a : b;
}

double min(double a, double b)
{
	return a < b ? a : b;
}


/*
 *
 * Sort helpers.
 *
 */

private void qsort(size_t lo, size_t hi, CmpDg cmp, SwapDg swap)
{
	if (lo < hi) {
		p := partition(lo, hi, cmp, swap);
		mid1 := p == 0 ? 0 : p - 1;
		mid2 := p == size_t.max ? size_t.max : p + 1;
		qsort(lo, mid1, cmp, swap);
		qsort(mid2, hi, cmp, swap);
	}
}

private size_t partition(size_t lo, size_t hi, CmpDg cmp, SwapDg swap)
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

private size_t choosePivot(size_t lo, size_t hi)
{
	return lo + ((hi - lo) / 2);
}
