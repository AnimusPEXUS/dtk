module dtk.interfaces.WindowEventMgrI;

import dtk.interfaces.event_receivers;
import dtk.interfaces.WindowI;

import dtk.types.EventXAction;

interface WindowEventMgrI : EventReceiverWindowI
{

    WindowI getWindow();

    void removeAllActions();

    static foreach(v;["Window", "Keyboard", "Mouse", "TextInput"])
    {
        mixin("void add"~v~"Action(Event"~v~"Action eva);");
    }
}
