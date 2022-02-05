module dtk.interfaces.WidgetI;

import std.typecons;
import std.format;

// import dtk.interfaces.FormI;
// import dtk.interfaces.LayoutI;
import dtk.interfaces.ContainerI;
//import dtk.interfaces.ContainerableI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.event_receivers;

// import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.widgets.Form;
import dtk.widgets.Layout;

// import dtk.miscs.mixin_event_handler_reg;

interface WidgetI // : ContainerableI
{
    Form getForm();
    
    DrawingSurfaceI getDrawingSurface();
    
    //void positionAndSizeRequest(Position2D, Size2D);
    void propagatePosAndSizeRecalc();
    
    void redraw();
    
    // Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point);
    
    WidgetI getNextFocusableWidget();
    WidgetI getPrevFocusableWidget();
    
    // static foreach(v; ["Keyboard", "Mouse", "TextInput"])
    // {
    // mixin(mixin_event_handler_reg(v, true));
    // }
    
    typeof(this) setParent(ContainerI container);
    typeof(this) unsetParent();
    ContainerI getParent();
    
    static foreach (v; ["X", "Y", "Width", "Height"])
    {
    	mixin(
    		q{
    			ulong get%1$s();
    			typeof(this) set%1$s(ulong v);
    		}.format(v)
    		);
    }
    
    void redraw();
    void propagatePosAndSizeRecalc();
}
