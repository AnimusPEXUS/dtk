module dtk.interfaces.FormI;

import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LaFI;
// import dtk.interfaces.WidgetI;

import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.EventForm;
import dtk.types.WindowBorderSizes;
import dtk.types.Widget;

import dtk.miscs.signal_tools;

// import dtk.signal_mixins.Form;


interface FormI
{
    typeof(this) setWindow(WindowI value);
    typeof(this) unsetWindow();
    WindowI getWindow();

    Widget getMainWidget();

    void nonWindowEventReceiver(Event* event);
    void windowEventReceiver(Event* event);

    int getDesiredWidth();
    int getDesiredHeight();

    void redraw();
}
