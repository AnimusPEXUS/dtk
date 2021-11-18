module dtk.types.Signal;

import observable.signal;


mixin template installSignal(
	string name,
	string var_name,
	P...
	)
{
	import std.format;
	import observable.signal;
	
	private {
		mixin(
			q{
				Signal!(P) %1$s;
			}.format(var_name)
			);
		
	}
	
	mixin(
		q{
			SignalConnection connectTo_%1$s( void delegate(P) nothrow cb)
			{
				SignalConnection conn;
				this.%2$s.socket.connect(conn, cb);
				return conn;
			}
		}.format(name,var_name)
		);
	
}