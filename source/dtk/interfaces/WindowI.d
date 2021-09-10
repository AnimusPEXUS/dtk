module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.event_receivers;

interface WindowI
{
    PlatformI getPlatform();

    void setEventManager(WindowEventMgrI mgr);
    WindowEventMgrI getEventManager();

    void installForm(FormI form);
    void uninstallForm();

    void setForm(FormI form);
    void unsetForm();
    FormI getForm();

    DrawingSurfaceI getDrawingSurface();

    Position2D getPoint();
    Tuple!(bool, Position2D) setPoint(Position2D point);

    Size2D getSize();
    Tuple!(bool, Size2D) setSize(Size2D size);

    /* Position2D getFormPoint();
    Size2D getFormSize(); */

    string getTitle();
    void setTitle(string value);

    void redraw();

    /* void setWindowEventCB(void delegate(EventWindow event));
    void unsetWindowEventCB();

    void setKeyboardEventCB(void delegate(EventKeyboard event));
    void unsetKeyboardEventCB();

    void setMouseEventCB(void delegate(EventMouse event));
    void unsetMouseEventCB(); */
}
