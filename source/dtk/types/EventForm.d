module dtk.types.EventForm;

import std.typecons;

public import dtk.types.Event;

import dtk.types.Widget;
import dtk.types.Position2D;

struct EventForm
{
    Event* event;
    Widget focusedWidget;
    Widget mouseFocusedWidget;
    Tuple!(Widget, Position2D)[] mouseFocusedWidgetBreadCrumbs;
    int mouseFocusedWidgetX;
    int mouseFocusedWidgetY;
}
