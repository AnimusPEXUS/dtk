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
import dtk.types.WindowBorderSizes;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LaFI;

import dtk.signal_mixins.Window;

import dtk.widgets.Form;

interface WindowI
{
    mixin(mixin_WindowSignals(true));
	// mixin(mixin_ContainerSignals(true));
	
    PlatformI getPlatform();

    LaFI getLaf();

    LaFI getForcedLaf();
    WindowI setForcedLaf(LaFI);
    WindowI unsetForcedLaf();    
    
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
    
    WindowBorderSizes getBorderSizes();
    
    void redraw();
    
    // void handleEvent(Event* event);
}
