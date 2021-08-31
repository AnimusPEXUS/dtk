module dtk.interfaces.WidgetI;

import std.typecons;

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

    typeof(this) setParent(WidgetI widget);
    typeof(this) unsetParent();
    bool isUnsetParent();

    FormI getForm();

    DrawingSurfaceI getDrawingSurface();

    void positionAndSizeRequest(Position2D, Size2D);
    void recalculateChildrenPositionsAndSizes();

    typeof(this) setPosition(Position2D);
    typeof(this) unsetPosition();
    Position2D getPosition();
    bool isUnsetPosition();

    typeof(this) setSize(Size2D);
    typeof(this) unsetSize();
    Size2D getSize();
    bool isUnsetSize();

    bool handle_event_keyboard(EventKeyboard* e);
    bool handle_event_mouse(EventMouse* e);
    bool handle_event_textinput(EventTextInput* e);

    void redraw();

    WidgetI getWidgetAtVisible(Position2D point);

}
