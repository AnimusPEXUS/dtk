module dtk.signal_mixins.Window;

import std.format;

import dtk.miscs.signal_tools;

string mixin_WindowSignals(bool for_interface)
{
	string ret = q{
		// import dtk.types.EventWindow;
		import dtk.miscs.signal_tools;
		
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
	    mixin mixin_installSignal!(
	    	"Resized", 
	    	"signal_resized",
	    	%1$s,
	    	);
	}.format(for_interface);
	return ret;
}