module dtk.interfaces.WindowEventMgrI;

import std.format;

// import dtk.interfaces.event_receivers;
import dtk.interfaces.WindowI;

import dtk.types.Event;
import dtk.types.WindowEventMgrHandler;

interface WindowEventMgrI // : EventReceiverWindowI
{
	
    WindowI getWindow();
    
    void removeAllHandlers();
    
    static foreach (v; ["Window", "Keyboard", "Mouse", "TextInput"])
    {
        mixin(
        	q{
        		void add%1$sHandler(WindowEventMgr%1$sHandler eva);
        	}.format(v)
        	);
    }
    
    void handleEvent(Event* event);
}
