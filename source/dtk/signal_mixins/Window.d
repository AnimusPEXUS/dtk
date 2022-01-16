module dtk.signal_mixins.Window;

import std.format;

import dtk.miscs.Window_tools;

string mixin_PlatformSignals(bool for_interface)
{
	string ret = q{
	    mixin mixin_installSignal!(
	    	"Close", 
	    	"signal_close",
	    	%1$s,
	    	false
	    	);
	    mixin mixin_installSignal!(
	    	"Move", 
	    	"signal_move",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Resize", 
	    	"signal_resize",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Maximize", 
	    	"signal_maximize",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Unmaximize", 
	    	"signal_unmaximize",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Minimize", 
	    	"signal_minimize",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Unminimize", 
	    	"signal_unminimize",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Restore", 
	    	"signal_restore",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Show", 
	    	"signal_show",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Hide", 
	    	"signal_hide",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Expose", 
	    	"signal_expose",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"KeyboardFocus", 
	    	"signal_keyboardFocus",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"KeyboardUnFocus", 
	    	"signal_keyboardUnFocus",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"MouseFocus", 
	    	"signal_mouseFocus",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"MouseUnFocus", 
	    	"signal_mouseUnFocus",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"Focus", 
	    	"signal_focus",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"UnFocus", 
	    	"signal_unFocus",
	    	%1$s,
	    	false,
	    	);
	    mixin mixin_installSignal!(
	    	"FocusProposed", 
	    	"signal_focusProposed",
	    	%1$s,
	    	false,
	    	);
	}.format(for_interface);
	return ret;
}