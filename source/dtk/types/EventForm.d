module dtk.types.EventForm;

// import dtk.interfaces.WidgetI;

public import dtk.types.Event;

import dtk.types.Widget;

struct EventForm
{
	Event* event;
	Widget focusedWidget;
	Widget mouseFocusedWidget;
	int mouseFocusedWidgetX;
	int mouseFocusedWidgetY;
}
