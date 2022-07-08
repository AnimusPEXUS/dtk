module dtk.backends.glfw_desktop.keyconversion;

/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/

import std.typecons;
import std.format;

import bindbc.glfw;

import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;

Tuple!(EnumKeyboardKeyCode, Exception) convertGLWFKeycodeToEnumKeyboardKeyCode(int keycode)
{
    switch (keycode)
    {
    default:
        return tuple(cast(EnumKeyboardKeyCode) 0, new Exception("keycode not supported"));

    case int.GLFW_KEY_ESCAPE:
        return tuple(EnumKeyboardKeyCode.Escape, cast(Exception) null);

    case int.GLFW_KEY_ESC:
        return tuple(EnumKeyboardKeyCode.Escape, cast(Exception) null);

    case int.GLFW_KEY_F1:
        return tuple(EnumKeyboardKeyCode.F1, cast(Exception) null);

    case int.GLFW_KEY_F2:
        return tuple(EnumKeyboardKeyCode.F2, cast(Exception) null);

    case int.GLFW_KEY_F3:
        return tuple(EnumKeyboardKeyCode.F3, cast(Exception) null);

    case int.GLFW_KEY_F4:
        return tuple(EnumKeyboardKeyCode.F4, cast(Exception) null);

    case int.GLFW_KEY_F5:
        return tuple(EnumKeyboardKeyCode.F5, cast(Exception) null);

    case int.GLFW_KEY_F6:
        return tuple(EnumKeyboardKeyCode.F6, cast(Exception) null);

    case int.GLFW_KEY_F7:
        return tuple(EnumKeyboardKeyCode.F7, cast(Exception) null);

    case int.GLFW_KEY_F8:
        return tuple(EnumKeyboardKeyCode.F8, cast(Exception) null);

    case int.GLFW_KEY_F9:
        return tuple(EnumKeyboardKeyCode.F9, cast(Exception) null);

    case int.GLFW_KEY_F10:
        return tuple(EnumKeyboardKeyCode.F10, cast(Exception) null);

    case int.GLFW_KEY_F11:
        return tuple(EnumKeyboardKeyCode.F11, cast(Exception) null);

    case int.GLFW_KEY_F12:
        return tuple(EnumKeyboardKeyCode.F12, cast(Exception) null);

    case int.GLFW_KEY_F13:
        return tuple(EnumKeyboardKeyCode.F13, cast(Exception) null);

    case int.GLFW_KEY_F14:
        return tuple(EnumKeyboardKeyCode.F14, cast(Exception) null);

    case int.GLFW_KEY_F15:
        return tuple(EnumKeyboardKeyCode.F15, cast(Exception) null);

    case int.GLFW_KEY_F16:
        return tuple(EnumKeyboardKeyCode.F16, cast(Exception) null);

    case int.GLFW_KEY_F17:
        return tuple(EnumKeyboardKeyCode.F17, cast(Exception) null);

    case int.GLFW_KEY_F18:
        return tuple(EnumKeyboardKeyCode.F18, cast(Exception) null);

    case int.GLFW_KEY_F19:
        return tuple(EnumKeyboardKeyCode.F19, cast(Exception) null);

    case int.GLFW_KEY_F20:
        return tuple(EnumKeyboardKeyCode.F20, cast(Exception) null);

    case int.GLFW_KEY_F21:
        return tuple(EnumKeyboardKeyCode.F21, cast(Exception) null);

    case int.GLFW_KEY_F22:
        return tuple(EnumKeyboardKeyCode.F22, cast(Exception) null);

    case int.GLFW_KEY_F23:
        return tuple(EnumKeyboardKeyCode.F23, cast(Exception) null);

    case int.GLFW_KEY_F24:
        return tuple(EnumKeyboardKeyCode.F24, cast(Exception) null);

    case int.GLFW_KEY_A:
        return tuple(EnumKeyboardKeyCode.A, cast(Exception) null);

    case int.GLFW_KEY_B:
        return tuple(EnumKeyboardKeyCode.B, cast(Exception) null);

    case int.GLFW_KEY_C:
        return tuple(EnumKeyboardKeyCode.C, cast(Exception) null);

    case int.GLFW_KEY_D:
        return tuple(EnumKeyboardKeyCode.D, cast(Exception) null);

    case int.GLFW_KEY_E:
        return tuple(EnumKeyboardKeyCode.E, cast(Exception) null);

    case int.GLFW_KEY_F:
        return tuple(EnumKeyboardKeyCode.F, cast(Exception) null);

    case int.GLFW_KEY_G:
        return tuple(EnumKeyboardKeyCode.G, cast(Exception) null);

    case int.GLFW_KEY_H:
        return tuple(EnumKeyboardKeyCode.H, cast(Exception) null);

    case int.GLFW_KEY_I:
        return tuple(EnumKeyboardKeyCode.I, cast(Exception) null);

    case int.GLFW_KEY_J:
        return tuple(EnumKeyboardKeyCode.J, cast(Exception) null);

    case int.GLFW_KEY_K:
        return tuple(EnumKeyboardKeyCode.K, cast(Exception) null);

    case int.GLFW_KEY_L:
        return tuple(EnumKeyboardKeyCode.L, cast(Exception) null);

    case int.GLFW_KEY_M:
        return tuple(EnumKeyboardKeyCode.M, cast(Exception) null);

    case int.GLFW_KEY_N:
        return tuple(EnumKeyboardKeyCode.N, cast(Exception) null);

    case int.GLFW_KEY_O:
        return tuple(EnumKeyboardKeyCode.O, cast(Exception) null);

    case int.GLFW_KEY_P:
        return tuple(EnumKeyboardKeyCode.P, cast(Exception) null);

    case int.GLFW_KEY_Q:
        return tuple(EnumKeyboardKeyCode.Q, cast(Exception) null);

    case int.GLFW_KEY_R:
        return tuple(EnumKeyboardKeyCode.R, cast(Exception) null);

    case int.GLFW_KEY_S:
        return tuple(EnumKeyboardKeyCode.S, cast(Exception) null);

    case int.GLFW_KEY_T:
        return tuple(EnumKeyboardKeyCode.T, cast(Exception) null);

    case int.GLFW_KEY_U:
        return tuple(EnumKeyboardKeyCode.U, cast(Exception) null);

    case int.GLFW_KEY_V:
        return tuple(EnumKeyboardKeyCode.V, cast(Exception) null);

    case int.GLFW_KEY_W:
        return tuple(EnumKeyboardKeyCode.W, cast(Exception) null);

    case int.GLFW_KEY_X:
        return tuple(EnumKeyboardKeyCode.X, cast(Exception) null);

    case int.GLFW_KEY_Y:
        return tuple(EnumKeyboardKeyCode.Y, cast(Exception) null);

    case int.GLFW_KEY_Z:
        return tuple(EnumKeyboardKeyCode.Z, cast(Exception) null);

    case int.GLFW_KEY_SPACE:
        return tuple(EnumKeyboardKeyCode.Space, cast(Exception) null);

    case int.GLFW_KEY_0:
        return tuple(EnumKeyboardKeyCode.Zero, cast(Exception) null);

    case int.GLFW_KEY_1:
        return tuple(EnumKeyboardKeyCode.One, cast(Exception) null);

    case int.GLFW_KEY_2:
        return tuple(EnumKeyboardKeyCode.Two, cast(Exception) null);

    case int.GLFW_KEY_3:
        return tuple(EnumKeyboardKeyCode.Three, cast(Exception) null);

    case int.GLFW_KEY_4:
        return tuple(EnumKeyboardKeyCode.Four, cast(Exception) null);

    case int.GLFW_KEY_5:
        return tuple(EnumKeyboardKeyCode.Five, cast(Exception) null);

    case int.GLFW_KEY_6:
        return tuple(EnumKeyboardKeyCode.Six, cast(Exception) null);

    case int.GLFW_KEY_7:
        return tuple(EnumKeyboardKeyCode.Seven, cast(Exception) null);

    case int.GLFW_KEY_8:
        return tuple(EnumKeyboardKeyCode.Eight, cast(Exception) null);

    case int.GLFW_KEY_9:
        return tuple(EnumKeyboardKeyCode.Nine, cast(Exception) null);

    case int.GLFW_KEY_MINUS:
        return tuple(EnumKeyboardKeyCode.Minus, cast(Exception) null);

    case int.GLFW_KEY_EQUAL:
        return tuple(EnumKeyboardKeyCode.Equals, cast(Exception) null);

    case int.GLFW_KEY_TAB:
        return tuple(EnumKeyboardKeyCode.Tabulation, cast(Exception) null);

    case int.GLFW_KEY_LEFT_SHIFT:
        return tuple(EnumKeyboardKeyCode.LeftShift, cast(Exception) null);

    case int.GLFW_KEY_LSHIFT:
        return tuple(EnumKeyboardKeyCode.LeftShift, cast(Exception) null);

    case int.GLFW_KEY_LCTRL:
        return tuple(EnumKeyboardKeyCode.LeftControl, cast(Exception) null);

    case int.GLFW_KEY_LEFT_CONTROL:
        return tuple(EnumKeyboardKeyCode.LeftControl, cast(Exception) null);

    case int.GLFW_KEY_LSUPER:
        return tuple(EnumKeyboardKeyCode.LeftSuper, cast(Exception) null);

    case int.GLFW_KEY_LEFT_SUPER:
        return tuple(EnumKeyboardKeyCode.LeftSuper, cast(Exception) null);

    case int.GLFW_KEY_LALT:
        return tuple(EnumKeyboardKeyCode.LeftAlt, cast(Exception) null);

    case int.GLFW_KEY_LEFT_ALT:
        return tuple(EnumKeyboardKeyCode.LeftAlt, cast(Exception) null);

    case int.GLFW_KEY_RIGHT_SHIFT:
        return tuple(EnumKeyboardKeyCode.RightShift, cast(Exception) null);

    case int.GLFW_KEY_RSHIFT:
        return tuple(EnumKeyboardKeyCode.RightShift, cast(Exception) null);

    case int.GLFW_KEY_RCTRL:
        return tuple(EnumKeyboardKeyCode.RightControl, cast(Exception) null);

    case int.GLFW_KEY_RIGHT_CONTROL:
        return tuple(EnumKeyboardKeyCode.RightControl, cast(Exception) null);

    case int.GLFW_KEY_MENU:
        return tuple(EnumKeyboardKeyCode.RightMenu, cast(Exception) null);

    case int.GLFW_KEY_RIGHT_SUPER:
        return tuple(EnumKeyboardKeyCode.RightSuper, cast(Exception) null);

    case int.GLFW_KEY_RSUPER:
        return tuple(EnumKeyboardKeyCode.RightSuper, cast(Exception) null);

    case int.GLFW_KEY_RALT:
        return tuple(EnumKeyboardKeyCode.RightAlt, cast(Exception) null);

    case int.GLFW_KEY_RIGHT_ALT:
        return tuple(EnumKeyboardKeyCode.RightAlt, cast(Exception) null);

    case int.GLFW_KEY_CAPS_LOCK:
        return tuple(EnumKeyboardKeyCode.CapsLock, cast(Exception) null);

    case int.GLFW_KEY_NUM_LOCK:
        return tuple(EnumKeyboardKeyCode.NumLock, cast(Exception) null);

    case int.GLFW_KEY_KP_NUM_LOCK:
        return tuple(EnumKeyboardKeyCode.NumLock, cast(Exception) null);

    case int.GLFW_KEY_SCROLL_LOCK:
        return tuple(EnumKeyboardKeyCode.ScrollLock, cast(Exception) null);

    case int.GLFW_KEY_BACKSPACE:
        return tuple(EnumKeyboardKeyCode.BackSpace, cast(Exception) null);

    case int.GLFW_KEY_ENTER:
        return tuple(EnumKeyboardKeyCode.Return, cast(Exception) null);

    case int.GLFW_KEY_LEFT_BRACKET:
        return tuple(EnumKeyboardKeyCode.SquareLeftBracket, cast(Exception) null);

    case int.GLFW_KEY_RIGHT_BRACKET:
        return tuple(EnumKeyboardKeyCode.SquareRightBracket, cast(Exception) null);

    case int.GLFW_KEY_SEMICOLON:
        return tuple(EnumKeyboardKeyCode.Semicolon, cast(Exception) null);

    case int.GLFW_KEY_APOSTROPHE:
        return tuple(EnumKeyboardKeyCode.SingleQuote, cast(Exception) null);

    case int.GLFW_KEY_BACKSLASH:
        return tuple(EnumKeyboardKeyCode.BackSlash, cast(Exception) null);

    case int.GLFW_KEY_COMMA:
        return tuple(EnumKeyboardKeyCode.Comma, cast(Exception) null);

    case int.GLFW_KEY_PERIOD:
        return tuple(EnumKeyboardKeyCode.Period, cast(Exception) null);

    case int.GLFW_KEY_SLASH:
        return tuple(EnumKeyboardKeyCode.Slash, cast(Exception) null);

    case int.GLFW_KEY_INSERT:
        return tuple(EnumKeyboardKeyCode.Insert, cast(Exception) null);

    case int.GLFW_KEY_DEL:
        return tuple(EnumKeyboardKeyCode.Delete, cast(Exception) null);

    case int.GLFW_KEY_DELETE:
        return tuple(EnumKeyboardKeyCode.Delete, cast(Exception) null);

    case int.GLFW_KEY_HOME:
        return tuple(EnumKeyboardKeyCode.Home, cast(Exception) null);

    case int.GLFW_KEY_END:
        return tuple(EnumKeyboardKeyCode.End, cast(Exception) null);

    case int.GLFW_KEY_PAGE_UP:
        return tuple(EnumKeyboardKeyCode.PageUp, cast(Exception) null);

    case int.GLFW_KEY_PAGEUP:
        return tuple(EnumKeyboardKeyCode.PageUp, cast(Exception) null);

    case int.GLFW_KEY_PAGE_DOWN:
        return tuple(EnumKeyboardKeyCode.PageDown, cast(Exception) null);

    case int.GLFW_KEY_PAGEDOWN:
        return tuple(EnumKeyboardKeyCode.PageDown, cast(Exception) null);

    case int.GLFW_KEY_PRINT_SCREEN:
        return tuple(EnumKeyboardKeyCode.PrintScreen, cast(Exception) null);

    case int.GLFW_KEY_PAUSE:
        return tuple(EnumKeyboardKeyCode.Pause, cast(Exception) null);

    case int.GLFW_KEY_UP:
        return tuple(EnumKeyboardKeyCode.Up, cast(Exception) null);

    case int.GLFW_KEY_DOWN:
        return tuple(EnumKeyboardKeyCode.Down, cast(Exception) null);

    case int.GLFW_KEY_LEFT:
        return tuple(EnumKeyboardKeyCode.Left, cast(Exception) null);

    case int.GLFW_KEY_RIGHT:
        return tuple(EnumKeyboardKeyCode.Right, cast(Exception) null);

    case int.GLFW_KEY_KP_0:
        return tuple(EnumKeyboardKeyCode.KpZero, cast(Exception) null);

    case int.GLFW_KEY_KP_1:
        return tuple(EnumKeyboardKeyCode.KpOne, cast(Exception) null);

    case int.GLFW_KEY_KP_2:
        return tuple(EnumKeyboardKeyCode.KpTwo, cast(Exception) null);

    case int.GLFW_KEY_KP_3:
        return tuple(EnumKeyboardKeyCode.KpThree, cast(Exception) null);

    case int.GLFW_KEY_KP_4:
        return tuple(EnumKeyboardKeyCode.KpFour, cast(Exception) null);

    case int.GLFW_KEY_KP_5:
        return tuple(EnumKeyboardKeyCode.KpFive, cast(Exception) null);

    case int.GLFW_KEY_KP_6:
        return tuple(EnumKeyboardKeyCode.KpSix, cast(Exception) null);

    case int.GLFW_KEY_KP_7:
        return tuple(EnumKeyboardKeyCode.KpSeven, cast(Exception) null);

    case int.GLFW_KEY_KP_8:
        return tuple(EnumKeyboardKeyCode.KpEight, cast(Exception) null);

    case int.GLFW_KEY_KP_9:
        return tuple(EnumKeyboardKeyCode.KpNine, cast(Exception) null);

    case int.GLFW_KEY_KP_DIVIDE:
        return tuple(EnumKeyboardKeyCode.KpDevide, cast(Exception) null);

    case int.GLFW_KEY_KP_ENTER:
        return tuple(EnumKeyboardKeyCode.KpEnter, cast(Exception) null);

    case int.GLFW_KEY_KP_EQUAL:
        return tuple(EnumKeyboardKeyCode.KpEquals, cast(Exception) null);

    case int.GLFW_KEY_KP_SUBTRACT:
        return tuple(EnumKeyboardKeyCode.KpMinus, cast(Exception) null);

    case int.GLFW_KEY_KP_MULTIPLY:
        return tuple(EnumKeyboardKeyCode.KpMultiply, cast(Exception) null);

    case int.GLFW_KEY_KP_ADD:
        return tuple(EnumKeyboardKeyCode.KpPlus, cast(Exception) null);

    }
}

