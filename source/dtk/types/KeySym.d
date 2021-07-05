module dtk.types.KeySym;

import dtk.types.EnumKeyboardKeyState;
import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;

struct KeySym
{
    /* uint scancode; */
    EnumKeyboardKeyCode keycode;
    EnumKeyboardModCode modcode;
}
