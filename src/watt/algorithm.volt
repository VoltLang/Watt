module watt.algorithm;

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
		qsort(objects, lo, p - 1, cmp);
		qsort(objects, p + 1, hi, cmp);
	}
}

private size_t partition(object.Object[] objects, size_t lo, size_t hi, cmpfn cmp)
{
	size_t pivotIndex = choosePivot(objects, lo, hi);
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

private size_t choosePivot(object.Object[] objects, size_t lo, size_t hi)
{
	return lo + ((hi - lo) / 2);
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

