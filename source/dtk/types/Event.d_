module dtk.types.Event;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

enum EventSubject : ubyte
{
	none,
	window,
	keyboard,
	mouse,
	textInput,
}

struct Event
{
	EventSubject event_subject;
	union
	{
		EventWindow *ew;
		EventKeyboard *ek;
		EventMouse *em;
		EventTextInput *eti;
	}
}