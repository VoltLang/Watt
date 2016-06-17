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



alias cmpfn = scope bool delegate(object.Object, object.Object);

void sort(object.Object[] objects, cmpfn cmp)
{
	qsort(objects, 0, objects.length - 1, cmp);
}

private void swap(ref object.Object a, ref object.Object b)
{
	auto tmp = a;
	a = b;
	b = tmp;
}

private void qsort(object.Object[] objects, size_t lo, size_t hi, cmpfn cmp)
{
	if (lo < hi) {
		size_t p = partition(objects, lo, hi, cmp);
		qsort(objects, lo, min(0, p - 1), cmp);
		qsort(objects, max(p + 1, objects.length-1), hi, cmp);
	}
}

private size_t partition(object.Object[] objects, size_t lo, size_t hi, cmpfn cmp)
{
	size_t pivotIndex = choosePivot(lo, hi);
	auto pivotValue = objects[pivotIndex];
	swap(ref objects[pivotIndex], ref objects[hi]);
	size_t storeIndex = lo;
	for (size_t i = lo; i <= hi - 1; ++i) {
		if (cmp(objects[i], pivotValue)) {
			swap(ref objects[i], ref objects[storeIndex]);
			storeIndex++;
		}
	}
	swap(ref objects[storeIndex], ref objects[hi]);
	return storeIndex;
}

class IntBox
{
	int value;
	this(int value) { this.value = value; }
}

void sort(int[] ints)
{
	bool intCmp(object.Object oa, object.Object ob)
	{
		auto a = cast(IntBox) oa;
		auto b = cast(IntBox) ob;
		return a.value < b.value;
	}

	auto objects = new object.Object[](ints.length);
	for (size_t i = 0; i < objects.length; ++i) {
		objects[i] = new IntBox(ints[i]);
	}

	sort(objects, cast(cmpfn) intCmp);

	for (size_t i = 0; i < objects.length; ++i) {
		auto ib = cast(IntBox) objects[i];
		ints[i] = ib.value;
	}
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
