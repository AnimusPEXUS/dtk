module dtk.interfaces.WidgetI;

import std.typecons;
import std.format;

// import dtk.interfaces.FormI;
// import dtk.interfaces.LayoutI;
import dtk.interfaces.ContainerI;
//import dtk.interfaces.ContainerableI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.event_receivers;

import dtk.types.Event;
import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.Image;

import dtk.widgets.Form;
import dtk.widgets.Layout;

// import dtk.miscs.mixin_event_handler_reg;

interface WidgetI // : ContainerableI
{
    Form getForm();
    
    DrawingSurfaceI getDrawingSurface();
    
    Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point);
    
    WidgetI getNextFocusableWidget();
    WidgetI getPrevFocusableWidget();
    
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
    
	Image renderImage(ulong x, ulong y, ulong w, ulong h);
	Image renderImage();
    void redraw();
    void propagatePosAndSizeRecalc();
    Image propagateRedraw();
    void propagateParentChangeEmision();
    
    void focusEnter(Form form, WidgetI widget);
    void focusExit(Form form, WidgetI widget);
    
    bool isVisualPressed();
    void visualPress(Form form, WidgetI widget, EventForm* event);
    void visualRelease(Form form, WidgetI widget, EventForm* event);
    
    void intMousePress(Form form, WidgetI widget, EventForm* event);
    void intMouseRelease(Form form, WidgetI widget, EventForm* event);
    void intMousePressRelease(Form form, WidgetI widget, EventForm* event);
    void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event);
    void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event);
    void intMouseMove(Form form, WidgetI widget, EventForm* event);
    
    void intKeyboardPress(Form form, WidgetI widget, EventForm* event);
    void intKeyboardRelease(Form form, WidgetI widget, EventForm* event);
    
    void intTextInput(Form form, WidgetI widget, EventForm* event);
    
    // void intMouseDragStart();
    // void intMouseDragStop();
    // void drawChild(WidgetI child, Image img);
    // void drawChild(DrawingSurfaceI ds, WidgetI child, Image img);
}
