module dtk.signal_mixins.Window;

import std.format;

import dtk.miscs.signal_tools;

string mixin_WindowSignals(bool for_interface)
{
	string ret = q{
		import dtk.types.EventWindow;
		import dtk.miscs.signal_tools;
		
	    mixin mixin_installSignal!(
	    	"WindowEvent", 
	    	"signal_window_event",
	    	%1$s,
	    	EventWindow*
	    	);
	    mixin mixin_installSignal!(
	    	"FormEvents", 
	    	"signal_form_events",
	    	%1$s,
	    	Event*
	    	);
	}.format(for_interface);
	return ret;
}