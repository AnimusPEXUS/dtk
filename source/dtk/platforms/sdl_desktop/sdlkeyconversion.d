module dtk.platforms.sdl_desktop.sdlkeyconversion;

/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/

import dtk.types.EnumKeyboardKeyCode;
import bindbc.sdl;

EnumKeyboardKeyCode convertSDLKeycodeToEnumKeyboardKeyCode(SDL_Keycode code)
{
    switch (code)
    {
    default:
        throw new Exception("could not decode supplied keycode");
    case SDL_Keycode.SDLK_0:
        return EnumKeyboardKeyCode.Zero;
    case SDL_Keycode.SDLK_1:
        return EnumKeyboardKeyCode.One;
    case SDL_Keycode.SDLK_2:
        return EnumKeyboardKeyCode.Two;
    case SDL_Keycode.SDLK_3:
        return EnumKeyboardKeyCode.Three;
    case SDL_Keycode.SDLK_4:
        return EnumKeyboardKeyCode.Four;
    case SDL_Keycode.SDLK_5:
        return EnumKeyboardKeyCode.Five;
    case SDL_Keycode.SDLK_6:
        return EnumKeyboardKeyCode.Six;
    case SDL_Keycode.SDLK_7:
        return EnumKeyboardKeyCode.Seven;
    case SDL_Keycode.SDLK_8:
        return EnumKeyboardKeyCode.Eight;
    case SDL_Keycode.SDLK_9:
        return EnumKeyboardKeyCode.Nine;
    case SDL_Keycode.SDLK_MINUS:
        return EnumKeyboardKeyCode.Minus;
    case SDL_Keycode.SDLK_EQUALS:
        return EnumKeyboardKeyCode.Equals;
    case SDL_Keycode.SDLK_NUMLOCKCLEAR:
        return EnumKeyboardKeyCode.NumLock;
    case SDL_Keycode.SDLK_SCROLLLOCK:
        return EnumKeyboardKeyCode.ScrollLock;
    case SDL_Keycode.SDLK_TAB:
        return EnumKeyboardKeyCode.Tabulation;
    case SDL_Keycode.SDLK_LSHIFT:
        return EnumKeyboardKeyCode.LeftShift;
    case SDL_Keycode.SDLK_LCTRL:
        return EnumKeyboardKeyCode.LeftControl;
    case SDL_Keycode.SDLK_LALT:
        return EnumKeyboardKeyCode.LeftAlt;
    case SDL_Keycode.SDLK_RSHIFT:
        return EnumKeyboardKeyCode.RightShift;
    case SDL_Keycode.SDLK_RCTRL:
        return EnumKeyboardKeyCode.RightControl;
    case SDL_Keycode.SDLK_APPLICATION:
        return EnumKeyboardKeyCode.RightMenu;
    case SDL_Keycode.SDLK_RALT:
        return EnumKeyboardKeyCode.RightAlt;
    case SDL_Keycode.SDLK_BACKSPACE:
        return EnumKeyboardKeyCode.BackSpace;
    case SDL_Keycode.SDLK_RETURN:
        return EnumKeyboardKeyCode.Return;
    case SDL_Keycode.SDLK_RETURN2:
        return EnumKeyboardKeyCode.Return2;
    case SDL_Keycode.SDLK_RIGHTBRACKET:
        return EnumKeyboardKeyCode.SquareRightBracket;
    case SDL_Keycode.SDLK_SEMICOLON:
        return EnumKeyboardKeyCode.Semicolon;
    case SDL_Keycode.SDLK_PERIOD:
        return EnumKeyboardKeyCode.Period;
    case SDL_Keycode.SDLK_SLASH:
        return EnumKeyboardKeyCode.Slash;
    case SDL_Keycode.SDLK_PAGEUP:
        return EnumKeyboardKeyCode.PageUp;
    case SDL_Keycode.SDLK_PAGEDOWN:
        return EnumKeyboardKeyCode.PageDown;
    case SDL_Keycode.SDLK_PRINTSCREEN:
        return EnumKeyboardKeyCode.PrintScreen;
    case SDL_Keycode.SDLK_SYSREQ:
        return EnumKeyboardKeyCode.SysReq;
    case SDL_Keycode.SDLK_PAUSE:
        return EnumKeyboardKeyCode.Pause;
    case SDL_Keycode.SDLK_UP:
        return EnumKeyboardKeyCode.Up;
    case SDL_Keycode.SDLK_KP_0:
        return EnumKeyboardKeyCode.KpZero;
    case SDL_Keycode.SDLK_KP_00:
        return EnumKeyboardKeyCode.KpZeroZero;
    case SDL_Keycode.SDLK_KP_000:
        return EnumKeyboardKeyCode.KpZeroZeroZero;
    case SDL_Keycode.SDLK_KP_1:
        return EnumKeyboardKeyCode.KpOne;
    case SDL_Keycode.SDLK_KP_2:
        return EnumKeyboardKeyCode.KpTwo;
    case SDL_Keycode.SDLK_KP_3:
        return EnumKeyboardKeyCode.KpThree;
    case SDL_Keycode.SDLK_KP_4:
        return EnumKeyboardKeyCode.KpFour;
    case SDL_Keycode.SDLK_KP_5:
        return EnumKeyboardKeyCode.KpFive;
    case SDL_Keycode.SDLK_KP_6:
        return EnumKeyboardKeyCode.KpSix;
    case SDL_Keycode.SDLK_KP_7:
        return EnumKeyboardKeyCode.KpSeven;
    case SDL_Keycode.SDLK_KP_8:
        return EnumKeyboardKeyCode.KpEight;
    case SDL_Keycode.SDLK_KP_9:
        return EnumKeyboardKeyCode.KpNine;
    case SDL_Keycode.SDLK_KP_DIVIDE:
        return EnumKeyboardKeyCode.KpDevide;
    case SDL_Keycode.SDLK_KP_ENTER:
        return EnumKeyboardKeyCode.KpEnter;
    case SDL_Keycode.SDLK_KP_EQUALS:
        return EnumKeyboardKeyCode.KpEquals;
    case SDL_Keycode.SDLK_KP_MINUS:
        return EnumKeyboardKeyCode.KpMinus;
    case SDL_Keycode.SDLK_KP_MULTIPLY:
        return EnumKeyboardKeyCode.KpMultiply;
    case SDL_Keycode.SDLK_KP_PLUS:
        return EnumKeyboardKeyCode.KpPlus;
    }
}

