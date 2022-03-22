module dtk.types.EventKeyboard;

public import dtk.types.EnumKeyboardKeyState;
public import dtk.types.KeySym;

struct EventKeyboard
{
    EnumKeyboardKeyState keyState;
    bool repeat;
    KeySym keysym;
}
