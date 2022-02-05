module dtk.signal_mixins.Window;

import std.format;

string mixin_WindowSignals(bool for_interface)
{
	string ret = q{
		
	    mixin mixin_installSignal!(
	    	"WindowEvents", 
	    	"signal_window_events",
	    	%1$s,
	    	EventWindow*
	    	);
	    mixin mixin_installSignal!(
	    	"OtherEvents", 
	    	"signal_other_events",
	    	%1$s,
	    	Event*
	    	);
	}.format(for_interface);
	return ret;
}