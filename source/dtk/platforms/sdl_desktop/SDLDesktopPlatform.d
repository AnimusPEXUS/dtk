module dtk.platforms.sdl_desktop.SDLDesktopPlatform;

import std.stdio;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;

import dtk.types.WindowCreationSettings;

import dtk.platforms.sdl_desktop.Window;

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

    void mainLoop()
    {
        SDL_Event event;

        main_loop: while (true)
        {
            if (exit)
                break;

            auto res = SDL_WaitEvent(&event);

            if (res == 0) // TODO: use GetError()
            {
                writeln("TODO: got error on SDL_WaitEvent");
                return;
            }

            writeln(event.type);

        event_type_switch:
            switch (event.type)
            {
            default:
                break;
            case SDL_WINDOWEVENT:
                auto window_event = event.window;
                foreach (ref Window w; windows)
                {
                    if (w.sdl_window_id == window_event.windowID)
                    {
                        w.HandleWindowEvent(window_event);
                        break event_type_switch;
                    }
                }
                throw new Exception("got event for unregistered window");
                /* break; */
            case SDL_QUIT:
                break main_loop;
            }

        }

        return;
    }
}
