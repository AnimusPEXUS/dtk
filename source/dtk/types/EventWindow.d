module dtk.types.EventWindow;

enum EventWindowID
{
    None,
    Shown,
    Hidden,
    Exposed,
    Moved,
    Resized,
    SizeChanged,
    Minimized,
    Maximized,
    Restored,
    Enter,
    Leave,
    FocusGained,
    FocusLost,
    Close, /* TAKE_FOCUS, */
    /* HIT_TEST, */



}

struct EventWindow
{
    EventWindowID eventId;
    int data1;
    int data2;
}
