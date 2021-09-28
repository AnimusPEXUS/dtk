module dtk.interfaces.event_receivers;

import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.EventWindow;

interface EventReceiverWidgetI
{
    bool handle_event_keyboard(EventKeyboard* e);
    bool handle_event_mouse(EventMouse* e);
    bool handle_event_textinput(EventTextInput* e);
}

interface EventReceiverWindowI : EventReceiverWidgetI
{
    bool handle_event_window(EventWindow* e);
}
