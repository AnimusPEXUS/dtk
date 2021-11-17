module dtk.types.Signal;

import observable.signal;


mixin template installSignal(
	string name,
	string var_name,
	P...
	)
{
	import std.format;
	
	private {
		mixin(
			q{
				Signal!(P) %1$s;
			}.format(var_name)
			);
		
	}
	
	
}