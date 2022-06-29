module dtk.backends.glfw_desktop.Platform;

import core.sync.mutex;

import std.typecons;

import bindbc.glfw;

import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;
import dtk.interfaces.LaFI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.MouseCursorMgrI;

import dtk.types.Event;
import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.WindowCreationSettings;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;
import dtk.types.EnumWindowDraggingEventEndReason;

import dtk.backends.glfw_desktop.Window;

import dtk.miscs.signal_tools;

import dtk.signal_mixins.Platform;



const auto PlatformProperties = cast(PropSetting[])[
    PropSetting("gsun", "FontMgrI", "font_mgr", "FontManager", "null"),
    PropSetting(
        "gsun", 
        "MouseCursorMgrI", 
        "mouse_cursor_mgr", 
        "MouseCursorManager", 
        "null"
    ),
];


class Platform : PlatformI
{

    mixin mixin_multiple_properties_define!(PlatformProperties);
    mixin mixin_multiple_properties_forward!(PlatformProperties, false);

    mixin(mixin_PlatformSignals(false));

    private
    {
        Window[] windows;

        bool stop_flag;

        // SDL_EventType timer500_event_id;

        __gshared PlatformEventSpool esp;
    }

    string getName()
    {
        return "GLFW-Desktop";
    }

    string getDescription()
    {
        return "GLFW Backend for DTK";
    }

    bool canCreateWindow()
    {
        return true;
    }

    bool getFormCanResizeWindow()
    {
        return true;
    }

    this()
    {
        mixin(mixin_multiple_properties_inst(PlatformProperties));
        esp = new PlatformEventSpool();

        glfwInit();
    }

