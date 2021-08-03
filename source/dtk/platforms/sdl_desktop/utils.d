module dtk.platforms.sdl_desktop.utils;

import bindbc.sdl;

import dtk.types.EventWindow;
import dtk.types.EnumWindowEvent;

import dtk.types.EventKeyboard;
import dtk.types.EnumKeyboardKeyState;
import dtk.types.KeySym;

import dtk.types.EventMouse;
import dtk.types.EnumWindowEvent;

import dtk.types.EventTextInput;

import dtk.platforms.sdl_desktop.sdlkeyconversion;

EventWindow* convertSDLWindowEventToDtkEventWindow(SDL_WindowEvent* e)
{
    EventWindow* ret = new EventWindow;
    switch (e.event)
    {
        default:
        /* case SDL_WINDOWEVENT_HIT_TEST: */
        case SDL_WINDOWEVENT_NONE:
            throw new Exception("unsupported SDL_WindowEvent.event");
        case SDL_WINDOWEVENT_SIZE_CHANGED:
            throw new Exception("should be ignored, not processed");
        case SDL_WINDOWEVENT_SHOWN:
            ret.eventId = EnumWindowEvent.show;
            break;
        case SDL_WINDOWEVENT_HIDDEN:
            ret.eventId = EnumWindowEvent.hide;
            break;
        case SDL_WINDOWEVENT_EXPOSED:
            ret.eventId = EnumWindowEvent.expose;
            break;
        case SDL_WINDOWEVENT_MOVED:
            ret.eventId = EnumWindowEvent.move;
            break;
        case SDL_WINDOWEVENT_RESIZED:
            ret.eventId = EnumWindowEvent.resize;
            break;
        case SDL_WINDOWEVENT_MINIMIZED:
            ret.eventId = EnumWindowEvent.minimize;
            break;
        case SDL_WINDOWEVENT_MAXIMIZED:
            ret.eventId = EnumWindowEvent.maximize;
            break;
        case SDL_WINDOWEVENT_RESTORED:
            ret.eventId = EnumWindowEvent.restore;
            break;
        case SDL_WINDOWEVENT_ENTER:
            ret.eventId = EnumWindowEvent.mouseFocus;
            break;
        case SDL_WINDOWEVENT_LEAVE:
            ret.eventId = EnumWindowEvent.mouseUnFocus;
            break;
        case SDL_WINDOWEVENT_FOCUS_GAINED:
            ret.eventId = EnumWindowEvent.keyboardFocus;
            break;
        case SDL_WINDOWEVENT_FOCUS_LOST:
            ret.eventId = EnumWindowEvent.keyboardUnFocus;
            break;
        case SDL_WINDOWEVENT_CLOSE:
            ret.eventId = EnumWindowEvent.close;
            break;
        /* case SDL_WINDOWEVENT_TAKE_FOCUS:
            ret.eventId = EnumWindowEvent.focusProposed; */
    }
    return ret;
}

EventKeyboard* convertSDLKeyboardEventToDtkEventKeyboard(SDL_KeyboardEvent* e)
{
    EventKeyboard* ret = new EventKeyboard;

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

EventMouse* convertSDLMouseMotionEventToDtkEventMouse(SDL_MouseMotionEvent* e)
{
    EventMouse* ret = new EventMouse;
    return ret;
}

EventMouse* convertSDLMouseButtonEventToDtkEventMouse(SDL_MouseButtonEvent* e)
{
    EventMouse* ret = new EventMouse;
    return ret;
}

EventMouse* convertSDLMouseWheelEventToDtkEventMouse(SDL_MouseWheelEvent* e)
{
    EventMouse* ret = new EventMouse;
    return ret;
}

EventTextInput* convertSDLWindowEventToDtkEventMouse(SDL_TextInputEvent* e)
{
    EventTextInput* ret = new EventTextInput;
    return ret;
}
