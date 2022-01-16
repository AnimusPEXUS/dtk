module dtk.interfaces.WidgetI;

import std.typecons;

import dtk.interfaces.FormI;
import dtk.interfaces.LayoutI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.event_receivers;

// import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.widgets.Layout;

import dtk.miscs.mixin_event_handler_reg;

interface WidgetI
{
    WidgetI setParentLayout(LayoutI layout);
    WidgetI unsetParentLayout();
    bool isUnsetParentLayout();
    LayoutI getParentLayout();
    
    FormI getForm();
    
    DrawingSurfaceI getDrawingSurface();
    
    void positionAndSizeRequest(Position2D, Size2D);
    void recalculateChildrenPositionsAndSizes();
    void redraw();
    
    ulong getX();
    ulong getY();
    ulong getWidth();
    ulong getHeight();
    
    WidgetI setX(ulong);
    WidgetI setY(ulong);
    WidgetI setWidth(ulong);
    WidgetI setHeight(ulong);
    
    Tuple!(WidgetI, ulong, ulong) getWidgetAtPosition(Position2D point);
    
    WidgetI getNextFocusableWidget();
    WidgetI getPrevFocusableWidget();
    
    static foreach(v; ["Keyboard", "Mouse", "TextInput"])
    {    	
    	mixin(mixin_event_handler_reg(v, true));
    }
}
