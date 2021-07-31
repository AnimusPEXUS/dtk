module dtk.platforms.sdl_desktop.SDLDesktopPlatform;

import std.stdio;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;

import dtk.types.WindowCreationSettings;

import dtk.platforms.sdl_desktop.Window;
import dtk.platforms.sdl_desktop.utils;

class SDLDesktopPlatform : PlatformI
{

    private
    {
        bool exit;
        Window[] windows;
    }

    string getName()
    {
        return "SDL-Desktop";
    }

    string getDescription()
    {
        return "DTK (D ToolKit). on SDL Platform";
    }

    string getSystemTriplet()
    {
        return "x86_64-pc-linux-gnu"; // TODO: fix this
    }

    bool canCreateWindow()
    {
        return true;
    }

    WindowI createWindow(WindowCreationSettings window_settings)
    {
        return new Window(window_settings, this);
    }

    void registerWindow(Window win)
    {
        foreach (ref Window w; windows)
        {
            if (w == win)
                break;
        }
        windows ~= win;
    }

    void unregisterWindow(Window win)
    {
        size_t[] indexes;
        foreach (size_t i, ref Window w; windows)
        {
            if (w == win)
                indexes ~= i;
        }

        foreach_reverse (size_t i; indexes)
        {
            windows = windows[0 .. i] ~ windows[i + 1 .. $];
        }
    }

    bool getFormCanResizeWindow()
    {
        return true;
    }

    void init()
    {
        SDL_Init(SDL_INIT_VIDEO);
    }

    void destroy_()
    {
        SDL_Quit();
    }

    Window getWindowByWindowID(typeof (SDL_WindowEvent.windowID) windowID){
        Window ret;
        foreach (Window w; windows)
        {
            if (w._sdl_window_id == windowID)
            {
                ret =w ;
                break;
            }
        }
        if (ret is null)
        {
            throw new Exception("got event for unregistered window");
        }
        return ret;
    }

    void mainLoop()
    {
        SDL_Event *event = new SDL_Event;

        main_loop: while (true)
        {
            if (exit)
                break;

            auto res = SDL_WaitEvent(event);

            if (res == 0) // TODO: use GetError()
            {
                writeln("TODO: got error on SDL_WaitEvent");
                return;
            }

            // TODO: probably, at this point, things have to become asynchronous

            writeln(event.type);

        typeof (SDL_WindowEvent.windowID) windowID;

        event_type_switch:
            switch (event.type)
            {
            default:
                continue main_loop;
            case SDL_WINDOWEVENT:
                auto w = getWindowByWindowID(event.window.windowID);
                auto ew = convertSDLWindowEventToDtkEventWindow(event.window);
                w.handle_event_window(ew);
                continue main_loop;
            case SDL_KEYDOWN:
            case SDL_KEYUP:
                auto w = getWindowByWindowID(event.key.windowID);
                auto ek = convertSDLKeyboardEventToDtkEventKeyboard(event.key);
                w.handle_event_keyboard(ek);
                continue main_loop;
            case SDL_QUIT:
                break main_loop;
            }

        }

        return;
    }
}