Tuple!(int, Exception) convertEnumKeyboardKeyCodeToGLWFKeycode(EnumKeyboardKeyCode keycode)
{
    switch (keycode)
    {
    default:
        return tuple(cast(int) 0, new Exception("keycode not supported"));

    case EnumKeyboardKeyCode.Escape:
        return tuple(int.GLFW_KEY_ESCAPE,
                GLFW_KEY_ESC, cast(Exception) null);

    case EnumKeyboardKeyCode.F1:
        return tuple(int.GLFW_KEY_F1, cast(Exception) null);

    case EnumKeyboardKeyCode.F2:
        return tuple(int.GLFW_KEY_F2, cast(Exception) null);

    case EnumKeyboardKeyCode.F3:
        return tuple(int.GLFW_KEY_F3, cast(Exception) null);

    case EnumKeyboardKeyCode.F4:
        return tuple(int.GLFW_KEY_F4, cast(Exception) null);

    case EnumKeyboardKeyCode.F5:
        return tuple(int.GLFW_KEY_F5, cast(Exception) null);

    case EnumKeyboardKeyCode.F6:
        return tuple(int.GLFW_KEY_F6, cast(Exception) null);

    case EnumKeyboardKeyCode.F7:
        return tuple(int.GLFW_KEY_F7, cast(Exception) null);

    case EnumKeyboardKeyCode.F8:
        return tuple(int.GLFW_KEY_F8, cast(Exception) null);

    case EnumKeyboardKeyCode.F9:
        return tuple(int.GLFW_KEY_F9, cast(Exception) null);

    case EnumKeyboardKeyCode.F10:
        return tuple(int.GLFW_KEY_F10, cast(Exception) null);

    case EnumKeyboardKeyCode.F11:
        return tuple(int.GLFW_KEY_F11, cast(Exception) null);

    case EnumKeyboardKeyCode.F12:
        return tuple(int.GLFW_KEY_F12, cast(Exception) null);

    case EnumKeyboardKeyCode.F13:
        return tuple(int.GLFW_KEY_F13, cast(Exception) null);

    case EnumKeyboardKeyCode.F14:
        return tuple(int.GLFW_KEY_F14, cast(Exception) null);

    case EnumKeyboardKeyCode.F15:
        return tuple(int.GLFW_KEY_F15, cast(Exception) null);

    case EnumKeyboardKeyCode.F16:
        return tuple(int.GLFW_KEY_F16, cast(Exception) null);

    case EnumKeyboardKeyCode.F17:
        return tuple(int.GLFW_KEY_F17, cast(Exception) null);

    case EnumKeyboardKeyCode.F18:
        return tuple(int.GLFW_KEY_F18, cast(Exception) null);

    case EnumKeyboardKeyCode.F19:
        return tuple(int.GLFW_KEY_F19, cast(Exception) null);

    case EnumKeyboardKeyCode.F20:
        return tuple(int.GLFW_KEY_F20, cast(Exception) null);

    case EnumKeyboardKeyCode.F21:
        return tuple(int.GLFW_KEY_F21, cast(Exception) null);

    case EnumKeyboardKeyCode.F22:
        return tuple(int.GLFW_KEY_F22, cast(Exception) null);

    case EnumKeyboardKeyCode.F23:
        return tuple(int.GLFW_KEY_F23, cast(Exception) null);

    case EnumKeyboardKeyCode.F24:
        return tuple(int.GLFW_KEY_F24, cast(Exception) null);

    case EnumKeyboardKeyCode.A:
        return tuple(int.GLFW_KEY_A, cast(Exception) null);

    case EnumKeyboardKeyCode.B:
        return tuple(int.GLFW_KEY_B, cast(Exception) null);

    case EnumKeyboardKeyCode.C:
        return tuple(int.GLFW_KEY_C, cast(Exception) null);

    case EnumKeyboardKeyCode.D:
        return tuple(int.GLFW_KEY_D, cast(Exception) null);

    case EnumKeyboardKeyCode.E:
        return tuple(int.GLFW_KEY_E, cast(Exception) null);

    case EnumKeyboardKeyCode.F:
        return tuple(int.GLFW_KEY_F, cast(Exception) null);

    case EnumKeyboardKeyCode.G:
        return tuple(int.GLFW_KEY_G, cast(Exception) null);

    case EnumKeyboardKeyCode.H:
        return tuple(int.GLFW_KEY_H, cast(Exception) null);

    case EnumKeyboardKeyCode.I:
        return tuple(int.GLFW_KEY_I, cast(Exception) null);

    case EnumKeyboardKeyCode.J:
        return tuple(int.GLFW_KEY_J, cast(Exception) null);

    case EnumKeyboardKeyCode.K:
        return tuple(int.GLFW_KEY_K, cast(Exception) null);

    case EnumKeyboardKeyCode.L:
        return tuple(int.GLFW_KEY_L, cast(Exception) null);

    case EnumKeyboardKeyCode.M:
        return tuple(int.GLFW_KEY_M, cast(Exception) null);

    case EnumKeyboardKeyCode.N:
        return tuple(int.GLFW_KEY_N, cast(Exception) null);

    case EnumKeyboardKeyCode.O:
        return tuple(int.GLFW_KEY_O, cast(Exception) null);

    case EnumKeyboardKeyCode.P:
        return tuple(int.GLFW_KEY_P, cast(Exception) null);

    case EnumKeyboardKeyCode.Q:
        return tuple(int.GLFW_KEY_Q, cast(Exception) null);

    case EnumKeyboardKeyCode.R:
        return tuple(int.GLFW_KEY_R, cast(Exception) null);

    case EnumKeyboardKeyCode.S:
        return tuple(int.GLFW_KEY_S, cast(Exception) null);

    case EnumKeyboardKeyCode.T:
        return tuple(int.GLFW_KEY_T, cast(Exception) null);

    case EnumKeyboardKeyCode.U:
        return tuple(int.GLFW_KEY_U, cast(Exception) null);

    case EnumKeyboardKeyCode.V:
        return tuple(int.GLFW_KEY_V, cast(Exception) null);

    case EnumKeyboardKeyCode.W:
        return tuple(int.GLFW_KEY_W, cast(Exception) null);

    case EnumKeyboardKeyCode.X:
        return tuple(int.GLFW_KEY_X, cast(Exception) null);

    case EnumKeyboardKeyCode.Y:
        return tuple(int.GLFW_KEY_Y, cast(Exception) null);

    case EnumKeyboardKeyCode.Z:
        return tuple(int.GLFW_KEY_Z, cast(Exception) null);

    case EnumKeyboardKeyCode.Space:
        return tuple(int.GLFW_KEY_SPACE, cast(Exception) null);

    case EnumKeyboardKeyCode.Zero:
        return tuple(int.GLFW_KEY_0, cast(Exception) null);

    case EnumKeyboardKeyCode.One:
        return tuple(int.GLFW_KEY_1, cast(Exception) null);

    case EnumKeyboardKeyCode.Two:
        return tuple(int.GLFW_KEY_2, cast(Exception) null);

    case EnumKeyboardKeyCode.Three:
        return tuple(int.GLFW_KEY_3, cast(Exception) null);

    case EnumKeyboardKeyCode.Four:
        return tuple(int.GLFW_KEY_4, cast(Exception) null);

    case EnumKeyboardKeyCode.Five:
        return tuple(int.GLFW_KEY_5, cast(Exception) null);

    case EnumKeyboardKeyCode.Six:
        return tuple(int.GLFW_KEY_6, cast(Exception) null);

    case EnumKeyboardKeyCode.Seven:
        return tuple(int.GLFW_KEY_7, cast(Exception) null);

    case EnumKeyboardKeyCode.Eight:
        return tuple(int.GLFW_KEY_8, cast(Exception) null);

    case EnumKeyboardKeyCode.Nine:
        return tuple(int.GLFW_KEY_9, cast(Exception) null);

    case EnumKeyboardKeyCode.Minus:
        return tuple(int.GLFW_KEY_MINUS, cast(Exception) null);

    case EnumKeyboardKeyCode.Equals:
        return tuple(int.GLFW_KEY_EQUAL, cast(Exception) null);

    case EnumKeyboardKeyCode.Tabulation:
        return tuple(int.GLFW_KEY_TAB, cast(Exception) null);

    case EnumKeyboardKeyCode.LeftShift:
        return tuple(int.GLFW_KEY_LEFT_SHIFT,
                GLFW_KEY_LSHIFT, cast(Exception) null);

    case EnumKeyboardKeyCode.LeftControl:
        return tuple(int.GLFW_KEY_LCTRL,
                GLFW_KEY_LEFT_CONTROL, cast(Exception) null);

    case EnumKeyboardKeyCode.LeftSuper:
        return tuple(int.GLFW_KEY_LSUPER,
                GLFW_KEY_LEFT_SUPER, cast(Exception) null);

    case EnumKeyboardKeyCode.LeftAlt:
        return tuple(int.GLFW_KEY_LALT,
                GLFW_KEY_LEFT_ALT, cast(Exception) null);

    case EnumKeyboardKeyCode.RightShift:
        return tuple(int.GLFW_KEY_RIGHT_SHIFT,
                GLFW_KEY_RSHIFT, cast(Exception) null);

    case EnumKeyboardKeyCode.RightControl:
        return tuple(int.GLFW_KEY_RCTRL,
                GLFW_KEY_RIGHT_CONTROL, cast(Exception) null);

    case EnumKeyboardKeyCode.RightMenu:
        return tuple(int.GLFW_KEY_MENU, cast(Exception) null);

    case EnumKeyboardKeyCode.RightSuper:
        return tuple(int.GLFW_KEY_RIGHT_SUPER,
                GLFW_KEY_RSUPER, cast(Exception) null);

    case EnumKeyboardKeyCode.RightAlt:
        return tuple(int.GLFW_KEY_RALT,
                GLFW_KEY_RIGHT_ALT, cast(Exception) null);

    case EnumKeyboardKeyCode.CapsLock:
        return tuple(int.GLFW_KEY_CAPS_LOCK, cast(Exception) null);

    case EnumKeyboardKeyCode.NumLock:
        return tuple(int.GLFW_KEY_NUM_LOCK,
                GLFW_KEY_KP_NUM_LOCK, cast(Exception) null);

    case EnumKeyboardKeyCode.ScrollLock:
        return tuple(int.GLFW_KEY_SCROLL_LOCK, cast(Exception) null);

    case EnumKeyboardKeyCode.BackSpace:
        return tuple(int.GLFW_KEY_BACKSPACE, cast(Exception) null);

    case EnumKeyboardKeyCode.Return:
        return tuple(int.GLFW_KEY_ENTER, cast(Exception) null);

    case EnumKeyboardKeyCode.SquareLeftBracket:
        return tuple(int.GLFW_KEY_LEFT_BRACKET, cast(Exception) null);

    case EnumKeyboardKeyCode.SquareRightBracket:
        return tuple(int.GLFW_KEY_RIGHT_BRACKET, cast(Exception) null);

    case EnumKeyboardKeyCode.Semicolon:
        return tuple(int.GLFW_KEY_SEMICOLON, cast(Exception) null);

    case EnumKeyboardKeyCode.SingleQuote:
        return tuple(int.GLFW_KEY_APOSTROPHE, cast(Exception) null);

    case EnumKeyboardKeyCode.BackSlash:
        return tuple(int.GLFW_KEY_BACKSLASH, cast(Exception) null);

    case EnumKeyboardKeyCode.Comma:
        return tuple(int.GLFW_KEY_COMMA, cast(Exception) null);

    case EnumKeyboardKeyCode.Period:
        return tuple(int.GLFW_KEY_PERIOD, cast(Exception) null);

    case EnumKeyboardKeyCode.Slash:
        return tuple(int.GLFW_KEY_SLASH, cast(Exception) null);

    case EnumKeyboardKeyCode.Insert:
        return tuple(int.GLFW_KEY_INSERT, cast(Exception) null);

    case EnumKeyboardKeyCode.Delete:
        return tuple(int.GLFW_KEY_DEL,
                GLFW_KEY_DELETE, cast(Exception) null);

    case EnumKeyboardKeyCode.Home:
        return tuple(int.GLFW_KEY_HOME, cast(Exception) null);

    case EnumKeyboardKeyCode.End:
        return tuple(int.GLFW_KEY_END, cast(Exception) null);

    case EnumKeyboardKeyCode.PageUp:
        return tuple(int.GLFW_KEY_PAGE_UP,
                GLFW_KEY_PAGEUP, cast(Exception) null);

    case EnumKeyboardKeyCode.PageDown:
        return tuple(int.GLFW_KEY_PAGE_DOWN,
                GLFW_KEY_PAGEDOWN, cast(Exception) null);

    case EnumKeyboardKeyCode.PrintScreen:
        return tuple(int.GLFW_KEY_PRINT_SCREEN, cast(Exception) null);

    case EnumKeyboardKeyCode.Pause:
        return tuple(int.GLFW_KEY_PAUSE, cast(Exception) null);

    case EnumKeyboardKeyCode.Up:
        return tuple(int.GLFW_KEY_UP, cast(Exception) null);

    case EnumKeyboardKeyCode.Down:
        return tuple(int.GLFW_KEY_DOWN, cast(Exception) null);

    case EnumKeyboardKeyCode.Left:
        return tuple(int.GLFW_KEY_LEFT, cast(Exception) null);

    case EnumKeyboardKeyCode.Right:
        return tuple(int.GLFW_KEY_RIGHT, cast(Exception) null);

    case EnumKeyboardKeyCode.KpZero:
        return tuple(int.GLFW_KEY_KP_0, cast(Exception) null);

    case EnumKeyboardKeyCode.KpOne:
        return tuple(int.GLFW_KEY_KP_1, cast(Exception) null);

    case EnumKeyboardKeyCode.KpTwo:
        return tuple(int.GLFW_KEY_KP_2, cast(Exception) null);

    case EnumKeyboardKeyCode.KpThree:
        return tuple(int.GLFW_KEY_KP_3, cast(Exception) null);

    case EnumKeyboardKeyCode.KpFour:
        return tuple(int.GLFW_KEY_KP_4, cast(Exception) null);

    case EnumKeyboardKeyCode.KpFive:
        return tuple(int.GLFW_KEY_KP_5, cast(Exception) null);

    case EnumKeyboardKeyCode.KpSix:
        return tuple(int.GLFW_KEY_KP_6, cast(Exception) null);

    case EnumKeyboardKeyCode.KpSeven:
        return tuple(int.GLFW_KEY_KP_7, cast(Exception) null);

    case EnumKeyboardKeyCode.KpEight:
        return tuple(int.GLFW_KEY_KP_8, cast(Exception) null);

    case EnumKeyboardKeyCode.KpNine:
        return tuple(int.GLFW_KEY_KP_9, cast(Exception) null);

    case EnumKeyboardKeyCode.KpDevide:
        return tuple(int.GLFW_KEY_KP_DIVIDE, cast(Exception) null);

    case EnumKeyboardKeyCode.KpEnter:
        return tuple(int.GLFW_KEY_KP_ENTER, cast(Exception) null);

    case EnumKeyboardKeyCode.KpEquals:
        return tuple(int.GLFW_KEY_KP_EQUAL, cast(Exception) null);

    case EnumKeyboardKeyCode.KpMinus:
        return tuple(int.GLFW_KEY_KP_SUBTRACT, cast(Exception) null);

    case EnumKeyboardKeyCode.KpMultiply:
        return tuple(int.GLFW_KEY_KP_MULTIPLY, cast(Exception) null);

    case EnumKeyboardKeyCode.KpPlus:
        return tuple(int.GLFW_KEY_KP_ADD, cast(Exception) null);

    }
}

