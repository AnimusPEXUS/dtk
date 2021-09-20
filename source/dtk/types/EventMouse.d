module dtk.types.EventMouse;

enum EventMouseType
{
    movement,
    button,
    wheel
}

enum EnumMouseButtonState : ubyte
{
    released,
    pressed
}

enum EnumMouseButton : ushort
{
    none = 0,
    bl  = 0b00000000000000001,
    br  = 0b00000000000000010,
    bm  = 0b00000000000000100,
    b4  = 0b00000000000001000,
    b5  = 0b00000000000010000,
    b6  = 0b00000000000100000,
    b7  = 0b00000000001000000,
    b8  = 0b00000000010000000,
    b9  = 0b00000000100000000,
    b10 = 0b00000001000000000,
    b11 = 0b00000010000000000,
    b12 = 0b00000100000000000
}

struct EventMouseMovement
{
    /// binary mask of pressed buttons
    EnumMouseButton button;

    int xr;
    int yr;
}

struct EventMouseButton
{
    /// changed button
    EnumMouseButton button;
    /// new state for changed button
    EnumMouseButtonState buttonState;

    ubyte clicks;
}

enum EventMouseWheelDirection : ubyte
{
    Up = 0b01,
    Down = 0b10,
    Left = 0b100,
    Right = 0b1000
}

struct EventMouseWheel
{
    EventMouseWheelDirection direction;
}

struct EventMouse
{
    EventMouseType type;
    uint mouseId;
    int x;
    int y;
    union
    {
        EventMouseMovement movement;
        EventMouseButton button;
        EventMouseWheel wheel;
    }
}
