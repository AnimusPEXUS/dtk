module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LafI;
// import dtk.interfaces.FormI;
// import dtk.interfaces.WindowEventMgrI;
// import dtk.interfaces.event_receivers;

// import dtk.miscs.mixin_event_handler_reg;

import dtk.widgets.Form;

import dtk.signal_mixins.Window;

interface WindowI
{
    PlatformI getPlatform();

    // WindowI setWindowEventMgr(WindowEventMgrI mgr);
    // WindowEventMgrI getWindowEventMgr();

    //void installForm(FormI form);
    //void uninstallForm();

    LafI getLaf();

    LafI getForcedLaf();
    typeof(this) setForcedLaf(LafI);
    typeof(this) unsetForcedLaf();    
    
    WindowI setForm(Form form);
    WindowI unsetForm();
    Form getForm();
    
    DrawingSurfaceI getDrawingSurface();

    int getX();
    int getY();
    ulong getWidth();
    ulong getHeight();
    
    ulong getFormWidth();
    ulong getFormHeight();
    
    WindowI setX(int v);
    WindowI setY(int v);
    WindowI setWidth(ulong v);
    WindowI setHeight(ulong v);

    /* static foreach(v; ["Window", "Keyboard", "Mouse", "TextInput"])
    {    	
    	mixin(mixin_event_handler_reg(v, true));
    } */
    
    dstring getTitle();
    WindowI setTitle(dstring value);

    mixin(mixin_WindowSignals(true));
    
    void redraw();
    
    // void handleEvent(Event* event);
}
