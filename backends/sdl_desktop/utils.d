module dtk.backends.sdl_desktop.utils;

import std.stdio;
import std.conv;
import std.typecons;

import bindbc.sdl;

import dtk.types.EnumWindowEvent;
import dtk.types.EnumKeyboardKeyState;
import dtk.types.KeySym;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.backends.sdl_desktop.sdlkeyconversion;

Event* convertSDLEventToEvent(SDL_Event* event)
{
    Event* ret = new Event();

    switch (event.type)
    {
    default:
        return null;
    case SDL_WINDOWEVENT:
        ret.ew = convertSDLWindowEventToDtkEventWindow(&event.window);
        ret.type = EventType.window;
        break;
    case SDL_KEYDOWN:
    case SDL_KEYUP:
        auto res = convertSDLKeyboardEventToDtkEventKeyboard(&event.key);
        if (res[1]!is null)
        {
            debug writeln("convertSDLKeyboardEventToDtkEventKeyboard error:", res[1]);
            return null;
        }
        ret.ek = res[0];
        ret.type = EventType.keyboard;
        break;
    case SDL_MOUSEMOTION:
        ret.em = convertSDLMouseMotionEventToDtkEventMouse(&event.motion);
        ret.type = EventType.mouse;
        break;
    case SDL_MOUSEBUTTONDOWN:
    case SDL_MOUSEBUTTONUP:
        ret.em = convertSDLMouseButtonEventToDtkEventMouse(&event.button);
        ret.type = EventType.mouse;
        break;
    case SDL_MOUSEWHEEL:
        ret.em = convertSDLMouseWheelEventToDtkEventMouse(&event.wheel);
        ret.type = EventType.mouse;
        break;
    case SDL_TEXTINPUT:
        ret.eti = convertSDLTextInputEventToDtkEventTextInput(&event.text);
        ret.type = EventType.textInput;
        writeln("convertSDLEventToEvent eti.text ", ret.eti.text);
        break;
    }

    return ret;
}

EventWindow* convertSDLWindowEventToDtkEventWindow(SDL_WindowEvent* e)
{
    EventWindow* ret = new EventWindow;
    switch (e.event)
    {
    default:
        break;
    case SDL_WINDOWEVENT_NONE:
        break;
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
    case SDL_WINDOWEVENT_SIZE_CHANGED:
        ret.eventId = EnumWindowEvent.sizeChanged;
        ret.size.width = e.data1;
        ret.size.height = e.data2;
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
        ret.keyState = EnumKeyboardKeyState.pressed;
        break;
    case SDL_RELEASED:
        ret.keyState = EnumKeyboardKeyState.released;
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
    ret.button = EnumMouseButton.none;
    if ((e.state && SDL_BUTTON_LEFT) != 0)
    {
        ret.button |= EnumMouseButton.bl;
    }

    if ((e.state && SDL_BUTTON_RIGHT) != 0)
    {
        ret.button |= EnumMouseButton.br;
    }

    if ((e.state && SDL_BUTTON_MIDDLE) != 0)
    {
        ret.button |= EnumMouseButton.bm;
    }

    if ((e.state && SDL_BUTTON_X1) != 0)
    {
        ret.button |= EnumMouseButton.b4;
    }

    if ((e.state && SDL_BUTTON_X2) != 0)
    {
        ret.button |= EnumMouseButton.b5;
    }

    ret.x = e.x;
    ret.y = e.y;
    /* ret.xr = e.xr;
    ret.yr = e.yr;
     */
    return ret;
}

EventMouse* convertSDLMouseButtonEventToDtkEventMouse(SDL_MouseButtonEvent* e)
{
    EventMouse* ret = new EventMouse;

    ret.type = EventMouseType.button;

    ret.button = EnumMouseButton.none;
    switch (e.button)
    {
    default:
        break;
    case SDL_BUTTON_LEFT:
        ret.button = EnumMouseButton.bl;
        break;
    case SDL_BUTTON_RIGHT:
        ret.button = EnumMouseButton.br;
        break;
    case SDL_BUTTON_MIDDLE:
        ret.button = EnumMouseButton.bm;
        break;
    case SDL_BUTTON_X1:
        ret.button = EnumMouseButton.b4;
        break;
    case SDL_BUTTON_X2:
        ret.button = EnumMouseButton.b5;
        break;
    }

    if (e.state == SDL_PRESSED)
    {
        ret.buttonState = EnumMouseButtonState.pressed;
    }
    else
    {
        ret.buttonState = EnumMouseButtonState.released;
    }

    // TODO: todo
    // Error: no property `clicks` for type `bindbc.sdl.bind.sdlevents.SDL_MouseButtonEvent*`
    ret.clicks = e.clicks;

    ret.x = e.x;
    ret.y = e.y;

    return ret;
}

EventMouse* convertSDLMouseWheelEventToDtkEventMouse(SDL_MouseWheelEvent* e)
{
    EventMouse* ret = new EventMouse;

    ret.type = EventMouseType.wheel;

    // TODO: fix this
    // ret.x = e.x;
    // ret.y = e.y;

    return ret;
}

EventTextInput* convertSDLTextInputEventToDtkEventTextInput(SDL_TextInputEvent* e)
{
    import std.conv;
    import std.string;
    import core.stdc.string;

    EventTextInput* ret = new EventTextInput;

    string new_str;

    foreach (v; e.text)
    {
        if (v == 0)
        {
            break;
        }
        new_str ~= v;
    }

    ret.text = to!dstring(new_str);

    return ret;
}
