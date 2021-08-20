module dtk.types.EventMouse;

enum EventMouseType
{
    movement,
    button,
    scroll
}

enum EnumMouseButtonState : byte
{
    depressed,
    pressed
}


enum EnumMouseButton : ushort {
    b1 = 0b_00000000000000001,
    b2 = 0b_00000000000000010,
    b3 = 0b_00000000000000100,
    b4 = 0b_00000000000001000,
    b5 = 0b_00000000000010000,
    b6 = 0b_00000000000100000,
    b7 = 0b_00000000001000000,
    b8 = 0b_00000000010000000,
    b9 = 0b_00000000100000000,
    b10 = 0b00000001000000000,
    b11 = 0b00000010000000000,
    b12 = 0b00000100000000000
}

struct EventMouse
{
    EventMouseType type;
    uint mouseId;
    union {
        EventMouseMovement movement;
    }
}

struct EventMouseMovement
{

}


struct EventMouseButton
{

}

enum EventMouseWheelDirection : ushort
{
    Up = 0b01,
    Down = 0b10,
    Left  = 0b100,
    Right = 0b1000
}

struct EventMouseWheel
{
    EventMouseWheelDirection direction;
}
