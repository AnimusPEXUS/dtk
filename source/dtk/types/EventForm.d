module dtk.types.EventForm;

import dtk.interfaces.WidgetI;

public import dtk.types.Event;

struct EventForm
{
	Event* event;
	WidgetI focusedWidget;
	WidgetI mouseFocusedWidget;
	ulong mouseFocusedWidget_x;
	ulong mouseFocusedWidget_y;
}
