module dtk.miscs.WindowEventMgr;

import std.stdio;
import std.typecons;
import std.format;

import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;
import dtk.interfaces.WindowEventMgrI;

import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.WindowEventMgrHandler;

union XEvent
{
    EventWindow* ewindow;
    EventKeyboard* ekeyboard;
    EventMouse* emouse;
    EventTextInput* etextinput;
}

enum XEventType : ubyte
{
    none,
    window,
    keyboard,
    mouse,
    textInput
}

class WindowEventMgr : WindowEventMgrI
{
	
    private
    {
        WindowI window;
    }
    
    this(WindowI window)
    {
        this.window = window;
    }
    
    WindowI getWindow()
    {
        return window;
    }
    
    private bool handle_event_search_and_call(alias listXActions, T1)(T1 event)
    {
        WidgetI focusedWidget;
        WidgetI mouseWidget;
        
        ulong widget_local_x;
        ulong widget_local_y;
        
        auto form = window.getForm();
        if (form !is null)
        {
            focusedWidget = form.getFocusedWidget();
        }
        
        // TODO: if mouse info isn't available - get it using platform
        
        static if (is(T1 == EventMouse*))
        {   
        	auto x = getWidgetAtPosition(Position2D(event.x, event.y));
            mouseWidget = x[0];
            widget_local_x = x[1];
            widget_local_y = x[2];          
        }
        
        bool processed;
        
        foreach (ref v; listXActions)
        {
            if (!v.any_focusedWidget && focusedWidget != v.focusedWidget)
                continue;
            
            if (!v.any_mouseWidget && mouseWidget != v.mouseWidget)
                continue;
            
            if (v.checkMatch !is null)
            if (
            	!v.checkMatch(
                	this, 
                	window, 
                	event, 
                	focusedWidget, 
                	mouseWidget,
                	widget_local_x, 
                	widget_local_y
                	)
                )
            continue;
            
            if (v.action !is null)
            processed = v.action(
            	this, 
            	window, 
            	event, 
            	focusedWidget, 
            	mouseWidget,
            	widget_local_x, 
            	widget_local_y
            	);
            
            continue;
        }
        
        return processed;
    }
    
    void handleEvent(Event* event)
    {
    	final switch (event.eventType)
    	{
    	case EventType.none:
    		break;
    		
    	case EventType.window:
    		handle_event_search_and_call!listWindowHandlers(event.ew);
    		break;
    	case EventType.keyboard:
    		handle_event_search_and_call!listKeyboardHandlers(event.ek);
    		break;
    	case EventType.mouse:
    		handle_event_search_and_call!listMouseHandlers(event.em);
    		break;
    	case EventType.textInput:
    		handle_event_search_and_call!listTextInputHandlers(event.eti);
    		break;
    	}
    }
    
    Tuple!(WidgetI, ulong, ulong) getWidgetAtPosition(Position2D point)
    {
        FormI form = window.getForm();
        if (form !is null)
        {
            return form.getWidgetAtPosition(point);
        }
        return tuple(cast(WidgetI) null, 0UL, 0UL);
    }
    
    static foreach (v; ["Window", "Keyboard", "Mouse", "TextInput"])
    {
    	mixin(
    		q{
    			private WindowEventMgr%1$sHandler[] list%1$sHandlers;
    			void add%1$sHandler(WindowEventMgr%1$sHandler eva) { 
    				list%1$sHandlers ~= eva; 
    			}
    		}.format(v)
    		);    	
    }
    
    void removeAllHandlers()
    {
        static foreach (v; ["Window", "Keyboard", "Mouse", "TextInput"])
        {
            mixin(q{list%1$sHandlers = [];}.format(v));
        }
    }
    
}



