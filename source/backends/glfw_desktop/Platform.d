module dtk.backends.glfw_desktop.Platform;

import core.thread.osthread;

import std.typecons;
import std.format;
import std.stdio;
import std.algorithm;
import std.parallelism;

import bindbc.glfw;

import dtk.interfaces.LaFI;
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

import dtk.backends.glfw_desktop.Window;

import dtk.miscs.signal_tools;

import dtk.signal_mixins.Platform;


class Platform : PlatformPrototype001
{

    override string getName()
    {
        return "GLFW-Desktop";
    }

    override string getDescription()
    {
        return "GLFW Backend for DTK";
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
        glfwInit();
    }

    override void destroy()
    {
        // SDL_Quit();
    }

    WindowI convertWindowtoWindowI(Window win)
    {
        return cast(WindowI) win;
    }

    Window convertWindowItoWindow(WindowI win)
    {
        return cast(Window) win;
    }

    void addWindow(Window win)
    {
        auto res = convertWindowtoWindowI(win);

        addWindow(res);
    }

    void removeWindow(Window win)
    {
        auto res = convertWindowtoWindowI(win);

        removeWindow(res);
    }

    bool haveWindow(Window win)
    {
        auto res = convertWindowtoWindowI(win);

        return haveWindow(res);
    }

    Window getWindowByPointer(GLFWwindow* window_ptr)
    {
        Window ret;
        // foreach (WindowI w; getWindowIArray())
        foreach (WindowI w; windows)
        {
            auto w_w = cast(Window)w;

            if (!w_w)
                throw new Exception("can't cast WindowI to Window (of SDL backend)");

            if (w_w.glfw_window == window_ptr)
            {
                ret = w_w;
                break;
            }
        }
        return ret;
    }

    protected void cbGLFWwindowposfun (
        GLFWwindow *window, int xpos, int ypos
        )
    {
    }

    protected void cbGLFWwindowsizefun (
        GLFWwindow *window, int width, int height
        )
    {
    }

    protected void cbGLFWwindowclosefun (GLFWwindow *window)
    {
    }

    protected void cbGLFWwindowrefreshfun (GLFWwindow *window)
    {
    }

    protected void cbGLFWwindowfocusfun (
        GLFWwindow *window, int focused
        )
    {
    }

    protected void cbGLFWwindowiconifyfun (
        GLFWwindow *window, int iconified
        )
    {
    }

    protected void cbGLFWwindowmaximizefun (
        GLFWwindow *window, int maximized
        )
    {
    }

    protected void cbGLFWframebuffersizefun (
        GLFWwindow *window, int width, int height
        )
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

    override void mainLoop()
    {

    }

    override Tuple!(int, string) getPlatformError()
    {
        import std.string;
        const (char) *txt;
        int err;
        err = glfwGetError(&txt);
        string ret_str = cast(string)fromStringz(txt);
        return tuple(err, ret_str);
    }


}
