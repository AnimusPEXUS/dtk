module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;

interface WindowI
{
    PlatformI getPlatform();

    void installForm(FormI form);
    void uninstallForm();

    void setForm(FormI form);
    void unsetForm();

    DrawingSurfaceI getDrawingSurface();

    Point getPoint();
    Tuple!(bool, Point) setPoint(Point point);

    Size getSize();
    Tuple!(bool, Size) setSize(Size size);

    Point getFormPoint();
    Size getFormSize();

    string getTitle();
    void setTitle(string value);

    void handle_event_window(EventWindow* e);
    void handle_event_keyboard(EventKeyboard* e);
    void handle_event_mouse(EventMouse* e);
    void handle_event_textinput(EventTextInput* e);

    /* void setWindowEventCB(void delegate(EventWindow event));
    void unsetWindowEventCB();

    void setKeyboardEventCB(void delegate(EventKeyboard event));
    void unsetKeyboardEventCB();

    void setMouseEventCB(void delegate(EventMouse event));
    void unsetMouseEventCB(); */
}
