module dtk.miscs.WindowEventMgr;

import std.stdio;

import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;
import dtk.interfaces.WindowEventMgrI;

import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.EventWindow;



mixin template mixin_EventXAction(string subject)
{
    mixin("
struct Event"~subject~"Action
{
    bool any_focusedWidget;
    bool any_mouseWidget;

    WidgetI focusedWidget;
    WidgetI mouseWidget;

    bool delegate(WindowEventMgrI mgr, Event"~subject~"* e, WidgetI focusedWidget, WidgetI mouseWidget) isEvent;
    bool delegate(WindowEventMgrI mgr, Event"~subject~"* e, WidgetI focusedWidget, WidgetI mouseWidget) action;
}"
);
}

static foreach(v;["Window", "Keyboard", "Mouse", "TextInput"])
{
    mixin mixin_EventXAction!v;
}


class WindowEventMgr: WindowEventMgrI
{

    private
    {
        WindowI window;
    }

    this(WindowI window)
    {
        this.window=window;
    }

    bool handle_event_keyboard(EventKeyboard* e)
    {
        return true;
    }

    bool handle_event_mouse(EventMouse* e)
    {
        writeln("   mouse clicks:", e.button.clicks);

        WidgetI w = getWidgetAtVisible(Position2D(e.x, e.y));
        writeln("widget at [", e.x, ",", e.y, "] ", w);

        while (true)
        {
            auto res = w.handle_event_mouse(e);
            if (res)
            {
                break;
            }
            w = w.getParent();
            if (w is null)
            {
                break;
            }
        }
        return true;
    }

    bool handle_event_textinput(EventTextInput* e)
    {
        return true;
    }

    bool handle_event_window(EventWindow* e)
    {
        bool needs_resize = false;
        bool needs_redraw = false;

        switch (e.eventId)
        {
        default:
            return true; // TODO: is it really should be 'true'?
            /* case EnumWindowEvent.show:
                break; */
        case EnumWindowEvent.show:
        case EnumWindowEvent.resize:
            needs_resize = true;
            needs_redraw = true;
            break;
        }

        if (needs_resize)
        {
            FormI _form = window.getForm() ;
            if (_form !is null)
            {
                _form.positionAndSizeRequest(Position2D(0, 0), Size2D(e.size.width, e.size.height));
            }
            needs_redraw = true;
        }

        if (needs_redraw)
        {
            window.redraw();
        }

        return true;
    }

    WidgetI getWidgetAtVisible(Position2D point)
    {
        WidgetI ret = null;
        FormI _form = window.getForm() ;
        if (_form !is null)
        {
            ret = _form.getWidgetAtVisible(point);
        }
        return ret;
    }

    static foreach(v;["Window", "Keyboard", "Mouse", "TextInput"])
    {
        mixin("private Event"~v~"Action[] list"~v~"Actions;");
        mixin("void add"~v~"Action(Event"~v~"Action eva) { list"~v~"Actions ~= eva; }");
    }

}
