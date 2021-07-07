module dtk.platforms.sdl_desktop.utils;

import bindbc.sdl;

import dtk.types.EventKeyboard;
import dtk.types.EnumKeyboardKeyState;
import dtk.types.KeySym;

import dtk.platforms.sdl_desktop.sdlkeyconversion;

EventKeyboard convertSDLKeyboardEventToDtkEventKeyboard(SDL_KeyboardEvent e)
{
    EventKeyboard ret;

    final switch (e.state)
    {
    case SDL_PRESSED:
        ret.key_state = EnumKeyboardKeyState.pressed;
        break;
    case SDL_RELEASED:
        ret.key_state = EnumKeyboardKeyState.depressed;
        break;
    }

    ret.repeat = e.repeat != 0;

    auto sk = KeySym();

    sk.keycode = convertSDLKeycodeToEnumKeyboardKeyCode(e.keysym.sym);
    sk.modcode = convertCombinationSDLKeymodToEnumKeyboardModCode(cast(SDL_Keymod) e.keysym.mod);

    ret.keysym = sk;

    return ret;
}
