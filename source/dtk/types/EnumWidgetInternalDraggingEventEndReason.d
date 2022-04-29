module dtk.types.EnumWidgetInternalDraggingEventEndReason;


enum EnumWidgetInternalDraggingEventEndReason : ubyte
{
	// in case of error
	abort,
	// for widgetInternalDraggingEventStart() callback result to continue dragging
	notEnd,
	// dragging is canceled
	cancel,
	// dragging success
	success,
}