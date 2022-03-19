module dtk.types.Event;

import dtk.interfaces.WindowI;

public import dtk.types.EventWindow;
public import dtk.types.EventKeyboard;
public import dtk.types.EventMouse;
public import dtk.types.EventTextInput;
public import dtk.types.EventForm;

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
	EventType type;
	WindowI window;
	union
	{
		EventWindow *ew;
		EventKeyboard *ek;
		EventMouse *em;
		EventTextInput *eti;
	}
}
