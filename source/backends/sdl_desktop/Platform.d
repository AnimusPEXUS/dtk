module dtk.backends.sdl_desktop.Platform;

import core.thread.osthread;

import std.typecons;
import std.format;
import std.stdio;
import std.algorithm;
import std.parallelism;

// import fontconfig.fontconfig;
import bindbc.sdl;

import dtk.interfaces.LaFI;
//import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.MouseCursorMgrI;

import dtk.types.EventWindow;
import dtk.types.Position2D;
import dtk.types.Event;
import dtk.types.Widget;
import dtk.types.Property;
import dtk.types.WindowCreationSettings;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;
import dtk.types.EnumWindowDraggingEventEndReason;

import dtk.prototypes.PlatformPrototype001;

import dtk.backends.sdl_desktop.CursorMgr;
import dtk.backends.sdl_desktop.Window;
import dtk.backends.sdl_desktop.utils;

import dtk.miscs.signal_tools;

import dtk.signal_mixins.Platform;

// TODO: ensure those events are not needed
immutable SDL_WindowEventID[] ignoredSDLWindowEvents = [
    SDL_WINDOWEVENT_NONE, SDL_WINDOWEVENT_SIZE_CHANGED,
    cast(SDL_WindowEventID) 15 //SDL_WINDOWEVENT_TAKE_FOCUS
];

// const auto PlatformProperties = cast(PropSetting[])[
//     PropSetting("gsun", "FontMgrI", "font_mgr", "FontManager", "null"),
//     PropSetting("gsun", "MouseCursorMgrI", "mouse_cursor_mgr", "MouseCursorManager", "null"),
// ];

class Platform : PlatformPrototype001
{

    private
    {
        SDL_EventType timer500_event_id;
    }

    override string getName()
    {
        return "SDL-Desktop";
    }

    override string getDescription()
    {
        return "DTK (D ToolKit). on SDL Platform";
    }

    override bool canCreateWindow()
    {
        return true;
    }

    override bool getFormCanResizeWindow()
    {
        return true;
    }

    alias addWindow = PlatformPrototype001.addWindow;
    alias removeWindow = PlatformPrototype001.removeWindow;
    alias haveWindow = PlatformPrototype001.haveWindow;

    this()
    {
        super();

        {
            timer500_event_id = cast(SDL_EventType) SDL_RegisterEvents(1);
            if (timer500_event_id == -1)
                throw new Exception("Couldn't register 500 ms timer event");
        }

        version (linux)
        {
            import dtk.fontMGRs.fcft.FontConfigFreeTypeLinux;

            setFontManager(new FontConfigFreeTypeLinux());
            // font_mgr = cast(FontMgrI) ;
        }
        else
        {
            static assert(false, "Couldn't select Font Manager for platform");
        }

        setMouseCursorManager(new CursorMgr(this));

        SDL_Init(SDL_INIT_VIDEO);
    }

    override void destroy()
    {
        SDL_Quit();
    }

    override WindowI createWindow(WindowCreationSettings window_settings)
    {
        auto w = new Window(window_settings);
        w.setPlatform(this);
        return w;
    }

    WindowI convertSDLWindowtoWindowI(Window win)
    {
        return cast(WindowI) win;
    }

    Window convertWindowItoSDLWindow(WindowI win)
    {
        return cast(Window) win;
    }

    void addWindow(Window win)
    {
        auto res = convertSDLWindowtoWindowI(win);

        super.addWindow(res);
    }

    void removeWindow(Window win)
    {
        auto res = convertSDLWindowtoWindowI(win);

        super.removeWindow(res);
    }

    bool haveWindow(Window win)
    {
        auto res = convertSDLWindowtoWindowI(win);

        return super.haveWindow(res);
    }

    Window getWindowByWindowID(typeof(SDL_WindowEvent.windowID) windowID)
    {
        Window ret;
        // foreach (WindowI w; getWindowIArray())
        foreach (WindowI w; windows)
        {
            auto w_w = cast(Window)w;

            if (!w_w)
                throw new Exception("can't cast WindowI to Window (of SDL backend)");

            if (w_w.sdl_window_id == windowID)
            {
                ret = w_w;
                break;
            }
        }
        return ret;
    }

