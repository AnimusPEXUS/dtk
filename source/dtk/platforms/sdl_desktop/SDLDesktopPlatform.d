module dtk.platforms.sdl_desktop.SDLDesktopPlatform;

import core.thread.osthread;

import std.format;
import std.stdio;
import std.algorithm;
import std.parallelism;

import fontconfig.fontconfig;
import bindbc.sdl;

import dtk.interfaces.LaFI;
import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;
import dtk.interfaces.FontMgrI;

import dtk.types.Event;
import dtk.types.Widget;
import dtk.types.Property;
import dtk.types.WindowCreationSettings;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;

import dtk.platforms.sdl_desktop.Window;
import dtk.platforms.sdl_desktop.utils;

import dtk.miscs.signal_tools;

// import dtk.miscs.WindowEventMgr;

import dtk.signal_mixins.Platform;

// TODO: ensure those events are not needed
immutable SDL_WindowEventID[] ignoredSDLWindowEvents = [
    SDL_WINDOWEVENT_NONE, SDL_WINDOWEVENT_SIZE_CHANGED,
    cast(SDL_WindowEventID) 15 //SDL_WINDOWEVENT_TAKE_FOCUS
];

const auto SDLDesktopPlatformProperties = cast(PropSetting[])[
    PropSetting("gsun", "FontMgrI", "font_mgr", "FontManager", "null"),
    // PropSetting("gsun", "LaFI", "laf", "Laf", "null"),
];

class SDLDesktopPlatform : PlatformI
{

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

    bool getFormCanResizeWindow()
    {
        return true;
    }

    mixin mixin_multiple_properties_define!(SDLDesktopPlatformProperties);
    mixin mixin_multiple_properties_forward!(SDLDesktopPlatformProperties, false);

    mixin(mixin_PlatformSignals(false));

    private
    {
        Window[] windows;

        bool stop_flag;

        SDL_EventType timer500_event_id;
    }

    void init() // TODO: check whatever this function name have special meaning in D
    {
        mixin(mixin_multiple_properties_inst(SDLDesktopPlatformProperties));

        SDL_Init(SDL_INIT_VIDEO);
        SDL_version v;
        SDL_GetVersion(&v);

        {
            timer500_event_id = cast(SDL_EventType) SDL_RegisterEvents(1);
            if (timer500_event_id == -1)
                throw new Exception("Couldn't register 500 ms timer event");

        }

        version (linux)
        {
            import dtk.platforms.sdl_desktop.FontMgrLinux;

            setFontManager(new FontMgrLinux());
            // font_mgr = cast(FontMgrI) ;
        }
        else
        {
            static assert(false, "Couldn't select Font Manager for platform");
        }
    }

    void destroy()
    {
        SDL_Quit();
    }

    WindowI createWindow(WindowCreationSettings window_settings)
    {
        auto w = new Window(window_settings);
        w.setPlatform(this);
        return w;
    }

    LaFI delegate() onGetLaf;

    void setOnGetLaf(LaFI delegate() cb)
    {
        onGetLaf = cb;
    }

    LaFI getLaf()
    {
        if (onGetLaf is null)
            throw new Exception("onGetLaf is not set");
        return onGetLaf();
    }

    private Window convertWindowItoSDLWindow(WindowI win)
    {
        auto sdl_window = cast(Window) win;
        if (sdl_window is null)
        {
            throw new Exception("not an SDL window");
        }
        return sdl_window;
    }

    void addWindow(WindowI win)
    {
        auto sdl_win = convertWindowItoSDLWindow(win);
        if (haveWindow(sdl_win))
            return;
        foreach (ref Window w; windows)
        {
            if (w == sdl_win)
                break;
        }
        windows ~= sdl_win;
        if (sdl_win.getPlatform() != this)
            sdl_win.setPlatform(this);
    }

    void removeWindow(WindowI win)
    {
        auto sdl_win = convertWindowItoSDLWindow(win);
        if (!haveWindow(sdl_win))
            return;
        size_t[] indexes;
        foreach (size_t i, ref Window w; windows)
        {
            if (w == sdl_win)
                indexes ~= i;
        }

        foreach_reverse (size_t i; indexes)
        {
            windows = windows[0 .. i] ~ windows[i + 1 .. $];
        }

        sdl_win.unsetPlatform();
    }

    bool haveWindow(WindowI win)
    {
        auto sdl_win = convertWindowItoSDLWindow(win);
        return haveWindow(sdl_win);
    }

    bool haveWindow(Window win)
    {
        foreach (ref Window w; windows)
        {
            if (w == win)
                return true;
        }
        return false;
    }

