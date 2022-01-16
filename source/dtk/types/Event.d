module dtk.types.Event;

import dtk.interfaces.WindowI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

enum EventType : ubyte
{
	none,
	window,
	keyboard,
	mouse,
	textInput,
}

struct Event
{
	EventType eventType;
	WindowI window;
	union
	{
		EventWindow *ew;
		EventKeyboard *ek;
		EventMouse *em;
		EventTextInput *eti;
	}
}
