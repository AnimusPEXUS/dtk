module dtk.interfaces.WindowEventMgrI;

import dtk.interfaces.event_receivers;

import dtk.types.EventXAction;

interface WindowEventMgrI : EventReceiverWindowI
{
    static foreach(v;["Window", "Keyboard", "Mouse", "TextInput"])
    {
        mixin("void add"~v~"Action(Event"~v~"Action eva);");
    }
}
