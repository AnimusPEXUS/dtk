module dtk.miscs.RecursionGuard;

import core.sync.mutex;

// TODO: all this is not tested

// T2 RecursionGuard(
	// T2 delegate() already_started_call,
	// T2 delegate() target	
	// )
// {
    // __gshared static bool started = false;
    // __gshared static Mutex mtx;
// 
    // synchronized (mtx)
    // {
        // if (started)
        // {
            // return already_started_call();
        // }
// 
        // started = true;
        // scope (exit) {started = false;} 
// 
        // return target();
    // }
// }

T2 RecursionGuard(T2, T1...)(
	T2 delegate() already_started_call,
	T2 delegate(T1) target	
	)
{
    __gshared static bool started = false;
    __gshared static Mutex mtx;

    synchronized (mtx)
    {
        if (started)
        {
            return already_started_call();
        }

        started = true;
        scope (exit) {started = false;} 

        return target(T1);
    }
}

T2 RecursionGuard(T2, T1...)(
	T2 already_started_return,
	T2 delegate(T1) target)
{
    return RecursionGuard(
    	delegate T2() { return already_started_return; },
    	target, 
    	);
}

unittest {
	pragma(msg, "Testing RecursionGuard");
	
	import std.stdio;

	{
		int t1() {
			int x = RecursionGuard(
				cast(int)11,
				delegate int() 
				{ 
					writeln("target called");
					assert(t1() == 11);
					return 10 ; 
				}
				);
			return x;
		}
		
		assert(t1() == 10);
	}
}
