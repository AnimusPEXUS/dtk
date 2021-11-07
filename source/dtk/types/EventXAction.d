module dtk.types.EventXAction;

mixin template mixin_EventXAction(string subject)
{
	import std.format;
	
    mixin(
    	q{
    		import dtk.interfaces.WindowEventMgrI;
    		import dtk.interfaces.WidgetI;
    		import dtk.interfaces.WindowI;
    		
    		import dtk.types.Event%1$s;
    		
    		struct Event%1$sAction
    		{
    			// if not matched prefilter - checkMatch call will not happen
    			// ------- prefilter start -------
    			bool any_focusedWidget;
    			bool any_mouseWidget;
    			
    			// not checked if any_focusedWidget is true
    			WidgetI focusedWidget;
    			
    			// not checked if any_mouseWidget is true
    			WidgetI mouseWidget;
    			// ------- prefilter end -------
    			
    			/// if true is not returned - action will not be called.  checkMatch is not
    			/// called (and it's return assumed to be false) if prefilter isn't matched
    			bool delegate(
    				WindowEventMgrI mgr, 
    				WindowI window, 
    				Event%1$s* e, 
    				WidgetI focusedWidget, 
    				WidgetI mouseWidget, 
    				ulong mouseWidget_x, 
    				ulong mouseWidget_y
    				) checkMatch;
    			
    			/// this is called then all filters successfully passed.
    			/// if false returned - event manager shoud continue to search for action handler.
    			/// if true returned - event manager should not continue search for action handler.
    			bool delegate(
    				WindowEventMgrI mgr, 
    				WindowI window, 
    				Event%1$s* e, 
    				WidgetI focusedWidget, 
    				WidgetI mouseWidget, 
    				ulong mouseWidget_x, 
    				ulong mouseWidget_y
    				) action;
    		}
		}.format(subject)
		);
}

static foreach (v; ["Window", "Keyboard", "Mouse", "TextInput"])
{
    mixin mixin_EventXAction!v;
}

// TODO: remove this?
union EventXAction
{
    EventWindowAction ewa;
    EventKeyboardAction eka;
    EventMouseAction ema;
    EventTextInputAction etia;
}