Tuple!(EnumKeyboardModCode, Exception) convertSingleGLWFKeymodToEnumKeyboardModCode(GLWF_Keymod code)
{
    switch (code)
    {
    default:
        return tuple(cast(EnumKeyboardModCode) 0,
                new Exception("could not decode supplied keycode: " ~ format("%s", code)));
    case GLWF_Keymod.GLFW_MOD_SHIFT:
        return tuple(EnumKeyboardModCode.LeftShift,
                cast(Exception) null);
    case GLWF_Keymod.GLFW_MOD_CONTROL:
        return tuple(EnumKeyboardModCode.LeftControl, cast(Exception) null);
    case GLWF_Keymod.GLFW_MOD_SUPER:
        return tuple(EnumKeyboardModCode.LeftSuper,
                cast(Exception) null);
    case GLWF_Keymod.GLFW_MOD_ALT:
        return tuple(EnumKeyboardModCode.LeftAlt, cast(Exception) null);
    }
}

Tuple!(GLWF_Keymod, Exception) convertSingleEnumKeyboardModCodeToGLWFKeymod(EnumKeyboardModCode code)
{
    switch (code)
    {
    default:
        return tuple(cast(GLWF_Keymod) 0,
                new Exception("could not decode supplied keycode: " ~ format("%s", code)));
    case EnumKeyboardModCode.LeftShift:
        return tuple(GLWF_Keymod.GLFW_MOD_SHIFT,
                cast(Exception) null);
    case EnumKeyboardModCode.LeftControl:
        return tuple(GLWF_Keymod.GLFW_MOD_CONTROL, cast(Exception) null);
    case EnumKeyboardModCode.LeftSuper:
        return tuple(GLWF_Keymod.GLFW_MOD_SUPER,
                cast(Exception) null);
    case EnumKeyboardModCode.LeftAlt:
        return tuple(GLWF_Keymod.GLFW_MOD_ALT, cast(Exception) null);
    }
}

