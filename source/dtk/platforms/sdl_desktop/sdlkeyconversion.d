module dtk.platforms.sdl_desktop.sdlkeyconversion;

/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/

import std.typecons;
import std.format;

import bindbc.sdl;

import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;



Tuple!(EnumKeyboardKeyCode, Exception) convertSDLKeycodeToEnumKeyboardKeyCode(SDL_Keycode code)
{
    switch (code) {
        default:
            return tuple(cast(EnumKeyboardKeyCode)0, new Exception("could not decode supplied keycode: " ~ format("%s", code)));
        case SDL_Keycode.SDLK_ESCAPE:
            return tuple(EnumKeyboardKeyCode.Escape, cast(Exception)null);
        case SDL_Keycode.SDLK_F1:
            return tuple(EnumKeyboardKeyCode.F1, cast(Exception)null);
        case SDL_Keycode.SDLK_F2:
            return tuple(EnumKeyboardKeyCode.F2, cast(Exception)null);
        case SDL_Keycode.SDLK_F3:
            return tuple(EnumKeyboardKeyCode.F3, cast(Exception)null);
        case SDL_Keycode.SDLK_F4:
            return tuple(EnumKeyboardKeyCode.F4, cast(Exception)null);
        case SDL_Keycode.SDLK_F5:
            return tuple(EnumKeyboardKeyCode.F5, cast(Exception)null);
        case SDL_Keycode.SDLK_F6:
            return tuple(EnumKeyboardKeyCode.F6, cast(Exception)null);
        case SDL_Keycode.SDLK_F7:
            return tuple(EnumKeyboardKeyCode.F7, cast(Exception)null);
        case SDL_Keycode.SDLK_F8:
            return tuple(EnumKeyboardKeyCode.F8, cast(Exception)null);
        case SDL_Keycode.SDLK_F9:
            return tuple(EnumKeyboardKeyCode.F9, cast(Exception)null);
        case SDL_Keycode.SDLK_F10:
            return tuple(EnumKeyboardKeyCode.F10, cast(Exception)null);
        case SDL_Keycode.SDLK_F11:
            return tuple(EnumKeyboardKeyCode.F11, cast(Exception)null);
        case SDL_Keycode.SDLK_F12:
            return tuple(EnumKeyboardKeyCode.F12, cast(Exception)null);
        case SDL_Keycode.SDLK_F13:
            return tuple(EnumKeyboardKeyCode.F13, cast(Exception)null);
        case SDL_Keycode.SDLK_F14:
            return tuple(EnumKeyboardKeyCode.F14, cast(Exception)null);
        case SDL_Keycode.SDLK_F15:
            return tuple(EnumKeyboardKeyCode.F15, cast(Exception)null);
        case SDL_Keycode.SDLK_F16:
            return tuple(EnumKeyboardKeyCode.F16, cast(Exception)null);
        case SDL_Keycode.SDLK_F17:
            return tuple(EnumKeyboardKeyCode.F17, cast(Exception)null);
        case SDL_Keycode.SDLK_F18:
            return tuple(EnumKeyboardKeyCode.F18, cast(Exception)null);
        case SDL_Keycode.SDLK_F19:
            return tuple(EnumKeyboardKeyCode.F19, cast(Exception)null);
        case SDL_Keycode.SDLK_F20:
            return tuple(EnumKeyboardKeyCode.F20, cast(Exception)null);
        case SDL_Keycode.SDLK_F21:
            return tuple(EnumKeyboardKeyCode.F21, cast(Exception)null);
        case SDL_Keycode.SDLK_F22:
            return tuple(EnumKeyboardKeyCode.F22, cast(Exception)null);
        case SDL_Keycode.SDLK_F23:
            return tuple(EnumKeyboardKeyCode.F23, cast(Exception)null);
        case SDL_Keycode.SDLK_F24:
            return tuple(EnumKeyboardKeyCode.F24, cast(Exception)null);
        case SDL_Keycode.SDLK_a:
            return tuple(EnumKeyboardKeyCode.A, cast(Exception)null);
        case SDL_Keycode.SDLK_b:
            return tuple(EnumKeyboardKeyCode.B, cast(Exception)null);
        case SDL_Keycode.SDLK_c:
            return tuple(EnumKeyboardKeyCode.C, cast(Exception)null);
        case SDL_Keycode.SDLK_d:
            return tuple(EnumKeyboardKeyCode.D, cast(Exception)null);
        case SDL_Keycode.SDLK_e:
            return tuple(EnumKeyboardKeyCode.E, cast(Exception)null);
        case SDL_Keycode.SDLK_f:
            return tuple(EnumKeyboardKeyCode.F, cast(Exception)null);
        case SDL_Keycode.SDLK_g:
            return tuple(EnumKeyboardKeyCode.G, cast(Exception)null);
        case SDL_Keycode.SDLK_h:
            return tuple(EnumKeyboardKeyCode.H, cast(Exception)null);
        case SDL_Keycode.SDLK_i:
            return tuple(EnumKeyboardKeyCode.I, cast(Exception)null);
        case SDL_Keycode.SDLK_j:
            return tuple(EnumKeyboardKeyCode.J, cast(Exception)null);
        case SDL_Keycode.SDLK_k:
            return tuple(EnumKeyboardKeyCode.K, cast(Exception)null);
        case SDL_Keycode.SDLK_l:
            return tuple(EnumKeyboardKeyCode.L, cast(Exception)null);
        case SDL_Keycode.SDLK_m:
            return tuple(EnumKeyboardKeyCode.M, cast(Exception)null);
        case SDL_Keycode.SDLK_n:
            return tuple(EnumKeyboardKeyCode.N, cast(Exception)null);
        case SDL_Keycode.SDLK_o:
            return tuple(EnumKeyboardKeyCode.O, cast(Exception)null);
        case SDL_Keycode.SDLK_p:
            return tuple(EnumKeyboardKeyCode.P, cast(Exception)null);
        case SDL_Keycode.SDLK_q:
            return tuple(EnumKeyboardKeyCode.Q, cast(Exception)null);
        case SDL_Keycode.SDLK_r:
            return tuple(EnumKeyboardKeyCode.R, cast(Exception)null);
        case SDL_Keycode.SDLK_s:
            return tuple(EnumKeyboardKeyCode.S, cast(Exception)null);
        case SDL_Keycode.SDLK_t:
            return tuple(EnumKeyboardKeyCode.T, cast(Exception)null);
        case SDL_Keycode.SDLK_u:
            return tuple(EnumKeyboardKeyCode.U, cast(Exception)null);
        case SDL_Keycode.SDLK_v:
            return tuple(EnumKeyboardKeyCode.V, cast(Exception)null);
        case SDL_Keycode.SDLK_w:
            return tuple(EnumKeyboardKeyCode.W, cast(Exception)null);
        case SDL_Keycode.SDLK_x:
            return tuple(EnumKeyboardKeyCode.X, cast(Exception)null);
        case SDL_Keycode.SDLK_y:
            return tuple(EnumKeyboardKeyCode.Y, cast(Exception)null);
        case SDL_Keycode.SDLK_z:
            return tuple(EnumKeyboardKeyCode.Z, cast(Exception)null);
        case SDL_Keycode.SDLK_SPACE:
            return tuple(EnumKeyboardKeyCode.Space, cast(Exception)null);
        case SDL_Keycode.SDLK_0:
            return tuple(EnumKeyboardKeyCode.Zero, cast(Exception)null);
        case SDL_Keycode.SDLK_1:
            return tuple(EnumKeyboardKeyCode.One, cast(Exception)null);
        case SDL_Keycode.SDLK_2:
            return tuple(EnumKeyboardKeyCode.Two, cast(Exception)null);
        case SDL_Keycode.SDLK_3:
            return tuple(EnumKeyboardKeyCode.Three, cast(Exception)null);
        case SDL_Keycode.SDLK_4:
            return tuple(EnumKeyboardKeyCode.Four, cast(Exception)null);
        case SDL_Keycode.SDLK_5:
            return tuple(EnumKeyboardKeyCode.Five, cast(Exception)null);
        case SDL_Keycode.SDLK_6:
            return tuple(EnumKeyboardKeyCode.Six, cast(Exception)null);
        case SDL_Keycode.SDLK_7:
            return tuple(EnumKeyboardKeyCode.Seven, cast(Exception)null);
        case SDL_Keycode.SDLK_8:
            return tuple(EnumKeyboardKeyCode.Eight, cast(Exception)null);
        case SDL_Keycode.SDLK_9:
            return tuple(EnumKeyboardKeyCode.Nine, cast(Exception)null);
        case SDL_Keycode.SDLK_MINUS:
            return tuple(EnumKeyboardKeyCode.Minus, cast(Exception)null);
        case SDL_Keycode.SDLK_EQUALS:
            return tuple(EnumKeyboardKeyCode.Equals, cast(Exception)null);
        case SDL_Keycode.SDLK_BACKQUOTE:
            return tuple(EnumKeyboardKeyCode.BackSingleQuote, cast(Exception)null);
        case SDL_Keycode.SDLK_TAB:
            return tuple(EnumKeyboardKeyCode.Tabulation, cast(Exception)null);
        case SDL_Keycode.SDLK_LSHIFT:
            return tuple(EnumKeyboardKeyCode.LeftShift, cast(Exception)null);
        case SDL_Keycode.SDLK_LCTRL:
            return tuple(EnumKeyboardKeyCode.LeftControl, cast(Exception)null);
        case SDL_Keycode.SDLK_LALT:
            return tuple(EnumKeyboardKeyCode.LeftAlt, cast(Exception)null);
        case SDL_Keycode.SDLK_RSHIFT:
            return tuple(EnumKeyboardKeyCode.RightShift, cast(Exception)null);
        case SDL_Keycode.SDLK_RCTRL:
            return tuple(EnumKeyboardKeyCode.RightControl, cast(Exception)null);
        case SDL_Keycode.SDLK_APPLICATION:
            return tuple(EnumKeyboardKeyCode.RightMenu, cast(Exception)null);
        case SDL_Keycode.SDLK_RALT:
            return tuple(EnumKeyboardKeyCode.RightAlt, cast(Exception)null);
        case SDL_Keycode.SDLK_CAPSLOCK:
            return tuple(EnumKeyboardKeyCode.CapsLock, cast(Exception)null);
        case SDL_Keycode.SDLK_NUMLOCKCLEAR:
            return tuple(EnumKeyboardKeyCode.NumLock, cast(Exception)null);
        case SDL_Keycode.SDLK_SCROLLLOCK:
            return tuple(EnumKeyboardKeyCode.ScrollLock, cast(Exception)null);
        case SDL_Keycode.SDLK_BACKSPACE:
            return tuple(EnumKeyboardKeyCode.BackSpace, cast(Exception)null);
        case SDL_Keycode.SDLK_RETURN:
            return tuple(EnumKeyboardKeyCode.Return, cast(Exception)null);
        case SDL_Keycode.SDLK_RETURN2:
            return tuple(EnumKeyboardKeyCode.Return2, cast(Exception)null);
        case SDL_Keycode.SDLK_LEFTBRACKET:
            return tuple(EnumKeyboardKeyCode.SquareLeftBracket, cast(Exception)null);
        case SDL_Keycode.SDLK_RIGHTBRACKET:
            return tuple(EnumKeyboardKeyCode.SquareRightBracket, cast(Exception)null);
        case SDL_Keycode.SDLK_SEMICOLON:
            return tuple(EnumKeyboardKeyCode.Semicolon, cast(Exception)null);
        case SDL_Keycode.SDLK_QUOTE:
            return tuple(EnumKeyboardKeyCode.SingleQuote, cast(Exception)null);
        case SDL_Keycode.SDLK_BACKSLASH:
            return tuple(EnumKeyboardKeyCode.BackSlash, cast(Exception)null);
        case SDL_Keycode.SDLK_COMMA:
            return tuple(EnumKeyboardKeyCode.Comma, cast(Exception)null);
        case SDL_Keycode.SDLK_PERIOD:
            return tuple(EnumKeyboardKeyCode.Period, cast(Exception)null);
        case SDL_Keycode.SDLK_SLASH:
            return tuple(EnumKeyboardKeyCode.Slash, cast(Exception)null);
        case SDL_Keycode.SDLK_INSERT:
            return tuple(EnumKeyboardKeyCode.Insert, cast(Exception)null);
        case SDL_Keycode.SDLK_DELETE:
            return tuple(EnumKeyboardKeyCode.Delete, cast(Exception)null);
        case SDL_Keycode.SDLK_HOME:
            return tuple(EnumKeyboardKeyCode.Home, cast(Exception)null);
        case SDL_Keycode.SDLK_END:
            return tuple(EnumKeyboardKeyCode.End, cast(Exception)null);
        case SDL_Keycode.SDLK_PAGEUP:
            return tuple(EnumKeyboardKeyCode.PageUp, cast(Exception)null);
        case SDL_Keycode.SDLK_PAGEDOWN:
            return tuple(EnumKeyboardKeyCode.PageDown, cast(Exception)null);
        case SDL_Keycode.SDLK_PRINTSCREEN:
            return tuple(EnumKeyboardKeyCode.PrintScreen, cast(Exception)null);
        case SDL_Keycode.SDLK_SYSREQ:
            return tuple(EnumKeyboardKeyCode.SysReq, cast(Exception)null);
        case SDL_Keycode.SDLK_PAUSE:
            return tuple(EnumKeyboardKeyCode.Pause, cast(Exception)null);
        case SDL_Keycode.SDLK_UP:
            return tuple(EnumKeyboardKeyCode.Up, cast(Exception)null);
        case SDL_Keycode.SDLK_DOWN:
            return tuple(EnumKeyboardKeyCode.Down, cast(Exception)null);
        case SDL_Keycode.SDLK_LEFT:
            return tuple(EnumKeyboardKeyCode.Left, cast(Exception)null);
        case SDL_Keycode.SDLK_RIGHT:
            return tuple(EnumKeyboardKeyCode.Right, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_0:
            return tuple(EnumKeyboardKeyCode.KpZero, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_00:
            return tuple(EnumKeyboardKeyCode.KpZeroZero, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_000:
            return tuple(EnumKeyboardKeyCode.KpZeroZeroZero, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_1:
            return tuple(EnumKeyboardKeyCode.KpOne, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_2:
            return tuple(EnumKeyboardKeyCode.KpTwo, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_3:
            return tuple(EnumKeyboardKeyCode.KpThree, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_4:
            return tuple(EnumKeyboardKeyCode.KpFour, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_5:
            return tuple(EnumKeyboardKeyCode.KpFive, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_6:
            return tuple(EnumKeyboardKeyCode.KpSix, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_7:
            return tuple(EnumKeyboardKeyCode.KpSeven, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_8:
            return tuple(EnumKeyboardKeyCode.KpEight, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_9:
            return tuple(EnumKeyboardKeyCode.KpNine, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_DIVIDE:
            return tuple(EnumKeyboardKeyCode.KpDevide, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_ENTER:
            return tuple(EnumKeyboardKeyCode.KpEnter, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_EQUALS:
            return tuple(EnumKeyboardKeyCode.KpEquals, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_MINUS:
            return tuple(EnumKeyboardKeyCode.KpMinus, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_MULTIPLY:
            return tuple(EnumKeyboardKeyCode.KpMultiply, cast(Exception)null);
        case SDL_Keycode.SDLK_KP_PLUS:
            return tuple(EnumKeyboardKeyCode.KpPlus, cast(Exception)null);
    }
}

Tuple!(SDL_Keycode, Exception) convertEnumKeyboardKeyCodeToSDLKeycode(EnumKeyboardKeyCode code)
{
    switch (code) {
        default:
            return tuple(cast(SDL_Keycode)0, new Exception("could not decode supplied keycode: " ~ format("%s", code)));
        case EnumKeyboardKeyCode.Escape:
            return tuple(SDL_Keycode.SDLK_ESCAPE, cast(Exception) null);
        case EnumKeyboardKeyCode.F1:
            return tuple(SDL_Keycode.SDLK_F1, cast(Exception) null);
        case EnumKeyboardKeyCode.F2:
            return tuple(SDL_Keycode.SDLK_F2, cast(Exception) null);
        case EnumKeyboardKeyCode.F3:
            return tuple(SDL_Keycode.SDLK_F3, cast(Exception) null);
        case EnumKeyboardKeyCode.F4:
            return tuple(SDL_Keycode.SDLK_F4, cast(Exception) null);
        case EnumKeyboardKeyCode.F5:
            return tuple(SDL_Keycode.SDLK_F5, cast(Exception) null);
        case EnumKeyboardKeyCode.F6:
            return tuple(SDL_Keycode.SDLK_F6, cast(Exception) null);
        case EnumKeyboardKeyCode.F7:
            return tuple(SDL_Keycode.SDLK_F7, cast(Exception) null);
        case EnumKeyboardKeyCode.F8:
            return tuple(SDL_Keycode.SDLK_F8, cast(Exception) null);
        case EnumKeyboardKeyCode.F9:
            return tuple(SDL_Keycode.SDLK_F9, cast(Exception) null);
        case EnumKeyboardKeyCode.F10:
            return tuple(SDL_Keycode.SDLK_F10, cast(Exception) null);
        case EnumKeyboardKeyCode.F11:
            return tuple(SDL_Keycode.SDLK_F11, cast(Exception) null);
        case EnumKeyboardKeyCode.F12:
            return tuple(SDL_Keycode.SDLK_F12, cast(Exception) null);
        case EnumKeyboardKeyCode.F13:
            return tuple(SDL_Keycode.SDLK_F13, cast(Exception) null);
        case EnumKeyboardKeyCode.F14:
            return tuple(SDL_Keycode.SDLK_F14, cast(Exception) null);
        case EnumKeyboardKeyCode.F15:
            return tuple(SDL_Keycode.SDLK_F15, cast(Exception) null);
        case EnumKeyboardKeyCode.F16:
            return tuple(SDL_Keycode.SDLK_F16, cast(Exception) null);
        case EnumKeyboardKeyCode.F17:
            return tuple(SDL_Keycode.SDLK_F17, cast(Exception) null);
        case EnumKeyboardKeyCode.F18:
            return tuple(SDL_Keycode.SDLK_F18, cast(Exception) null);
        case EnumKeyboardKeyCode.F19:
            return tuple(SDL_Keycode.SDLK_F19, cast(Exception) null);
        case EnumKeyboardKeyCode.F20:
            return tuple(SDL_Keycode.SDLK_F20, cast(Exception) null);
        case EnumKeyboardKeyCode.F21:
            return tuple(SDL_Keycode.SDLK_F21, cast(Exception) null);
        case EnumKeyboardKeyCode.F22:
            return tuple(SDL_Keycode.SDLK_F22, cast(Exception) null);
        case EnumKeyboardKeyCode.F23:
            return tuple(SDL_Keycode.SDLK_F23, cast(Exception) null);
        case EnumKeyboardKeyCode.F24:
            return tuple(SDL_Keycode.SDLK_F24, cast(Exception) null);
        case EnumKeyboardKeyCode.A:
            return tuple(SDL_Keycode.SDLK_a, cast(Exception) null);
        case EnumKeyboardKeyCode.B:
            return tuple(SDL_Keycode.SDLK_b, cast(Exception) null);
        case EnumKeyboardKeyCode.C:
            return tuple(SDL_Keycode.SDLK_c, cast(Exception) null);
        case EnumKeyboardKeyCode.D:
            return tuple(SDL_Keycode.SDLK_d, cast(Exception) null);
        case EnumKeyboardKeyCode.E:
            return tuple(SDL_Keycode.SDLK_e, cast(Exception) null);
        case EnumKeyboardKeyCode.F:
            return tuple(SDL_Keycode.SDLK_f, cast(Exception) null);
        case EnumKeyboardKeyCode.G:
            return tuple(SDL_Keycode.SDLK_g, cast(Exception) null);
        case EnumKeyboardKeyCode.H:
            return tuple(SDL_Keycode.SDLK_h, cast(Exception) null);
        case EnumKeyboardKeyCode.I:
            return tuple(SDL_Keycode.SDLK_i, cast(Exception) null);
        case EnumKeyboardKeyCode.J:
            return tuple(SDL_Keycode.SDLK_j, cast(Exception) null);
        case EnumKeyboardKeyCode.K:
            return tuple(SDL_Keycode.SDLK_k, cast(Exception) null);
        case EnumKeyboardKeyCode.L:
            return tuple(SDL_Keycode.SDLK_l, cast(Exception) null);
        case EnumKeyboardKeyCode.M:
            return tuple(SDL_Keycode.SDLK_m, cast(Exception) null);
        case EnumKeyboardKeyCode.N:
            return tuple(SDL_Keycode.SDLK_n, cast(Exception) null);
        case EnumKeyboardKeyCode.O:
            return tuple(SDL_Keycode.SDLK_o, cast(Exception) null);
        case EnumKeyboardKeyCode.P:
            return tuple(SDL_Keycode.SDLK_p, cast(Exception) null);
        case EnumKeyboardKeyCode.Q:
            return tuple(SDL_Keycode.SDLK_q, cast(Exception) null);
        case EnumKeyboardKeyCode.R:
            return tuple(SDL_Keycode.SDLK_r, cast(Exception) null);
        case EnumKeyboardKeyCode.S:
            return tuple(SDL_Keycode.SDLK_s, cast(Exception) null);
        case EnumKeyboardKeyCode.T:
            return tuple(SDL_Keycode.SDLK_t, cast(Exception) null);
        case EnumKeyboardKeyCode.U:
            return tuple(SDL_Keycode.SDLK_u, cast(Exception) null);
        case EnumKeyboardKeyCode.V:
            return tuple(SDL_Keycode.SDLK_v, cast(Exception) null);
        case EnumKeyboardKeyCode.W:
            return tuple(SDL_Keycode.SDLK_w, cast(Exception) null);
        case EnumKeyboardKeyCode.X:
            return tuple(SDL_Keycode.SDLK_x, cast(Exception) null);
        case EnumKeyboardKeyCode.Y:
            return tuple(SDL_Keycode.SDLK_y, cast(Exception) null);
        case EnumKeyboardKeyCode.Z:
            return tuple(SDL_Keycode.SDLK_z, cast(Exception) null);
        case EnumKeyboardKeyCode.Space:
            return tuple(SDL_Keycode.SDLK_SPACE, cast(Exception) null);
        case EnumKeyboardKeyCode.Zero:
            return tuple(SDL_Keycode.SDLK_0, cast(Exception) null);
        case EnumKeyboardKeyCode.One:
            return tuple(SDL_Keycode.SDLK_1, cast(Exception) null);
        case EnumKeyboardKeyCode.Two:
            return tuple(SDL_Keycode.SDLK_2, cast(Exception) null);
        case EnumKeyboardKeyCode.Three:
            return tuple(SDL_Keycode.SDLK_3, cast(Exception) null);
        case EnumKeyboardKeyCode.Four:
            return tuple(SDL_Keycode.SDLK_4, cast(Exception) null);
        case EnumKeyboardKeyCode.Five:
            return tuple(SDL_Keycode.SDLK_5, cast(Exception) null);
        case EnumKeyboardKeyCode.Six:
            return tuple(SDL_Keycode.SDLK_6, cast(Exception) null);
        case EnumKeyboardKeyCode.Seven:
            return tuple(SDL_Keycode.SDLK_7, cast(Exception) null);
        case EnumKeyboardKeyCode.Eight:
            return tuple(SDL_Keycode.SDLK_8, cast(Exception) null);
        case EnumKeyboardKeyCode.Nine:
            return tuple(SDL_Keycode.SDLK_9, cast(Exception) null);
        case EnumKeyboardKeyCode.Minus:
            return tuple(SDL_Keycode.SDLK_MINUS, cast(Exception) null);
        case EnumKeyboardKeyCode.Equals:
            return tuple(SDL_Keycode.SDLK_EQUALS, cast(Exception) null);
        case EnumKeyboardKeyCode.BackSingleQuote:
            return tuple(SDL_Keycode.SDLK_BACKQUOTE, cast(Exception) null);
        case EnumKeyboardKeyCode.Tabulation:
            return tuple(SDL_Keycode.SDLK_TAB, cast(Exception) null);
        case EnumKeyboardKeyCode.LeftShift:
            return tuple(SDL_Keycode.SDLK_LSHIFT, cast(Exception) null);
        case EnumKeyboardKeyCode.LeftControl:
            return tuple(SDL_Keycode.SDLK_LCTRL, cast(Exception) null);
        case EnumKeyboardKeyCode.LeftAlt:
            return tuple(SDL_Keycode.SDLK_LALT, cast(Exception) null);
        case EnumKeyboardKeyCode.RightShift:
            return tuple(SDL_Keycode.SDLK_RSHIFT, cast(Exception) null);
        case EnumKeyboardKeyCode.RightControl:
            return tuple(SDL_Keycode.SDLK_RCTRL, cast(Exception) null);
        case EnumKeyboardKeyCode.RightMenu:
            return tuple(SDL_Keycode.SDLK_APPLICATION, cast(Exception) null);
        case EnumKeyboardKeyCode.RightAlt:
            return tuple(SDL_Keycode.SDLK_RALT, cast(Exception) null);
        case EnumKeyboardKeyCode.CapsLock:
            return tuple(SDL_Keycode.SDLK_CAPSLOCK, cast(Exception) null);
        case EnumKeyboardKeyCode.NumLock:
            return tuple(SDL_Keycode.SDLK_NUMLOCKCLEAR, cast(Exception) null);
        case EnumKeyboardKeyCode.ScrollLock:
            return tuple(SDL_Keycode.SDLK_SCROLLLOCK, cast(Exception) null);
        case EnumKeyboardKeyCode.BackSpace:
            return tuple(SDL_Keycode.SDLK_BACKSPACE, cast(Exception) null);
        case EnumKeyboardKeyCode.Return:
            return tuple(SDL_Keycode.SDLK_RETURN, cast(Exception) null);
        case EnumKeyboardKeyCode.Return2:
            return tuple(SDL_Keycode.SDLK_RETURN2, cast(Exception) null);
        case EnumKeyboardKeyCode.SquareLeftBracket:
            return tuple(SDL_Keycode.SDLK_LEFTBRACKET, cast(Exception) null);
        case EnumKeyboardKeyCode.SquareRightBracket:
            return tuple(SDL_Keycode.SDLK_RIGHTBRACKET, cast(Exception) null);
        case EnumKeyboardKeyCode.Semicolon:
            return tuple(SDL_Keycode.SDLK_SEMICOLON, cast(Exception) null);
        case EnumKeyboardKeyCode.SingleQuote:
            return tuple(SDL_Keycode.SDLK_QUOTE, cast(Exception) null);
        case EnumKeyboardKeyCode.BackSlash:
            return tuple(SDL_Keycode.SDLK_BACKSLASH, cast(Exception) null);
        case EnumKeyboardKeyCode.Comma:
            return tuple(SDL_Keycode.SDLK_COMMA, cast(Exception) null);
        case EnumKeyboardKeyCode.Period:
            return tuple(SDL_Keycode.SDLK_PERIOD, cast(Exception) null);
        case EnumKeyboardKeyCode.Slash:
            return tuple(SDL_Keycode.SDLK_SLASH, cast(Exception) null);
        case EnumKeyboardKeyCode.Insert:
            return tuple(SDL_Keycode.SDLK_INSERT, cast(Exception) null);
        case EnumKeyboardKeyCode.Delete:
            return tuple(SDL_Keycode.SDLK_DELETE, cast(Exception) null);
        case EnumKeyboardKeyCode.Home:
            return tuple(SDL_Keycode.SDLK_HOME, cast(Exception) null);
        case EnumKeyboardKeyCode.End:
            return tuple(SDL_Keycode.SDLK_END, cast(Exception) null);
        case EnumKeyboardKeyCode.PageUp:
            return tuple(SDL_Keycode.SDLK_PAGEUP, cast(Exception) null);
        case EnumKeyboardKeyCode.PageDown:
            return tuple(SDL_Keycode.SDLK_PAGEDOWN, cast(Exception) null);
        case EnumKeyboardKeyCode.PrintScreen:
            return tuple(SDL_Keycode.SDLK_PRINTSCREEN, cast(Exception) null);
        case EnumKeyboardKeyCode.SysReq:
            return tuple(SDL_Keycode.SDLK_SYSREQ, cast(Exception) null);
        case EnumKeyboardKeyCode.Pause:
            return tuple(SDL_Keycode.SDLK_PAUSE, cast(Exception) null);
        case EnumKeyboardKeyCode.Up:
            return tuple(SDL_Keycode.SDLK_UP, cast(Exception) null);
        case EnumKeyboardKeyCode.Down:
            return tuple(SDL_Keycode.SDLK_DOWN, cast(Exception) null);
        case EnumKeyboardKeyCode.Left:
            return tuple(SDL_Keycode.SDLK_LEFT, cast(Exception) null);
        case EnumKeyboardKeyCode.Right:
            return tuple(SDL_Keycode.SDLK_RIGHT, cast(Exception) null);
        case EnumKeyboardKeyCode.KpZero:
            return tuple(SDL_Keycode.SDLK_KP_0, cast(Exception) null);
        case EnumKeyboardKeyCode.KpZeroZero:
            return tuple(SDL_Keycode.SDLK_KP_00, cast(Exception) null);
        case EnumKeyboardKeyCode.KpZeroZeroZero:
            return tuple(SDL_Keycode.SDLK_KP_000, cast(Exception) null);
        case EnumKeyboardKeyCode.KpOne:
            return tuple(SDL_Keycode.SDLK_KP_1, cast(Exception) null);
        case EnumKeyboardKeyCode.KpTwo:
            return tuple(SDL_Keycode.SDLK_KP_2, cast(Exception) null);
        case EnumKeyboardKeyCode.KpThree:
            return tuple(SDL_Keycode.SDLK_KP_3, cast(Exception) null);
        case EnumKeyboardKeyCode.KpFour:
            return tuple(SDL_Keycode.SDLK_KP_4, cast(Exception) null);
        case EnumKeyboardKeyCode.KpFive:
            return tuple(SDL_Keycode.SDLK_KP_5, cast(Exception) null);
        case EnumKeyboardKeyCode.KpSix:
            return tuple(SDL_Keycode.SDLK_KP_6, cast(Exception) null);
        case EnumKeyboardKeyCode.KpSeven:
            return tuple(SDL_Keycode.SDLK_KP_7, cast(Exception) null);
        case EnumKeyboardKeyCode.KpEight:
            return tuple(SDL_Keycode.SDLK_KP_8, cast(Exception) null);
        case EnumKeyboardKeyCode.KpNine:
            return tuple(SDL_Keycode.SDLK_KP_9, cast(Exception) null);
        case EnumKeyboardKeyCode.KpDevide:
            return tuple(SDL_Keycode.SDLK_KP_DIVIDE, cast(Exception) null);
        case EnumKeyboardKeyCode.KpEnter:
            return tuple(SDL_Keycode.SDLK_KP_ENTER, cast(Exception) null);
        case EnumKeyboardKeyCode.KpEquals:
            return tuple(SDL_Keycode.SDLK_KP_EQUALS, cast(Exception) null);
        case EnumKeyboardKeyCode.KpMinus:
            return tuple(SDL_Keycode.SDLK_KP_MINUS, cast(Exception) null);
        case EnumKeyboardKeyCode.KpMultiply:
            return tuple(SDL_Keycode.SDLK_KP_MULTIPLY, cast(Exception) null);
        case EnumKeyboardKeyCode.KpPlus:
            return tuple(SDL_Keycode.SDLK_KP_PLUS, cast(Exception) null);
    }
}

Tuple!(EnumKeyboardModCode, Exception) convertSingleSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)
{
    switch (code) {
        default:
            return tuple(cast(EnumKeyboardModCode)0, new Exception("could not decode supplied keycode: "~ format("%s", code)) );
        case SDL_Keymod.KMOD_LSHIFT:
            return tuple(EnumKeyboardModCode.LeftShift, cast(Exception)null);
        case SDL_Keymod.KMOD_LCTRL:
            return tuple(EnumKeyboardModCode.LeftControl, cast(Exception)null);
        case SDL_Keymod.KMOD_LGUI:
            return tuple(EnumKeyboardModCode.LeftSuper, cast(Exception)null);
        case SDL_Keymod.KMOD_LALT:
            return tuple(EnumKeyboardModCode.LeftAlt, cast(Exception)null);
        case SDL_Keymod.KMOD_RSHIFT:
            return tuple(EnumKeyboardModCode.RightShift, cast(Exception)null);
        case SDL_Keymod.KMOD_RCTRL:
            return tuple(EnumKeyboardModCode.RightControl, cast(Exception)null);
        case SDL_Keymod.KMOD_RGUI:
            return tuple(EnumKeyboardModCode.RightSuper, cast(Exception)null);
        case SDL_Keymod.KMOD_RALT:
            return tuple(EnumKeyboardModCode.RightAlt, cast(Exception)null);
        case SDL_Keymod.KMOD_CAPS:
            return tuple(EnumKeyboardModCode.CapsLock, cast(Exception)null);
        case SDL_Keymod.KMOD_NUM:
            return tuple(EnumKeyboardModCode.NumLock, cast(Exception)null);
    }
}

Tuple!(SDL_Keymod, Exception) convertSingleEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)
{
    switch (code) {
        default:
            return tuple(cast(SDL_Keymod)0, new Exception("could not decode supplied keycode: "~ format("%s", code)) );
        case EnumKeyboardModCode.LeftShift:
            return tuple(SDL_Keymod.KMOD_LSHIFT,cast(Exception)null);
        case EnumKeyboardModCode.LeftControl:
            return tuple(SDL_Keymod.KMOD_LCTRL,cast(Exception)null);
        case EnumKeyboardModCode.LeftAlt:
            return tuple(SDL_Keymod.KMOD_LALT,cast(Exception)null);
        case EnumKeyboardModCode.RightShift:
            return tuple(SDL_Keymod.KMOD_RSHIFT,cast(Exception)null);
        case EnumKeyboardModCode.RightControl:
            return tuple(SDL_Keymod.KMOD_RCTRL,cast(Exception)null);
        case EnumKeyboardModCode.RightAlt:
            return tuple(SDL_Keymod.KMOD_RALT,cast(Exception)null);
        case EnumKeyboardModCode.CapsLock:
            return tuple(SDL_Keymod.KMOD_CAPS,cast(Exception)null);
        case EnumKeyboardModCode.NumLock:
            return tuple(SDL_Keymod.KMOD_NUM,cast(Exception)null);
    }
}

Tuple!(EnumKeyboardModCode, Exception) convertCombinationSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)
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
   return tuple(ret, cast(Exception) null);
}

Tuple!(SDL_Keymod, Exception) convertCombinationEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)
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
   return tuple(ret, cast(Exception)null);
}

