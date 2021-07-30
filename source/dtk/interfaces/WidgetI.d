module dtk.interfaces.WidgetI;

import dtk.interfaces.FormI;
/* import dtk.interfaces.WidgetLocatorI; */

import dtk.types.Size;
import dtk.types.Point;

interface WidgetI
{
    WidgetI getParent();
    void setParent(WidgetI widget);
    void unsetParent();

    /* WidgetLocatorI getWidgetLocator(); */

    FormI getForm();

    void event_mouse();
    void event_keyboard();

    void redraw();
}
