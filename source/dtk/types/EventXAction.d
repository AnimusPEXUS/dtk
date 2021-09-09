module dtk.types.EventXAction;



mixin template mixin_EventXAction(string subject)
{
    mixin("
import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.WidgetI;

import dtk.types.Event"~subject~";

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
