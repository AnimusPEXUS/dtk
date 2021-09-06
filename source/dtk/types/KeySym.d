module dtk.types.KeySym;
// NOTE: this module should be named KeySym, because it's separate entety
//       from Keyboard Signal Processing

import dtk.types.EnumKeyboardKeyState;
import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;

struct KeySym
{
    /* uint scancode; */
    EnumKeyboardKeyCode keycode;
    EnumKeyboardModCode modcode;
}
