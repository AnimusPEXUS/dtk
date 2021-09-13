module dtk.types.KeySym;
// NOTE: this module should be named KeySym, because it's separate entety
//       from Keyboard Signal Processing

public import dtk.types.EnumKeyboardKeyState;
public import dtk.types.EnumKeyboardKeyCode;
public import dtk.types.EnumKeyboardModCode;

struct KeySym
{
    /* uint scancode; */
    EnumKeyboardKeyCode keycode;
    EnumKeyboardModCode modcode;
}
