module dtk.miscs.WindowEventMgr;

import std.stdio;

import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;
import dtk.interfaces.WindowEventMgrI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.EventXAction;


union XEvent
{
    EventWindow* ewindow;
    EventKeyboard* ekeyboard;
    EventMouse *emouse;
    EventTextInput* etextinput;
}

enum XEventType : ubyte
{
    none,
    window,
    keyboard,
    mouse,
    textInput
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

    WindowI getWindow()
    {
        return window;
    }


    private bool handle_event_x_search_and_call
        (
            alias listXActions,
            T1,
            )
        (T1 event)
        {
            WidgetI focusedWidget;
            WidgetI mouseWidget;

            auto form = window.getForm();
            if (form !is null)
            {
                focusedWidget = form.getFocusedWidget();
            }

            // TODO: if mouse info isn't available - get is using platform

            static if (is (T1 == EventMouse*)) {
                mouseWidget=getWidgetAtVisible(Position2D(event.x, event.y));
            }

            /* if (type == XEventType.mouse)
            {
                mouseWidget=getWidgetAtVisible(Position2D(event.emouse.x, event.emouse.y));
            } */

            bool processed;

            foreach (ref v; listXActions)
            {
                if (!v.any_focusedWidget && focusedWidget != v.focusedWidget)
                    continue;

                if (!v.any_mouseWidget && mouseWidget != v.mouseWidget)
                    continue;

                if (!v.checkMatch(this, window, event, focusedWidget, mouseWidget))
                    continue;

                v.action(this, window, event, focusedWidget, mouseWidget);
                processed = true;
                continue;
            }

        return processed;
    }

    /* bool handle_event_x(XEvent event, XEventType type)
    {
        WidgetI focusedWidget;
        WidgetI mouseWidget;

        auto form = window.getForm();
        if (form !is null)
        {
            focusedWidget = form.getFocusedWidget();
        }

        // TODO: if mouse info isn't available - get is using platform

        if (type == XEventType.mouse)
        {
            mouseWidget=getWidgetAtVisible(Position2D(event.emouse.x, event.emouse.y));
        }

        switch (type)
        {
            default:
            case XEventType.none:
                return false;
            case XEventType.window:
                foreach (ref v; listWindowActions)
                {
                    if (!v.any_focusedWidget && focusedWidget != v.focusedWidget)
                        continue;

                    if (!v.any_mouseWidget && mouseWidget != v.mouseWidget)
                        continue;

                    if (!v.checkMatch(this, window, event.ewindow, focusedWidget, mouseWidget))
                        continue;

                    v.action(this, window, event.ewindow, focusedWidget, mouseWidget);
                    continue;
                }
                break;
            case XEventType.keyboard:
                foreach (ref v; listKeyboardActions)
                {
                    if (!v.any_focusedWidget && focusedWidget != v.focusedWidget)
                        continue;

                    if (!v.any_mouseWidget && mouseWidget != v.mouseWidget)
                        continue;

                    if (!v.checkMatch(this, window, event.ekeyboard, focusedWidget, mouseWidget))
                        continue;

                    v.action(this, window, event.ekeyboard, focusedWidget, mouseWidget);
                    continue;
                }
                break;
            case XEventType.mouse:
                foreach (ref v; listMouseActions)
                {
                    if (!v.any_focusedWidget && focusedWidget != v.focusedWidget)
                        continue;

                    if (!v.any_mouseWidget && mouseWidget != v.mouseWidget)
                        continue;

                    if (!v.checkMatch(this, window, event.emouse, focusedWidget, mouseWidget))
                        continue;

                    v.action(this, window, event.emouse, focusedWidget, mouseWidget);
                    continue;
                }
                break;
            case XEventType.textInput:
                foreach (ref v; listTextInputActions)
                {
                    if (!v.any_focusedWidget && focusedWidget != v.focusedWidget)
                        continue;

                    if (!v.any_mouseWidget && mouseWidget != v.mouseWidget)
                        continue;

                    if (!v.checkMatch(this, window, event.etextinput, focusedWidget, mouseWidget))
                        continue;

                    v.action(this, window, event.etextinput, focusedWidget, mouseWidget);
                    continue;
                }
                break;
        }

        return true;
    } */

    bool handle_event_window(EventWindow* e)
    {
        return handle_event_x_search_and_call!listWindowActions(e);
        /* XEvent ev;
        ev.ewindow = e;
        return handle_event_x(ev, XEventType.window); */
    }

    bool handle_event_keyboard(EventKeyboard* e)
    {
        return handle_event_x_search_and_call!listKeyboardActions(e);
        /* XEvent ev;
        ev.ekeyboard = e;
        return handle_event_x(ev, XEventType.keyboard); */
    }

    bool handle_event_mouse(EventMouse* e)
    {
        writeln("   mouse clicks:", e.button.clicks);
        return handle_event_x_search_and_call!listMouseActions(e);
/*
        XEvent ev;
        ev.emouse = e;
        return handle_event_x(ev, XEventType.mouse); */
    }

    bool handle_event_textinput(EventTextInput* e)
    {
        return handle_event_x_search_and_call!listTextInputActions(e);
        /* XEvent ev;
        ev.etextinput = e;
        return handle_event_x(ev, XEventType.textInput); */
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

    void removeAllActions()
    {
        static foreach(v;["Window", "Keyboard", "Mouse", "TextInput"])
        {
            mixin("list"~v~"Actions = []; ");
        }
    }

}
