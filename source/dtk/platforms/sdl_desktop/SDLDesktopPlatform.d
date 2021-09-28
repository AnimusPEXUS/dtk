module dtk.platforms.sdl_desktop.SDLDesktopPlatform;

import std.stdio;
import std.algorithm;

import bindbc.sdl;

import dtk.interfaces.LafI;
import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;
import dtk.interfaces.FontMgrI;

import dtk.types.WindowCreationSettings;

import dtk.platforms.sdl_desktop.Window;
import dtk.platforms.sdl_desktop.utils;

import dtk.miscs.WindowEventMgr;

// TODO: ensure those events are not needed
immutable SDL_WindowEventID[] ignoredSDLWindowEvents = [
    SDL_WINDOWEVENT_NONE, SDL_WINDOWEVENT_SIZE_CHANGED,
    cast(SDL_WindowEventID) 15 //SDL_WINDOWEVENT_TAKE_FOCUS
];

class SDLDesktopPlatform : PlatformI
{

    private
    {
        bool exit;
        Window[] windows;
        LafI laf;
        FontMgrI font_mgr;
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
        auto w = new Window(window_settings, this);
        return w;
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
        SDL_version v;
        SDL_GetVersion(&v);
        writeln("SDL Version: ", v.major, ".", v.minor, ".", v.patch);
        version (linux)
        {
            pragma(msg, "using freetype font manager");
            import dtk.platforms.sdl_desktop.FontMgrLinux;

            font_mgr = cast(FontMgrI) new FontMgrLinux;
        }
        else
        {
            pragma(msg, "Font Manager error");
            static assert(false, "Couldn't select Font Manager for platform");
        }
    }

    void destroy()
    {
        SDL_Quit();
    }

    FontMgrI getFontManager()
    {
        return font_mgr;
    }

    Window getWindowByWindowID(typeof(SDL_WindowEvent.windowID) windowID)
    {
        Window ret;
        foreach (Window w; windows)
        {
            if (w._sdl_window_id == windowID)
            {
                ret = w;
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
        SDL_Event* event = new SDL_Event;

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

            typeof(SDL_WindowEvent.windowID) windowID;

        event_type_switch:
            switch (event.type)
            {
            default:
                continue main_loop;
            case SDL_WINDOWEVENT:
                windowID = event.window.windowID;
                if (ignoredSDLWindowEvents.canFind(event.window.event))
                {
                    writeln("warning: ignored SDL_WINDOWEVENT::", event.window.event, " just now");
                    continue main_loop;
                }
                break;
            case SDL_KEYDOWN:
            case SDL_KEYUP:
                windowID = event.key.windowID;
                break;
            case SDL_MOUSEMOTION:
                windowID = event.motion.windowID;
                break;
            case SDL_MOUSEBUTTONDOWN:
            case SDL_MOUSEBUTTONUP:
                windowID = event.button.windowID;
                break;
            case SDL_MOUSEWHEEL:
                windowID = event.wheel.windowID;
                break;
            case SDL_TEXTINPUT:
                windowID = event.text.windowID;
                break;
            case SDL_QUIT:
                break main_loop;
            }

            auto w = getWindowByWindowID(event.window.windowID);

            // NOTE: window have to recieve all events, because not all
            // platforms have same set of events, and so, Window may be required
            // to emitate event emission in some curcumstances based on it's
            // current state.
            w.handle_SDL_Event(event);
        }

        return;
    }

    LafI getLaf()
    {
        return laf;
    }

    void setLaf(LafI t)
    {
        laf = t;
    }

    void unsetLaf()
    {
        laf = null;
    }
}
