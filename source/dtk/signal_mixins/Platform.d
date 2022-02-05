module dtk.signal_mixins.Platform;

import std.format;

string mixin_PlatformSignals(bool for_interface)
{
	string ret = q{
	    mixin mixin_installSignal!(
	    	"Timer500", 
	    	"signal_timer500",
	    	%1$s
	    	);
	    mixin mixin_installSignal!(
	    	"Event", 
	    	"signal_event",
	    	%1$s,
	    	Event*
	    	);
	}.format(for_interface);
	return ret;
}