    void destroy()
    {
        // SDL_Quit();
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

    private Window convertWindowItoGLFWWindow(WindowI win)
    {
        auto glfw_window = cast(Window) win;
        if (!glfw_window)
        {
            throw new Exception("not a GLFW Window object");
        }
        return glfw_window;
    }

    void addWindow(WindowI win)
    {
        auto glfw_window = convertWindowItoGLFWWindow(win);
        if (haveWindow(glfw_window))
            return;
        foreach (ref Window w; windows)
        {
            if (w == glfw_window)
                break;
        }
        windows ~= glfw_window;
        if (glfw_window.getPlatform() != this)
            glfw_window.setPlatform(this);
    }

    void removeWindow(WindowI win)
    {
        auto glfw_window = convertWindowItoGLFWWindow(win);
        if (!haveWindow(glfw_window))
            return;
        size_t[] indexes;
        foreach (size_t i, ref Window w; windows)
        {
            if (w == glfw_window)
                indexes ~= i;
        }

        foreach_reverse (size_t i; indexes)
        {
            windows = windows[0 .. i] ~ windows[i + 1 .. $];
        }

        glfw_window.unsetPlatform();
    }

    bool haveWindow(WindowI win)
    {
        auto glfw_window = convertWindowItoGLFWWindow(win);
        return haveWindow(glfw_window);
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

    bool haveWindow(GLFWwindow* glfw_window)
    {
        return getWindow(glfw_window) !is null;
    }

    Window getWindow(GLFWwindow* glfw_window)
    {
        foreach (Window w; windows)
        {
            if (w.glfw_window == glfw_window)
            {
                return w;
            }
        }
        return null;
    }

    protected void cbGLFWwindowposfun (Window *window, int xpos, int ypos)
    {
    }

    protected void cbGLFWwindowsizefun (Window *window, int width, int height)
    {
    }

    protected void cbGLFWwindowclosefun (Window *window)
    {
    }

    protected void cbGLFWwindowrefreshfun (Window *window)
    {
    }

    protected void cbGLFWwindowfocusfun (Window *window, int focused)
    {
    }

    protected void cbGLFWwindowiconifyfun (Window *window, int iconified)
    {
    }

    protected void cbGLFWwindowmaximizefun (Window *window, int maximized)
    {
    }

    protected void cbGLFWframebuffersizefun (Window *window, int width, int height)
    {
    }

    void timer500Loop()
    {
        //         import core.thread;
        //         import core.time;

        //         //    auto sleep_f = core.thread.osthread.Thread.getThis.sleep;
        //         const auto m500 = msecs(500);
        //         while (!stop_flag)
        //         {
        //             Thread.sleep(m500);
        //             // sleep_f(m500);
        //             auto e = new SDL_Event();
        //             e.user = SDL_UserEvent();
        //             e.user.type = timer500_event_id;
        //             SDL_PushEvent(e);
        //         }
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
                e.window = w;

                if (w && e.window) {
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
                        widgetInternalDraggingEventWidget.intInternalDraggingEvent(
                            widgetInternalDraggingEventWidget,
                            widgetInternalDraggingEventInitX,
                            widgetInternalDraggingEventInitY,
                            e.mouseX,
                            e.mouseY,
                            e.mouseX - widgetInternalDraggingEventInitX,
                            e.mouseY - widgetInternalDraggingEventInitY
                            );
                    }

                    continue main_loop;
                }

                if (windowDraggingEventActive)
                {
                    if (windowDraggingEventStopCheck is null)
                    {
                        debug writeln("error: windowDraggingEventStopCheck is null");
                        windowDraggingEventEnd(e, EnumWindowDraggingEventEndReason.abort);
                        continue main_loop;
                    }
                    if (windowDraggingEventWindow is null)
                    {
                        debug writeln("error: windowDraggingEventWindow is null");
                        windowDraggingEventEnd(e, EnumWindowDraggingEventEndReason.abort);
                        continue main_loop;
                    }
                    {
                        auto res_drag_stop_check = windowDraggingEventStopCheck(e);
                        debug writeln("res_drag_stop_check == %s".format(res_drag_stop_check));
                        if (res_drag_stop_check != EnumWindowDraggingEventEndReason.notEnd)
                        {
                            windowDraggingEventEnd(e, res_drag_stop_check);
                            continue main_loop;
                        }
                    }

                    if (e.type == EventType.mouse && e.em.type == EventMouseType.movement)
                    {
                        intWindowDraggingEvent(
                            // windowDraggingEventWindow,
                            // e.mouseX,
                            // e.mouseY,
                            // e.mouseX - windowDraggingEventInitX,
                            // e.mouseY - windowDraggingEventInitY
                            );
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
        EnumWidgetInternalDraggingEventEndReason
            delegate(Event* e) widgetInternalDraggingEventStopCheck;
        int widgetInternalDraggingEventInitX;
        int widgetInternalDraggingEventInitY;
    }

    void widgetInternalDraggingEventStart(
        Widget widget,
        int initX,
        int initY,
        EnumWidgetInternalDraggingEventEndReason
            delegate(Event* e) widgetInternalDraggingEventStopCheck
        )
    {
        assert(widget !is null);
        assert(widgetInternalDraggingEventStopCheck !is null);

        SDL_CaptureMouse(SDL_TRUE);

        widgetInternalDraggingEventInitX = initX;
        widgetInternalDraggingEventInitY = initY;

        widgetInternalDraggingEventWidget = widget;

        this.widgetInternalDraggingEventStopCheck =
            widgetInternalDraggingEventStopCheck;

        widgetInternalDraggingEventActive = true;

        assert(widgetInternalDraggingEventWidget !is null);
        assert(this.widgetInternalDraggingEventStopCheck !is null);

        widgetInternalDraggingEventWidget.intInternalDraggingEventStart(
                widgetInternalDraggingEventWidget,
                initX, initY
                );
    }

    void widgetInternalDraggingEventEnd(
        Event* e,
        EnumWidgetInternalDraggingEventEndReason reason
        )
    {
        debug writeln("widgetInternalDraggingEventEnd end");
        if (reason == EnumWidgetInternalDraggingEventEndReason.notEnd)
        {
            return;
        }

        SDL_CaptureMouse(SDL_FALSE);

        widgetInternalDraggingEventWidget.intInternalDraggingEventEnd(
                widgetInternalDraggingEventWidget,
                reason,
                widgetInternalDraggingEventInitX,
                widgetInternalDraggingEventInitY,
                e.mouseX,
                e.mouseY,
                e.mouseX - widgetInternalDraggingEventInitX,
                e.mouseY - widgetInternalDraggingEventInitY
                );

        widgetInternalDraggingEventActive = false;
        widgetInternalDraggingEventWidget = null;
        this.widgetInternalDraggingEventStopCheck = null;
        debug writeln("widgetInternalDraggingEventEnd end");
    }

    private
    {
        bool windowDraggingEventActive;

        Window windowDraggingEventWindow;

        EnumWindowDraggingEventEndReason
            delegate(Event* e) windowDraggingEventStopCheck;

        int windowDraggingEventInitX;
        int windowDraggingEventInitY;
        int windowDraggingEventCursorInitX;
        int windowDraggingEventCursorInitY;
    }

    void windowDraggingEventStart(
        WindowI window,
        EnumWindowDraggingEventEndReason
            delegate(Event* e) windowDraggingEventStopCheck
        )
    {
        SDL_CaptureMouse(SDL_TRUE);

        windowDraggingEventWindow = cast(Window)window;

        // TODO: work on result
        SDL_GetWindowPosition(
            windowDraggingEventWindow.sdl_window,
            &windowDraggingEventInitX,
            &windowDraggingEventInitY,
        );

        // TODO: work on result
        SDL_GetGlobalMouseState(
            &windowDraggingEventCursorInitX,
            &windowDraggingEventCursorInitY,
        );

        this.windowDraggingEventStopCheck = windowDraggingEventStopCheck;

        windowDraggingEventActive = true;

        assert(windowDraggingEventWindow !is null);
        assert(windowDraggingEventStopCheck !is null);
    }

    void windowDraggingEventEnd(
        Event* e,
        EnumWindowDraggingEventEndReason reason
        )
    {
        if (reason == EnumWindowDraggingEventEndReason.notEnd)
        {
            return;
        }

        SDL_CaptureMouse(SDL_FALSE);

        windowDraggingEventActive = false;
        windowDraggingEventWindow = null;
        windowDraggingEventStopCheck = null;
        debug writeln("windowDraggingEventEnd end");
    }

    void intWindowDraggingEvent(
        // WindowI window,
        //int initX,
        //int initY,
        // int x,
        // int y,
        // int relX,
        // int relY
        )
    {
        // TODO: todo
        int x;
        int y;

        SDL_GetGlobalMouseState(&x, &y);

        debug writeln("SDL_GetGlobalMouseState %sx%s".format(x, y));

        SDL_SetWindowPosition(
            windowDraggingEventWindow.sdl_window,
            windowDraggingEventInitX - (windowDraggingEventCursorInitX - x),
            windowDraggingEventInitY - (windowDraggingEventCursorInitY - y),
        );
    }

//     void windowDraggingEventWidgetStart(
//         WindowI window,
//         int initX,
//         int initY
//         )
//     {

//     }

    Tuple!(int, string) getGLFWError()
    {
        import std.string;
        const (char) *txt;
        int err;
        err = glfwGetError(&txt);
        string ret_str = cast(string)fromStringz(txt);
        return tuple(err, ret_str);
    }

    Tuple!(int, string) printGLFWError()
    {
        auto res = getGLFWError();
        return printGLFWError(res);
    }

    Tuple!(int, string) printGLFWError(Tuple!(int, string) input)
    {
        if (input[0] == 0)
        {
            writeln(
                "GLFW Error (0) Message: %s".format(
                    (input[1].length == 0 ? "No Error" : input[1])
                )
            );
        }
        else
        {
            writeln("GLFW Error (%s) Message: %s".format(input[0], input[1]));
        }
        return input;
    }


}
