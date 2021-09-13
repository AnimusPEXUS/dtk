module dtk.platforms.sdl_desktop.sdlkeyconversion;

/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/

import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;
import bindbc.sdl;

class EKeycodeConversionError : Exception
{
}

class EKeymodConversionError : Exception
{
}

EnumKeyboardKeyCode convertSDLKeycodeToEnumKeyboardKeyCode(SDL_Keycode code)
{
    switch (code)
    {
    default:
        throw new EKeycodeConversionError("could not decode supplied keycode");
    case SDL_Keycode.SDLK_ESCAPE:
        return EnumKeyboardKeyCode.Escape;
    case SDL_Keycode.SDLK_F1:
        return EnumKeyboardKeyCode.F1;
    case SDL_Keycode.SDLK_F2:
        return EnumKeyboardKeyCode.F2;
    case SDL_Keycode.SDLK_F3:
        return EnumKeyboardKeyCode.F3;
    case SDL_Keycode.SDLK_F4:
        return EnumKeyboardKeyCode.F4;
    case SDL_Keycode.SDLK_F5:
        return EnumKeyboardKeyCode.F5;
    case SDL_Keycode.SDLK_F6:
        return EnumKeyboardKeyCode.F6;
    case SDL_Keycode.SDLK_F7:
        return EnumKeyboardKeyCode.F7;
    case SDL_Keycode.SDLK_F8:
        return EnumKeyboardKeyCode.F8;
    case SDL_Keycode.SDLK_F9:
        return EnumKeyboardKeyCode.F9;
    case SDL_Keycode.SDLK_F10:
        return EnumKeyboardKeyCode.F10;
    case SDL_Keycode.SDLK_F11:
        return EnumKeyboardKeyCode.F11;
    case SDL_Keycode.SDLK_F12:
        return EnumKeyboardKeyCode.F12;
    case SDL_Keycode.SDLK_F13:
        return EnumKeyboardKeyCode.F13;
    case SDL_Keycode.SDLK_F14:
        return EnumKeyboardKeyCode.F14;
    case SDL_Keycode.SDLK_F15:
        return EnumKeyboardKeyCode.F15;
    case SDL_Keycode.SDLK_F16:
        return EnumKeyboardKeyCode.F16;
    case SDL_Keycode.SDLK_F17:
        return EnumKeyboardKeyCode.F17;
    case SDL_Keycode.SDLK_F18:
        return EnumKeyboardKeyCode.F18;
    case SDL_Keycode.SDLK_F19:
        return EnumKeyboardKeyCode.F19;
    case SDL_Keycode.SDLK_F20:
        return EnumKeyboardKeyCode.F20;
    case SDL_Keycode.SDLK_F21:
        return EnumKeyboardKeyCode.F21;
    case SDL_Keycode.SDLK_F22:
        return EnumKeyboardKeyCode.F22;
    case SDL_Keycode.SDLK_F23:
        return EnumKeyboardKeyCode.F23;
    case SDL_Keycode.SDLK_F24:
        return EnumKeyboardKeyCode.F24;
    case SDL_Keycode.SDLK_a:
        return EnumKeyboardKeyCode.A;
    case SDL_Keycode.SDLK_b:
        return EnumKeyboardKeyCode.B;
    case SDL_Keycode.SDLK_c:
        return EnumKeyboardKeyCode.C;
    case SDL_Keycode.SDLK_d:
        return EnumKeyboardKeyCode.D;
    case SDL_Keycode.SDLK_e:
        return EnumKeyboardKeyCode.E;
    case SDL_Keycode.SDLK_f:
        return EnumKeyboardKeyCode.F;
    case SDL_Keycode.SDLK_g:
        return EnumKeyboardKeyCode.G;
    case SDL_Keycode.SDLK_h:
        return EnumKeyboardKeyCode.H;
    case SDL_Keycode.SDLK_i:
        return EnumKeyboardKeyCode.I;
    case SDL_Keycode.SDLK_j:
        return EnumKeyboardKeyCode.J;
    case SDL_Keycode.SDLK_k:
        return EnumKeyboardKeyCode.K;
    case SDL_Keycode.SDLK_l:
        return EnumKeyboardKeyCode.L;
    case SDL_Keycode.SDLK_m:
        return EnumKeyboardKeyCode.M;
    case SDL_Keycode.SDLK_n:
        return EnumKeyboardKeyCode.N;
    case SDL_Keycode.SDLK_o:
        return EnumKeyboardKeyCode.O;
    case SDL_Keycode.SDLK_p:
        return EnumKeyboardKeyCode.P;
    case SDL_Keycode.SDLK_q:
        return EnumKeyboardKeyCode.Q;
    case SDL_Keycode.SDLK_r:
        return EnumKeyboardKeyCode.R;
    case SDL_Keycode.SDLK_s:
        return EnumKeyboardKeyCode.S;
    case SDL_Keycode.SDLK_t:
        return EnumKeyboardKeyCode.T;
    case SDL_Keycode.SDLK_u:
        return EnumKeyboardKeyCode.U;
    case SDL_Keycode.SDLK_v:
        return EnumKeyboardKeyCode.V;
    case SDL_Keycode.SDLK_w:
        return EnumKeyboardKeyCode.W;
    case SDL_Keycode.SDLK_x:
        return EnumKeyboardKeyCode.X;
    case SDL_Keycode.SDLK_y:
        return EnumKeyboardKeyCode.Y;
    case SDL_Keycode.SDLK_z:
        return EnumKeyboardKeyCode.Z;
    case SDL_Keycode.SDLK_SPACE:
        return EnumKeyboardKeyCode.Space;
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
    case SDL_Keycode.SDLK_BACKQUOTE:
        return EnumKeyboardKeyCode.BackSingleQuote;
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
    case SDL_Keycode.SDLK_CAPSLOCK:
        return EnumKeyboardKeyCode.CapsLock;
    case SDL_Keycode.SDLK_NUMLOCKCLEAR:
        return EnumKeyboardKeyCode.NumLock;
    case SDL_Keycode.SDLK_SCROLLLOCK:
        return EnumKeyboardKeyCode.ScrollLock;
    case SDL_Keycode.SDLK_BACKSPACE:
        return EnumKeyboardKeyCode.BackSpace;
    case SDL_Keycode.SDLK_RETURN:
        return EnumKeyboardKeyCode.Return;
    case SDL_Keycode.SDLK_RETURN2:
        return EnumKeyboardKeyCode.Return2;
    case SDL_Keycode.SDLK_LEFTBRACKET:
        return EnumKeyboardKeyCode.SquareLeftBracket;
    case SDL_Keycode.SDLK_RIGHTBRACKET:
        return EnumKeyboardKeyCode.SquareRightBracket;
    case SDL_Keycode.SDLK_SEMICOLON:
        return EnumKeyboardKeyCode.Semicolon;
    case SDL_Keycode.SDLK_QUOTE:
        return EnumKeyboardKeyCode.SingleQuote;
    case SDL_Keycode.SDLK_BACKSLASH:
        return EnumKeyboardKeyCode.BackSlash;
    case SDL_Keycode.SDLK_COMMA:
        return EnumKeyboardKeyCode.Comma;
    case SDL_Keycode.SDLK_PERIOD:
        return EnumKeyboardKeyCode.Period;
    case SDL_Keycode.SDLK_SLASH:
        return EnumKeyboardKeyCode.Slash;
    case SDL_Keycode.SDLK_INSERT:
        return EnumKeyboardKeyCode.Insert;
    case SDL_Keycode.SDLK_DELETE:
        return EnumKeyboardKeyCode.Delete;
    case SDL_Keycode.SDLK_HOME:
        return EnumKeyboardKeyCode.Home;
    case SDL_Keycode.SDLK_END:
        return EnumKeyboardKeyCode.End;
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
    case SDL_Keycode.SDLK_DOWN:
        return EnumKeyboardKeyCode.Down;
    case SDL_Keycode.SDLK_LEFT:
        return EnumKeyboardKeyCode.Left;
    case SDL_Keycode.SDLK_RIGHT:
        return EnumKeyboardKeyCode.Right;
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
        throw new EKeycodeConversionError("could not decode supplied keycode");
    case EnumKeyboardKeyCode.Escape:
        return SDL_Keycode.SDLK_ESCAPE;
    case EnumKeyboardKeyCode.F1:
        return SDL_Keycode.SDLK_F1;
    case EnumKeyboardKeyCode.F2:
        return SDL_Keycode.SDLK_F2;
    case EnumKeyboardKeyCode.F3:
        return SDL_Keycode.SDLK_F3;
    case EnumKeyboardKeyCode.F4:
        return SDL_Keycode.SDLK_F4;
    case EnumKeyboardKeyCode.F5:
        return SDL_Keycode.SDLK_F5;
    case EnumKeyboardKeyCode.F6:
        return SDL_Keycode.SDLK_F6;
    case EnumKeyboardKeyCode.F7:
        return SDL_Keycode.SDLK_F7;
    case EnumKeyboardKeyCode.F8:
        return SDL_Keycode.SDLK_F8;
    case EnumKeyboardKeyCode.F9:
        return SDL_Keycode.SDLK_F9;
    case EnumKeyboardKeyCode.F10:
        return SDL_Keycode.SDLK_F10;
    case EnumKeyboardKeyCode.F11:
        return SDL_Keycode.SDLK_F11;
    case EnumKeyboardKeyCode.F12:
        return SDL_Keycode.SDLK_F12;
    case EnumKeyboardKeyCode.F13:
        return SDL_Keycode.SDLK_F13;
    case EnumKeyboardKeyCode.F14:
        return SDL_Keycode.SDLK_F14;
    case EnumKeyboardKeyCode.F15:
        return SDL_Keycode.SDLK_F15;
    case EnumKeyboardKeyCode.F16:
        return SDL_Keycode.SDLK_F16;
    case EnumKeyboardKeyCode.F17:
        return SDL_Keycode.SDLK_F17;
    case EnumKeyboardKeyCode.F18:
        return SDL_Keycode.SDLK_F18;
    case EnumKeyboardKeyCode.F19:
        return SDL_Keycode.SDLK_F19;
    case EnumKeyboardKeyCode.F20:
        return SDL_Keycode.SDLK_F20;
    case EnumKeyboardKeyCode.F21:
        return SDL_Keycode.SDLK_F21;
    case EnumKeyboardKeyCode.F22:
        return SDL_Keycode.SDLK_F22;
    case EnumKeyboardKeyCode.F23:
        return SDL_Keycode.SDLK_F23;
    case EnumKeyboardKeyCode.F24:
        return SDL_Keycode.SDLK_F24;
    case EnumKeyboardKeyCode.A:
        return SDL_Keycode.SDLK_a;
    case EnumKeyboardKeyCode.B:
        return SDL_Keycode.SDLK_b;
    case EnumKeyboardKeyCode.C:
        return SDL_Keycode.SDLK_c;
    case EnumKeyboardKeyCode.D:
        return SDL_Keycode.SDLK_d;
    case EnumKeyboardKeyCode.E:
        return SDL_Keycode.SDLK_e;
    case EnumKeyboardKeyCode.F:
        return SDL_Keycode.SDLK_f;
    case EnumKeyboardKeyCode.G:
        return SDL_Keycode.SDLK_g;
    case EnumKeyboardKeyCode.H:
        return SDL_Keycode.SDLK_h;
    case EnumKeyboardKeyCode.I:
        return SDL_Keycode.SDLK_i;
    case EnumKeyboardKeyCode.J:
        return SDL_Keycode.SDLK_j;
    case EnumKeyboardKeyCode.K:
        return SDL_Keycode.SDLK_k;
    case EnumKeyboardKeyCode.L:
        return SDL_Keycode.SDLK_l;
    case EnumKeyboardKeyCode.M:
        return SDL_Keycode.SDLK_m;
    case EnumKeyboardKeyCode.N:
        return SDL_Keycode.SDLK_n;
    case EnumKeyboardKeyCode.O:
        return SDL_Keycode.SDLK_o;
    case EnumKeyboardKeyCode.P:
        return SDL_Keycode.SDLK_p;
    case EnumKeyboardKeyCode.Q:
        return SDL_Keycode.SDLK_q;
    case EnumKeyboardKeyCode.R:
        return SDL_Keycode.SDLK_r;
    case EnumKeyboardKeyCode.S:
        return SDL_Keycode.SDLK_s;
    case EnumKeyboardKeyCode.T:
        return SDL_Keycode.SDLK_t;
    case EnumKeyboardKeyCode.U:
        return SDL_Keycode.SDLK_u;
    case EnumKeyboardKeyCode.V:
        return SDL_Keycode.SDLK_v;
    case EnumKeyboardKeyCode.W:
        return SDL_Keycode.SDLK_w;
    case EnumKeyboardKeyCode.X:
        return SDL_Keycode.SDLK_x;
    case EnumKeyboardKeyCode.Y:
        return SDL_Keycode.SDLK_y;
    case EnumKeyboardKeyCode.Z:
        return SDL_Keycode.SDLK_z;
    case EnumKeyboardKeyCode.Space:
        return SDL_Keycode.SDLK_SPACE;
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
    case EnumKeyboardKeyCode.BackSingleQuote:
        return SDL_Keycode.SDLK_BACKQUOTE;
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
    case EnumKeyboardKeyCode.CapsLock:
        return SDL_Keycode.SDLK_CAPSLOCK;
    case EnumKeyboardKeyCode.NumLock:
        return SDL_Keycode.SDLK_NUMLOCKCLEAR;
    case EnumKeyboardKeyCode.ScrollLock:
        return SDL_Keycode.SDLK_SCROLLLOCK;
    case EnumKeyboardKeyCode.BackSpace:
        return SDL_Keycode.SDLK_BACKSPACE;
    case EnumKeyboardKeyCode.Return:
        return SDL_Keycode.SDLK_RETURN;
    case EnumKeyboardKeyCode.Return2:
        return SDL_Keycode.SDLK_RETURN2;
    case EnumKeyboardKeyCode.SquareLeftBracket:
        return SDL_Keycode.SDLK_LEFTBRACKET;
    case EnumKeyboardKeyCode.SquareRightBracket:
        return SDL_Keycode.SDLK_RIGHTBRACKET;
    case EnumKeyboardKeyCode.Semicolon:
        return SDL_Keycode.SDLK_SEMICOLON;
    case EnumKeyboardKeyCode.SingleQuote:
        return SDL_Keycode.SDLK_QUOTE;
    case EnumKeyboardKeyCode.BackSlash:
        return SDL_Keycode.SDLK_BACKSLASH;
    case EnumKeyboardKeyCode.Comma:
        return SDL_Keycode.SDLK_COMMA;
    case EnumKeyboardKeyCode.Period:
        return SDL_Keycode.SDLK_PERIOD;
    case EnumKeyboardKeyCode.Slash:
        return SDL_Keycode.SDLK_SLASH;
    case EnumKeyboardKeyCode.Insert:
        return SDL_Keycode.SDLK_INSERT;
    case EnumKeyboardKeyCode.Delete:
        return SDL_Keycode.SDLK_DELETE;
    case EnumKeyboardKeyCode.Home:
        return SDL_Keycode.SDLK_HOME;
    case EnumKeyboardKeyCode.End:
        return SDL_Keycode.SDLK_END;
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
    case EnumKeyboardKeyCode.Down:
        return SDL_Keycode.SDLK_DOWN;
    case EnumKeyboardKeyCode.Left:
        return SDL_Keycode.SDLK_LEFT;
    case EnumKeyboardKeyCode.Right:
        return SDL_Keycode.SDLK_RIGHT;
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

EnumKeyboardModCode convertSingleSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)
{
    switch (code)
    {
    default:
        throw new EKeymodConversionError("could not decode supplied keymod");
    case SDL_Keymod.KMOD_LSHIFT:
        return EnumKeyboardModCode.LeftShift;
    case SDL_Keymod.KMOD_LCTRL:
        return EnumKeyboardModCode.LeftControl;
    case SDL_Keymod.KMOD_LGUI:
        return EnumKeyboardModCode.LeftSuper;
    case SDL_Keymod.KMOD_LALT:
        return EnumKeyboardModCode.LeftAlt;
    case SDL_Keymod.KMOD_RSHIFT:
        return EnumKeyboardModCode.RightShift;
    case SDL_Keymod.KMOD_RCTRL:
        return EnumKeyboardModCode.RightControl;
    case SDL_Keymod.KMOD_RGUI:
        return EnumKeyboardModCode.RightSuper;
    case SDL_Keymod.KMOD_RALT:
        return EnumKeyboardModCode.RightAlt;
    case SDL_Keymod.KMOD_CAPS:
        return EnumKeyboardModCode.CapsLock;
    case SDL_Keymod.KMOD_NUM:
        return EnumKeyboardModCode.NumLock;
    }
}

SDL_Keymod convertSingleEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)
{
    switch (code)
    {
    default:
        throw new EKeymodConversionError("could not decode supplied keymod");
    case EnumKeyboardModCode.LeftShift:
        return SDL_Keymod.KMOD_LSHIFT;
    case EnumKeyboardModCode.LeftControl:
        return SDL_Keymod.KMOD_LCTRL;
    case EnumKeyboardModCode.LeftAlt:
        return SDL_Keymod.KMOD_LALT;
    case EnumKeyboardModCode.RightShift:
        return SDL_Keymod.KMOD_RSHIFT;
    case EnumKeyboardModCode.RightControl:
        return SDL_Keymod.KMOD_RCTRL;
    case EnumKeyboardModCode.RightAlt:
        return SDL_Keymod.KMOD_RALT;
    case EnumKeyboardModCode.CapsLock:
        return SDL_Keymod.KMOD_CAPS;
    case EnumKeyboardModCode.NumLock:
        return SDL_Keymod.KMOD_NUM;
    }
}

