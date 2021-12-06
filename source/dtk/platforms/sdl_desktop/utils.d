module dtk.platforms.sdl_desktop.utils;

import std.stdio;
import std.conv;
import std.typecons;

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
        break;
    case SDL_WINDOWEVENT_NONE:
        break;
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
        ret.position.x = e.data1;
        ret.position.y = e.data2;
        break;
    case SDL_WINDOWEVENT_RESIZED:
        ret.eventId = EnumWindowEvent.resize;
        ret.size.width = e.data1;
        ret.size.height = e.data2;
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

Tuple!(EventKeyboard*, Exception) convertSDLKeyboardEventToDtkEventKeyboard(SDL_KeyboardEvent* e)
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

    {
        auto res = convertSDLKeycodeToEnumKeyboardKeyCode(e.keysym.sym);
        if (res[1]!is null)
        {
            return tuple(cast(EventKeyboard*) null, res[1]);
        }
        sk.keycode = res[0];
    }

    {
        auto res = convertCombinationSDLKeymodToEnumKeyboardModCode(cast(SDL_Keymod) e.keysym.mod);
        if (res[1]!is null)
        {
            return tuple(cast(EventKeyboard*) null, res[1]);
        }
        sk.modcode = res[0];
    }

    ret.keysym = sk;

    return tuple(ret, cast(Exception) null);
}

EventMouse* convertSDLMouseMotionEventToDtkEventMouse(SDL_MouseMotionEvent* e)
{
    EventMouse* ret = new EventMouse;

    ret.type = EventMouseType.movement;

    ret.mouseId = e.which;
    ret.movement.button = EnumMouseButton.none;
    if ((e.state && SDL_BUTTON_LEFT) != 0)
    {
        ret.movement.button |= EnumMouseButton.bl;
    }

    if ((e.state && SDL_BUTTON_RIGHT) != 0)
    {
        ret.movement.button |= EnumMouseButton.br;
    }

    if ((e.state && SDL_BUTTON_MIDDLE) != 0)
    {
        ret.movement.button |= EnumMouseButton.bm;
    }

    if ((e.state && SDL_BUTTON_X1) != 0)
    {
        ret.movement.button |= EnumMouseButton.b4;
    }

    if ((e.state && SDL_BUTTON_X2) != 0)
    {
        ret.movement.button |= EnumMouseButton.b5;
    }

    ret.x = e.x;
    ret.y = e.y;
    ret.movement.xr = e.xrel;
    ret.movement.yr = e.yrel;

    return ret;
}

EventMouse* convertSDLMouseButtonEventToDtkEventMouse(SDL_MouseButtonEvent* e)
{
    EventMouse* ret = new EventMouse;

    ret.type = EventMouseType.button;

    ret.button.button = EnumMouseButton.none;
    switch (e.button)
    {
    default:
        break;
    case SDL_BUTTON_LEFT:
        ret.button.button = EnumMouseButton.bl;
        break;
    case SDL_BUTTON_RIGHT:
        ret.button.button = EnumMouseButton.br;
        break;
    case SDL_BUTTON_MIDDLE:
        ret.button.button = EnumMouseButton.bm;
        break;
    case SDL_BUTTON_X1:
        ret.button.button = EnumMouseButton.b4;
        break;
    case SDL_BUTTON_X2:
        ret.button.button = EnumMouseButton.b5;
        break;
    }

    if (e.state == SDL_PRESSED)
    {
        ret.button.buttonState = EnumMouseButtonState.pressed;
    }
    else
    {
        ret.button.buttonState = EnumMouseButtonState.released;
    }

    // TODO: todo
    // Error: no property `clicks` for type `bindbc.sdl.bind.sdlevents.SDL_MouseButtonEvent*`
    ret.button.clicks = e.clicks;

    ret.x = e.x;
    ret.y = e.y;

    return ret;
}

EventMouse* convertSDLMouseWheelEventToDtkEventMouse(SDL_MouseWheelEvent* e)
{
    EventMouse* ret = new EventMouse;

    ret.type = EventMouseType.wheel;

    ret.x = e.x;
    ret.y = e.y;

    return ret;
}

EventTextInput* convertSDLTextInputEventToDtkEventTextInput(SDL_TextInputEvent* e)
{
    import std.conv;
    import std.string;

    EventTextInput* ret = new EventTextInput;

    ret.text = to!dstring(cast(string)(fromStringz(e.text)).idup);

    return ret;
}