SDL_Keycode convertEnumKeyboardKeyCodeToSDLKeycode(EnumKeyboardKeyCode code)
{
    switch (code)
    {
    default:
        throw new Exception("could not decode supplied keycode");
    case EnumKeyboardKeyCode.Zero:
        return SDL_Keycode.SDLK_0;
    case EnumKeyboardKeyCode.One:
        return SDL_Keycode.SDLK_1;
    case EnumKeyboardKeyCode.Two:
        return SDL_Keycode.SDLK_2;
    case EnumKeyboardKeyCode.Three:
        return SDL_Keycode.SDLK_3;
    case EnumKeyboardKeyCode.Four:
        return SDL_Keycode.SDLK_4;
    case EnumKeyboardKeyCode.Five:
        return SDL_Keycode.SDLK_5;
    case EnumKeyboardKeyCode.Six:
        return SDL_Keycode.SDLK_6;
    case EnumKeyboardKeyCode.Seven:
        return SDL_Keycode.SDLK_7;
    case EnumKeyboardKeyCode.Eight:
        return SDL_Keycode.SDLK_8;
    case EnumKeyboardKeyCode.Nine:
        return SDL_Keycode.SDLK_9;
    case EnumKeyboardKeyCode.Minus:
        return SDL_Keycode.SDLK_MINUS;
    case EnumKeyboardKeyCode.Equals:
        return SDL_Keycode.SDLK_EQUALS;
    case EnumKeyboardKeyCode.NumLock:
        return SDL_Keycode.SDLK_NUMLOCKCLEAR;
    case EnumKeyboardKeyCode.ScrollLock:
        return SDL_Keycode.SDLK_SCROLLLOCK;
    case EnumKeyboardKeyCode.Tabulation:
        return SDL_Keycode.SDLK_TAB;
    case EnumKeyboardKeyCode.LeftShift:
        return SDL_Keycode.SDLK_LSHIFT;
    case EnumKeyboardKeyCode.LeftControl:
        return SDL_Keycode.SDLK_LCTRL;
    case EnumKeyboardKeyCode.LeftAlt:
        return SDL_Keycode.SDLK_LALT;
    case EnumKeyboardKeyCode.RightShift:
        return SDL_Keycode.SDLK_RSHIFT;
    case EnumKeyboardKeyCode.RightControl:
        return SDL_Keycode.SDLK_RCTRL;
    case EnumKeyboardKeyCode.RightMenu:
        return SDL_Keycode.SDLK_APPLICATION;
    case EnumKeyboardKeyCode.RightAlt:
        return SDL_Keycode.SDLK_RALT;
    case EnumKeyboardKeyCode.BackSpace:
        return SDL_Keycode.SDLK_BACKSPACE;
    case EnumKeyboardKeyCode.Return:
        return SDL_Keycode.SDLK_RETURN;
    case EnumKeyboardKeyCode.Return2:
        return SDL_Keycode.SDLK_RETURN2;
    case EnumKeyboardKeyCode.SquareRightBracket:
        return SDL_Keycode.SDLK_RIGHTBRACKET;
    case EnumKeyboardKeyCode.Semicolon:
        return SDL_Keycode.SDLK_SEMICOLON;
    case EnumKeyboardKeyCode.Period:
        return SDL_Keycode.SDLK_PERIOD;
    case EnumKeyboardKeyCode.Slash:
        return SDL_Keycode.SDLK_SLASH;
    case EnumKeyboardKeyCode.PageUp:
        return SDL_Keycode.SDLK_PAGEUP;
    case EnumKeyboardKeyCode.PageDown:
        return SDL_Keycode.SDLK_PAGEDOWN;
    case EnumKeyboardKeyCode.PrintScreen:
        return SDL_Keycode.SDLK_PRINTSCREEN;
    case EnumKeyboardKeyCode.SysReq:
        return SDL_Keycode.SDLK_SYSREQ;
    case EnumKeyboardKeyCode.Pause:
        return SDL_Keycode.SDLK_PAUSE;
    case EnumKeyboardKeyCode.Up:
        return SDL_Keycode.SDLK_UP;
    case EnumKeyboardKeyCode.KpZero:
        return SDL_Keycode.SDLK_KP_0;
    case EnumKeyboardKeyCode.KpZeroZero:
        return SDL_Keycode.SDLK_KP_00;
    case EnumKeyboardKeyCode.KpZeroZeroZero:
        return SDL_Keycode.SDLK_KP_000;
    case EnumKeyboardKeyCode.KpOne:
        return SDL_Keycode.SDLK_KP_1;
    case EnumKeyboardKeyCode.KpTwo:
        return SDL_Keycode.SDLK_KP_2;
    case EnumKeyboardKeyCode.KpThree:
        return SDL_Keycode.SDLK_KP_3;
    case EnumKeyboardKeyCode.KpFour:
        return SDL_Keycode.SDLK_KP_4;
    case EnumKeyboardKeyCode.KpFive:
        return SDL_Keycode.SDLK_KP_5;
    case EnumKeyboardKeyCode.KpSix:
        return SDL_Keycode.SDLK_KP_6;
    case EnumKeyboardKeyCode.KpSeven:
        return SDL_Keycode.SDLK_KP_7;
    case EnumKeyboardKeyCode.KpEight:
        return SDL_Keycode.SDLK_KP_8;
    case EnumKeyboardKeyCode.KpNine:
        return SDL_Keycode.SDLK_KP_9;
    case EnumKeyboardKeyCode.KpDevide:
        return SDL_Keycode.SDLK_KP_DIVIDE;
    case EnumKeyboardKeyCode.KpEnter:
        return SDL_Keycode.SDLK_KP_ENTER;
    case EnumKeyboardKeyCode.KpEquals:
        return SDL_Keycode.SDLK_KP_EQUALS;
    case EnumKeyboardKeyCode.KpMinus:
        return SDL_Keycode.SDLK_KP_MINUS;
    case EnumKeyboardKeyCode.KpMultiply:
        return SDL_Keycode.SDLK_KP_MULTIPLY;
    case EnumKeyboardKeyCode.KpPlus:
        return SDL_Keycode.SDLK_KP_PLUS;
    }
}
