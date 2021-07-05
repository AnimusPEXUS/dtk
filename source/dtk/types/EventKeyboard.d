module dtk.types.EventKeyboard;

import dtk.types.EnumKeyboardKeyState;
import dtk.types.KeySym;

struct EventKeyboard
{
    EnumKeyboardKeyState key_state;
    bool repeat;
    KeySym keysym;
}