    Window getWindowByWindowID(typeof(SDL_WindowEvent.windowID) windowID)
    {
        Window ret;
        foreach (Window w; windows)
        {
            if (w.sdl_window_id == windowID)
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

    void mainLoop()
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
                    signal_timer500.emit();
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
                    break main_loop;
                }

                auto e = convertSDLEventToEvent(sdl_event);
                if (e is null)
                {
                    debug writeln("convertSDLEventToEvent returned null: ignoring");
                    continue main_loop;
                }
                e.window = w;

                {
                    if (e.type == EventType.mouse && e.em.type == EventMouseType.movement)
                    {
                        // TODO: save relative values too?
                        w.mouseX = e.em.x;
                        w.mouseY = e.em.y;
                    }

                    {
                        e.mouseX = w.mouseX;
                        e.mouseY = w.mouseY;
                    }
                }

                if (widgetInternalDraggingEventActive)
                {
                    if (widgetInternalDraggingEventStopCheck is null)
                    {
                        debug writeln("error: widgetInternalDraggingEventStopCheck is null");
                        widgetInternalDraggingEventEnd(e,
                                EnumWidgetInternalDraggingEventEndReason.abort);
                        continue main_loop;
                    }
                    if (widgetInternalDraggingEventWidget is null)
                    {
                        debug writeln("error: widgetInternalDraggingEventWidget is null");
                        widgetInternalDraggingEventEnd(e,
                                EnumWidgetInternalDraggingEventEndReason.abort);
                        continue main_loop;
                    }
                    {
                        auto res_drag_stop_check = widgetInternalDraggingEventStopCheck(e);
                        debug writeln("res_drag_stop_check == %s".format(res_drag_stop_check));
                        if (res_drag_stop_check != EnumWidgetInternalDraggingEventEndReason.notEnd)
                        {
                            widgetInternalDraggingEventEnd(e, res_drag_stop_check);
                            continue main_loop;
                        }
                    }

                    if (e.type == EventType.mouse && e.em.type == EventMouseType.movement)
                    {
                        widgetInternalDraggingEventWidget.intInternalDraggingEvent(widgetInternalDraggingEventWidget,
                                widgetInternalDraggingEventInitX,
                                widgetInternalDraggingEventInitY, e.mouseX,
                                e.mouseY, e.mouseX - widgetInternalDraggingEventInitX,
                                e.mouseY - widgetInternalDraggingEventInitY);
                    }

                    continue main_loop;
                }

                emitSignal_Event(e);
            }
        }

        return;
    }

    private
    {
        bool widgetInternalDraggingEventActive;
        Widget widgetInternalDraggingEventWidget;
        EnumWidgetInternalDraggingEventEndReason delegate(Event* e) widgetInternalDraggingEventStopCheck;
        int widgetInternalDraggingEventInitX;
        int widgetInternalDraggingEventInitY;
    }

    void widgetInternalDraggingEventStart(Widget widget, int initX, int initY,
            EnumWidgetInternalDraggingEventEndReason delegate(Event* e) widgetInternalDraggingEventStopCheck)
    {
        assert(widget !is null);
        assert(widgetInternalDraggingEventStopCheck !is null);

        SDL_CaptureMouse(SDL_TRUE);

        widgetInternalDraggingEventInitX = initX;
        widgetInternalDraggingEventInitY = initY;

        widgetInternalDraggingEventWidget = widget;

        this.widgetInternalDraggingEventStopCheck = widgetInternalDraggingEventStopCheck;

        widgetInternalDraggingEventActive = true;

        assert(widgetInternalDraggingEventWidget !is null);
        assert(this.widgetInternalDraggingEventStopCheck !is null);

        widgetInternalDraggingEventWidget.intInternalDraggingEventStart(
                widgetInternalDraggingEventWidget, initX, initY);
    }

    void widgetInternalDraggingEventEnd(Event* e, EnumWidgetInternalDraggingEventEndReason reason)
    {
        debug writeln("widgetInternalDraggingEventEnd start");
        if (reason == EnumWidgetInternalDraggingEventEndReason.notEnd)
        {
            return;
        }

        SDL_CaptureMouse(SDL_FALSE);

        widgetInternalDraggingEventWidget.intInternalDraggingEventEnd(
                widgetInternalDraggingEventWidget, reason, widgetInternalDraggingEventInitX,
                widgetInternalDraggingEventInitY,
                e.mouseX, e.mouseY, e.mouseX - widgetInternalDraggingEventInitX,
                e.mouseY - widgetInternalDraggingEventInitY);

        widgetInternalDraggingEventActive = false;
        widgetInternalDraggingEventWidget = null;
        this.widgetInternalDraggingEventStopCheck = null;
        debug writeln("widgetInternalDraggingEventEnd end");
    }

    string getSDLError()
    {
        import std.string;
        const (char) *err = SDL_GetError();
        string ret = cast(string)fromStringz(err);
        return ret;
    }

    void printSDLError()
    {
        writeln("SDL Error Message: %s".format(getSDLError()));
    }

}
