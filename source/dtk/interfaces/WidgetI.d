module dtk.interfaces.WidgetI;

import std.typecons;

import dtk.interfaces.FormI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.event_receivers;

import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Size2D;
import dtk.types.Position2D;

interface WidgetI : EventReceiverWidgetI
{
    WidgetI getParent();

    typeof(this) setParent(WidgetI widget);
    typeof(this) unsetParent();
    bool isUnsetParent();

    FormI getForm();

    DrawingSurfaceI getDrawingSurface();

    void positionAndSizeRequest(Position2D, Size2D);
    void recalculateChildrenPositionsAndSizes();
    void redraw();

    typeof(this) setPosition(Position2D);
    typeof(this) unsetPosition();
    Position2D getPosition();
    bool isUnsetPosition();

    typeof(this) setSize(Size2D);
    typeof(this) unsetSize();
    Size2D getSize();
    bool isUnsetSize();

    WidgetI getWidgetAtVisible(Position2D point);

    WidgetI getNextFocusableWidget();
    WidgetI getPrevFocusableWidget();

    // -------------- Events --------------

    bool on_mouse_event_internal(EventMouse* event);

    bool on_mouse_click_internal(EventMouse* event);
    bool on_mouse_down_internal(EventMouse* event);
    bool on_mouse_up_internal(EventMouse* event);

    bool on_mouse_enter_internal(EventMouse* event);
    bool on_mouse_leave_internal(EventMouse* event);

    bool on_mouse_over_internal(EventMouse* event);

    bool on_keyboard_click_internal(EventKeyboard* event);
    bool on_keyboard_down_internal(EventKeyboard* event);
    bool on_keyboard_up_internal(EventKeyboard* event);

    bool on_keyboard_enter_internal(EventKeyboard* event);
    bool on_keyboard_leave_internal(EventKeyboard* event);

}
