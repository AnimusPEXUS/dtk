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

                if (v.checkMatch !is null)
                    if (!v.checkMatch(this, window, event, focusedWidget, mouseWidget))
                        continue;

                if (v.action !is null)
                    processed = v.action(this, window, event, focusedWidget, mouseWidget);

                continue;
            }

        return processed;
    }


    bool handle_event_window(EventWindow* e)
    {
        return handle_event_x_search_and_call!listWindowActions(e);
    }

    bool handle_event_keyboard(EventKeyboard* e)
    {
        return handle_event_x_search_and_call!listKeyboardActions(e);
    }

    bool handle_event_mouse(EventMouse* e)
    {
        writeln("   mouse clicks:", e.button.clicks);
        return handle_event_x_search_and_call!listMouseActions(e);
    }

    bool handle_event_textinput(EventTextInput* e)
    {
        return handle_event_x_search_and_call!listTextInputActions(e);
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