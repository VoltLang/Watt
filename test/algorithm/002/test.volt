module test;

import core.object : Object;

import watt.algorithm;

class Bar
{
	int f;

	bool sort(Object ao, Object bo)
	{
		assert(ao !is null && bo !is null);
		auto a = cast(Bar) ao;
		auto b = cast(Bar) bo;
		return a.f > b.f;
	}
}

int main()
{
	auto a = new Bar();
	auto b = new Bar();

	a.f = 8;
	b.f = 42;

	auto arr = new Bar[](2);
	arr[0] = a;
	arr[1] = b;

	bool cmp(size_t ia, size_t ib)
	{
		return arr[ia].sort(arr[ia], arr[ib]);
	}

	void swap(size_t ia, size_t ib)
	{
		auto tmp = arr[ia];
		arr[ia] = arr[ib];
		arr[ib] = tmp;
	}


	runSort(arr.length, cmp, swap);

	return (cast(Bar)arr[0]).f - 42;
}
