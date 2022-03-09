module dtk.types.EventForm;

// TODO: rename to EventForm?

import dtk.types.Event;

import dtk.interfaces.WidgetI;

struct EventForm
{
	Event* event;
	WidgetI focusedWidget;
	WidgetI mouseFocusedWidget;
	ulong mouseFocusedWidget_x;
	ulong mouseFocusedWidget_y;
}
