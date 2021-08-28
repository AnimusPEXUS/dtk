module dtk.interfaces.WidgetI;

import dtk.interfaces.FormI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Size2D;
import dtk.types.Position2D;

interface WidgetI
{
    WidgetI getParent();

    void setParent(WidgetI widget);
    void unsetParent();
    bool isUnsetParent();

    FormI getForm();

    DrawingSurfaceI getDrawingSurface();

    void positionAndSizeRequest(Position2D, Size2D);

    void handle_event_keyboard(EventKeyboard* e);
    void handle_event_mouse(EventMouse* e);
    void handle_event_textinput(EventTextInput* e);

    void redraw();
}
