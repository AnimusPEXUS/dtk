module dtk.types.EventWindow;

public import dtk.types.EnumWindowEvent;
import dtk.types.Position2D;
import dtk.types.Size2D;

struct EventWindow
{
    EnumWindowEvent eventId;
    union {
        Position2D position;
        Size2D size;
    };
}
