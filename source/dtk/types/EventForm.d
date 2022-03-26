module dtk.types.EventForm;

import dtk.interfaces.WidgetI;

public import dtk.types.Event;

struct EventForm
{
	Event* event;
	WidgetI focusedWidget;
	WidgetI mouseFocusedWidget;
	int mouseFocusedWidget_x;
	int mouseFocusedWidget_y;
}
