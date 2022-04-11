module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Widget;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LafI;

import dtk.signal_mixins.Window;

import dtk.widgets.Form;

interface WindowI
{
    mixin(mixin_WindowSignals(true));
	// mixin(mixin_ContainerSignals(true));
	
    PlatformI getPlatform();

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
    int getWidth();
    int getHeight();
    
    int getFormWidth();
    int getFormHeight();
    
    WindowI setX(int v);
    WindowI setY(int v);
    WindowI setWidth(int v);
    WindowI setHeight(int v);

    dstring getTitle();
    WindowI setTitle(dstring value);
    
    Tuple!(bool, Position2D) getMousePosition();
    
    void redraw();
    
    // void handleEvent(Event* event);
}