EnumKeyboardModCode convertCombinationSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)
{
    EnumKeyboardModCode ret;
    if ((code & SDL_Keymod.KMOD_LSHIFT) != 0)
    {
        ret |= EnumKeyboardModCode.LeftShift;
    }
    if ((code & SDL_Keymod.KMOD_LCTRL) != 0)
    {
        ret |= EnumKeyboardModCode.LeftControl;
    }
    if ((code & SDL_Keymod.KMOD_LGUI) != 0)
    {
        ret |= EnumKeyboardModCode.LeftSuper;
    }
    if ((code & SDL_Keymod.KMOD_LALT) != 0)
    {
        ret |= EnumKeyboardModCode.LeftAlt;
    }
    if ((code & SDL_Keymod.KMOD_RSHIFT) != 0)
    {
        ret |= EnumKeyboardModCode.RightShift;
    }
    if ((code & SDL_Keymod.KMOD_RCTRL) != 0)
    {
        ret |= EnumKeyboardModCode.RightControl;
    }
    if ((code & SDL_Keymod.KMOD_RGUI) != 0)
    {
        ret |= EnumKeyboardModCode.RightSuper;
    }
    if ((code & SDL_Keymod.KMOD_RALT) != 0)
    {
        ret |= EnumKeyboardModCode.RightAlt;
    }
    if ((code & SDL_Keymod.KMOD_CAPS) != 0)
    {
        ret |= EnumKeyboardModCode.CapsLock;
    }
    if ((code & SDL_Keymod.KMOD_NUM) != 0)
    {
        ret |= EnumKeyboardModCode.NumLock;
    }
    return ret;
}

