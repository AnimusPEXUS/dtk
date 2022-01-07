module dtk.miscs.recursionGuard;

import core.sync.mutex;

// TODO: all this is not tested

T2 recursionGuard(T2, T1...)
(
	ref bool already_called,
	ref Mutex call_mutex,
	T2 delegate() already_started_call,
	T2 delegate(T1) target
	)
{
    synchronized (call_mutex)
    {
        if (already_called)
        {
        	debug
        	{
        		import std.stdio;
        		writeln("recursionGuard detected recurcive call");
        	}
            return already_started_call();
        }
        
        already_called = true;
        scope (exit) {already_called = false;}
        
        return target(T1);
    }
}

T2 recursionGuard(T2, T1...)(
	ref bool already_called,
	ref Mutex call_mutex,
	T2 already_started_return,
	T2 delegate(T1) target
	)
{
    return recursionGuard(
    	already_called,
    	call_mutex,
    	delegate T2() {
    		return already_started_return;
    	},
    	target,
    	);
}

unittest
{
	debug
	{
		import std.stdio;
		writeln("Testing recursionGuard");
	}
	
	{
		bool called;
		Mutex mtx = new Mutex();
		
		int t1() {
			int x = recursionGuard(
				called,
				mtx,
				cast(int)11,
				delegate int()
				{
					debug writeln("target called");
					assert(t1() == 11);
					return 10 ;
				}
				);
			return x;
		}
		
		assert(t1() == 10);
	}
}
