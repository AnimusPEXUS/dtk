module dtk.types.FormEvent;

import dtk.types.Event;

import dtk.interfaces.WidgetI;

struct FormEvent
{
	Event* event;
	WidgetI focusedWidget;
	WidgetI mouseFocusedWidget;
	ulong mouseFocusedWidget_x;
	ulong mouseFocusedWidget_y;
}