    void timer500Loop()
    {
        import core.thread;
        import core.time;

        //    	auto sleep_f = core.thread.osthread.Thread.getThis.sleep;
        const auto m500 = msecs(500);
        while (!stop_flag)
        {
            Thread.sleep(m500);
            // sleep_f(m500);
            auto e = new SDL_Event();
            e.user = SDL_UserEvent();
            e.user.type = timer500_event_id;
            SDL_PushEvent(e);
        }
    }

    override void mainLoop()
    {
        import std.parallelism;

        ulong main_thread_id = core.thread.osthread.Thread.getThis().id;

        SDL_Event* sdl_event = new SDL_Event;

        auto timer500 = task(&timer500Loop);
        timer500.executeInNewThread();
        scope (exit)
        {
            debug writeln("mainLoop exiting.. waiting for threads exit");
            stop_flag = true;
            timer500.workForce();
            debug writeln("mainLoop exited.");
        }

        main_loop: while (!stop_flag)
        {
            debug writeln("---------------------------- new iteration");
            auto res = SDL_WaitEvent(sdl_event);

            if (res == 0) // TODO: use GetError()
            {
                throw new Exception("got error on SDL_WaitEvent");
            }

            if (core.thread.osthread.Thread.getThis().id != main_thread_id)
            {
                throw new Exception("SDL_WaitEvent exited into invalid thread");
            }

            // TODO: probably, at this point, things have to become asynchronous
            //       in environments which supports this

            if (sdl_event.type == SDL_USEREVENT)
            {
                if (cast(SDL_EventType) sdl_event.user.type == timer500_event_id)
                {
                    emitSignal_Timer500();
                }
            }
            else
            {
                // typeof(SDL_WindowEvent.windowID) windowID;
                Window w;

            event_type_switch:
                switch (sdl_event.type)
                {
                default:
                    debug writeln("unsupported sdl_event: ", sdl_event.type);
                    continue main_loop;
                case SDL_WINDOWEVENT:
                    w = getWindowByWindowID(sdl_event.window.windowID);
                    if (ignoredSDLWindowEvents.canFind(sdl_event.window.event))
                    {
                        continue main_loop;
                    }
                    break;
                case SDL_KEYDOWN:
                case SDL_KEYUP:
                    w = getWindowByWindowID(sdl_event.key.windowID);
                    break;
                case SDL_MOUSEMOTION:
                    w = getWindowByWindowID(sdl_event.motion.windowID);
                    break;
                case SDL_MOUSEBUTTONDOWN:
                case SDL_MOUSEBUTTONUP:
                    w = getWindowByWindowID(sdl_event.button.windowID);
                    break;
                case SDL_MOUSEWHEEL:
                    w = getWindowByWindowID(sdl_event.wheel.windowID);
                    break;
                case SDL_TEXTINPUT:
                    w = getWindowByWindowID(sdl_event.text.windowID);
                    break;
                case SDL_QUIT:
                    stop_flag = true;
                    break main_loop;
                }

                if (!w)
                {
                    debug writeln("got event for unregistered window");
                    // continue main_loop;
                }

                auto e = convertSDLEventToEvent(sdl_event);
                if (e is null)
                {
                    debug writeln("convertSDLEventToEvent returned null: ignoring");
                    continue main_loop;
                }

                consumeEvent(e);
            }
        }

        stop_flag = true;

        return;
    }

    override void beforeWidgetInternalDraggingEventStart()
    {
        SDL_CaptureMouse(SDL_TRUE);
    }

    override void beforeWidgetInternalDraggingEventEnd()
    {
        SDL_CaptureMouse(SDL_FALSE);
    }

    override void beforeWindowDraggingEventStart()
    {
        SDL_CaptureMouse(SDL_TRUE);
    }

    override void beforeWindowDraggingEventEnd()
    {
        SDL_CaptureMouse(SDL_FALSE);
    }

    override Tuple!(int, string) getPlatformError()
    {
        import std.string;
        const (char) *err = SDL_GetError();
        string ret = cast(string)fromStringz(err);
        return tuple(cast(int) err, ret);
    }

    override Position2D getMouseCursorPosition()
    {
        Position2D ret;
        SDL_GetMouseState(&ret.x, &ret.y);
        return ret;
    }


}
