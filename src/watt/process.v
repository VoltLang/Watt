
module watt.process;



int spawnProcessLinux(string name,
                      string[] args,
                      int stdin_,
                      int stdout_,
                      int stderr_)
{
	auto stack = new char[16384];
	auto argz = new char*[256];

	toArgz(stack, argz, name, args);

	return 0;
}

void toArgz(char[] stack, char*[] result, string name, string[] args)
{
	size_t resultPos;

	result[resultPos++] = stack.ptr;
	stack[0 .. name.length] = name;
	stack[name.length] = cast(char)0;
	stack = stack[0 .. name.length + cast(uint)1];

	for (uint i; i < args.length; i++) {
		result[resultPos++] = stack.ptr;

		auto arg = args[i];
		stack[0 .. name.length] = arg;
		stack[name.length] = cast(char)0;

		stack = stack[0 .. arg.length + cast(uint)1];
	}

	return;
}
