module dtk.backends.glfw_desktop.Window;

import std.conv;
import std.string;
import std.typecons;
import std.stdio;
import std.algorithm;
import std.exception;

// static import bindbc.glfw;
// import bindbc.glfw : GLFW_Window = Window;

//GLFWwindow

import bindbc.glfw;

import erupted;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WindowDecorationI;

import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;

// import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.LaFI;

import dtk.backends.glfw_desktop.Platform;
// import dtk.backends.glfw_desktop.utils;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.WindowBorderSizes;
import dtk.types.ArtificalWDSpawner;

// import dtk.miscs.WindowEventMgr;
// import dtk.miscs.mixin_event_handler_reg;
import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.signal_tools;
import dtk.miscs.isPointInRegion;

import dtk.widgets.Form;
import dtk.widgets.Menu;

import dtk.prototypes.WindowPrototype001;

// import dtk.signal_mixins.Window;



class Window : WindowPrototype001
{

    // TODO: maybe this shouldn't be public
    public
    {
        GLFWwindow* glfw_window;
    }

    private
    {
        SignalConnection cs_PlatformChange;
        SignalConnection cs_FormChange;
        SignalConnection cs_PreferedArtificalWD;

        SignalConnection platform_signal_connection;
    }

    @disable this();

    this(WindowCreationSettings window_settings)
    {
        super(window_settings);

        // without this SDL makes fullscreen window;

        auto tt = to!string(window_settings.title);
        auto tt_c = tt.toStringz();

        debug writeln("glfwCreateWindow");
        // TODO: check x, y, w, h usage
        glfw_window = glfwCreateWindow(
            window_settings.w,
            window_settings.h,
            tt_c,
            null,
            null
            );
        if (glfw_window is null)
        {
            throw new Exception("window creation error");
        }

        setTitle(window_settings.title);

    }

    override WindowI setPlatformTitle(dstring value)
    {
        auto tt = to!string(value);
        auto tt_c = tt.toStringz();
        glfwSetWindowTitle(glfw_window, tt_c);
        return this;
    }

    override DrawingSurfaceI makePlatformDrawingSurface(WindowI win)
    {
        import dtk.DrawingSurface_collection.vulkan.DrawingSurface;
        return new DrawingSurface();
    }

    override void close()
    {
        super.close();
        glfwDestroyWindow(glfw_window);
    }

    override bool isPlatformBorderless()
    {
        return glfwGetWindowAttrib(glfw_window, GLFW_DECORATED) == GLFW_TRUE;
    }

    override WindowBorderSizes getPlatformBorderSizes()
    {
        WindowBorderSizes ret;
        glfwGetWindowFrameSize(
            glfw_window,
            &ret.leftTop.width, &ret.leftTop.height,
            &ret.rightBottom.width, &ret.rightBottom.height
            );
        // TODO: add error checking
        // if (res != 0)
        // {
        //     getPlatform().printPlatformError();
        //     debug writeln(
        //         "SDL failed to return window border sizes. " ~
        //         "forcing artifical decoration usage."
        //         );
        //     installArtificalWD();
        //     WindowBorderSizes empty_ret;
        //     return empty_ret;
        // }

        return ret;
    }

    override Position2D getPlatformPosition()
    {
        Position2D pos;
        // TODO: add error checking
        glfwGetWindowPos(this.glfw_window, &(pos.x), &(pos.y));
        return pos;
    }

    override Size2D getPlatformSize()
    {
        Size2D size;
        // TODO: add error checking
        glfwGetWindowSize(this.glfw_window, &(size.width), &(size.height));
        return size;
    }

    override WindowI setPlatformPosition(Position2D pos)
    {
        // TODO: add error checking
        glfwSetWindowPos(this.glfw_window, (pos.x), (pos.y));
        return this;
    }

    override WindowI setPlatformSize(Size2D size)
    {
        // TODO: add error checking
        glfwSetWindowSize(this.glfw_window, (size.width), (size.height));
        return this;
    }

}