SDL_Keymod convertCombinationEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)
{
    SDL_Keymod ret;
    if ((code & EnumKeyboardModCode.LeftShift) != 0)
    {
        ret |= SDL_Keymod.KMOD_LSHIFT;
    }
    if ((code & EnumKeyboardModCode.LeftControl) != 0)
    {
        ret |= SDL_Keymod.KMOD_LCTRL;
    }
    if ((code & EnumKeyboardModCode.LeftAlt) != 0)
    {
        ret |= SDL_Keymod.KMOD_LALT;
    }
    if ((code & EnumKeyboardModCode.RightShift) != 0)
    {
        ret |= SDL_Keymod.KMOD_RSHIFT;
    }
    if ((code & EnumKeyboardModCode.RightControl) != 0)
    {
        ret |= SDL_Keymod.KMOD_RCTRL;
    }
    if ((code & EnumKeyboardModCode.RightAlt) != 0)
    {
        ret |= SDL_Keymod.KMOD_RALT;
    }
    if ((code & EnumKeyboardModCode.CapsLock) != 0)
    {
        ret |= SDL_Keymod.KMOD_CAPS;
    }
    if ((code & EnumKeyboardModCode.NumLock) != 0)
    {
        ret |= SDL_Keymod.KMOD_NUM;
    }
    return ret;
}