Tuple!(EnumKeyboardModCode, Exception) convertCombinationGLWFKeymodToEnumKeyboardModCode(
        GLWF_Keymod code)
{
    EnumKeyboardModCode ret;
    if ((code & GLWF_Keymod.GLFW_MOD_SHIFT) != 0)
    {
        ret |= EnumKeyboardModCode.LeftShift;
    }
    if ((code & GLWF_Keymod.GLFW_MOD_CONTROL) != 0)
    {
        ret |= EnumKeyboardModCode.LeftControl;
    }
    if ((code & GLWF_Keymod.GLFW_MOD_SUPER) != 0)
    {
        ret |= EnumKeyboardModCode.LeftSuper;
    }
    if ((code & GLWF_Keymod.GLFW_MOD_ALT) != 0)
    {
        ret |= EnumKeyboardModCode.LeftAlt;
    }
    return tuple(ret, cast(Exception) null);
}

Tuple!(GLWF_Keymod, Exception) convertCombinationEnumKeyboardModCodeToGLWFKeymod(
        EnumKeyboardModCode code)
{
    GLWF_Keymod ret;
    if ((code & EnumKeyboardModCode.LeftShift) != 0)
    {
        ret |= GLWF_Keymod.GLFW_MOD_SHIFT;
    }
    if ((code & EnumKeyboardModCode.LeftControl) != 0)
    {
        ret |= GLWF_Keymod.GLFW_MOD_CONTROL;
    }
    if ((code & EnumKeyboardModCode.LeftSuper) != 0)
    {
        ret |= GLWF_Keymod.GLFW_MOD_SUPER;
    }
    if ((code & EnumKeyboardModCode.LeftAlt) != 0)
    {
        ret |= GLWF_Keymod.GLFW_MOD_ALT;
    }
    return tuple(ret, cast(Exception) null);
}
