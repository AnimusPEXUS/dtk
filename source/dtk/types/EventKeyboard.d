module dtk.types.EventKeyboard;

public import dtk.types.EnumKeyboardKeyState;
public import dtk.types.KeySym;

struct EventKeyboard
{
    EnumKeyboardKeyState key_state;
    bool repeat;
    KeySym keysym;
}
