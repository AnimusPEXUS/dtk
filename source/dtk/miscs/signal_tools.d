module dtk.miscs.signal_tools;

import observable.signal;

public import observable.signal : SignalConnection, SignalConnectionContainer;


mixin template mixin_installSignal(
	string name,
	string var_name,
	bool for_interface,
	bool define_before,
	P...
	)
{
	import std.format;
	import observable.signal;
	
	static if (!for_interface)
	{
		private {
			mixin(
				q{
					Signal!(P) %1$s;
				}.format(var_name)
				);
			
			static if (define_before)
			{
				mixin(
					q{
						Signal!(P) before_%1$s;
					}.format(var_name)
					);
			}
		}
	}
	
	static if (!for_interface)
	{
		mixin(
			q{
				SignalConnection connectToSignal_%1$s( void delegate(P) nothrow cb)
				{
					SignalConnection conn;
					this.%2$s.socket.connect(conn, cb);
					return conn;
				}
			}.format(name,var_name)
			);
		
		static if (define_before)
		{
			mixin(
				q{
					SignalConnection connectToSignalBefore_%1$s( void delegate(P) nothrow cb)
					{
						SignalConnection conn;
						this.before_%2$s.socket.connect(conn, cb);
						return conn;
					}
				}.format(name,var_name)
				);
		}
	}
	else
	{
		mixin(
			q{
				SignalConnection connectToSignal_%1$s( void delegate(P) nothrow cb);
			}.format(name)
			);
		
		static if (define_before)
		{
			mixin(
				q{
					SignalConnection connectToSignalBefore_%1$s( void delegate(P) nothrow cb);
				}.format(name)
				);
		}
	}
}
