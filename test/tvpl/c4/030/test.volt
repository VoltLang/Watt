module test;

fn main() i32
{
	assert((0b0000 | 0b0001) == 0b0001);
	assert((0b0001 | 0b0001) == 0b0001);
	assert((0b0000 | 0b0000) == 0b0000);
	assert((0b0001 & 0b0001) == 0b0001);
	assert((0b0000 & 0b0001) == 0b0000);
	assert((0b0001 & 0b0000) == 0b0000);
	assert((0b0000 ^ 0b0001) == 0b0001);
	assert((0b0001 ^ 0b0001) == 0b0000);
	assert((0b0000 ^ 0b0000) == 0b0000);
	assert((0b0001 << 1    ) == 0b0010);
	assert((0b0001 << 2    ) == 0b0100);
	assert((0b1000 >> 1    ) == 0b0100);
	assert((0b1000 >> 2    ) == 0b0010);
	return 0;
}
