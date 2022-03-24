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
	int mouse_x;
	int mouse_y;
	union
	{
		EventWindow *ew;
		EventKeyboard *ek;
		EventMouse *em;
		EventTextInput *eti;
	}
	
	string toString()
	{
		import std.format;
		
		string ret;
		ret ~= "(event:: type: %s, window: %s, ".format(type, window);
		switch (type)
		{
		default:
			ret ~= " todo";
			break;
		case EventType.textInput:
			ret ~= " textInput: %s".format(*eti);
			break;
		}
		ret ~= ")";
		return ret;
	}
}
