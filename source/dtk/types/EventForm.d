module dtk.types.EventForm;

// import dtk.interfaces.WidgetI;

public import dtk.types.Event;

import dtk.types.Widget;

struct EventRootWidget
{
	Event* event;
	Widget focusedWidget;
	Widget mouseFocusedWidget;
	int mouseFocusedWidget_x;
	int mouseFocusedWidget_y;
}
