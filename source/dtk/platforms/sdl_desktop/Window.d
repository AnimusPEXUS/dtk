module dtk.platforms.sdl_desktop.Window;

import std.typecons;
import std.stdio;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;

import dtk.platforms.sdl_desktop.DrawingSurface;
import dtk.platforms.sdl_desktop.SDLDesktopPlatform;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.WindowCreationSettings;

class Window : WindowI
{
    private
    {
        SDLDesktopPlatform platform;

        SDL_Window* sdl_window;

        DrawingSurface drawing_surface;

        FormI form;

        Point point;
        Size size;

        Point form_point;
        Size form_size;

        string title;

        bool _minimized;
        bool _maximized;

        bool _visible;
    }

    uint sdl_window_id;

    @disable this();

    this(WindowCreationSettings window_settings, SDLDesktopPlatform platform)
    {
        this.platform = platform;
        this.title = window_settings.title;

        auto flags = cast(SDL_WindowFlags) 0 /* else flags init with FULLSCREEN option */ ;

        if (!window_settings.resizable.isNull() && window_settings.resizable.get())
            flags |= SDL_WINDOW_RESIZABLE;

        int x, y;
        if (!window_settings.position.isNull())
        {
            auto z = window_settings.position.get();
            x = z.x;
            y = z.y;
        }

        int w, h;
        if (!window_settings.size.isNull())
        {
            auto z = window_settings.size.get();
            w = z.width;
            h = z.height;
        }

        sdl_window = SDL_CreateWindow(cast(char*) window_settings.title, x, y, w, h, flags);
        if (sdl_window is null)
        {
            throw new Exception("window creation error");
        }

        sdl_window_id = SDL_GetWindowID(sdl_window);
        if (sdl_window_id == 0)
        {
            throw new Exception("error getting window id");
        }

        platform.registerWindow(this);
    }

    ~this()
    {
        platform.unregisterWindow(this);
    }

    void HandleWindowEvent(SDL_WindowEvent e)
    {
        writeln(e.event);
        switch (e.event)
        {
        default:
            writeln("   NOT HANDLED!");
            break;
        case SDL_WINDOWEVENT_NONE:
            break;

        case SDL_WINDOWEVENT_SHOWN:
            this._visible = true;
            break;

        case SDL_WINDOWEVENT_HIDDEN:
            this._visible = false;
            break;

        case SDL_WINDOWEVENT_EXPOSED:
            this.redraw();
            break;

        case SDL_WINDOWEVENT_MOVED:
            this.point.x = e.data1;
            this.point.y = e.data2;
            printParams();
            break;

        case SDL_WINDOWEVENT_RESIZED:
            this.size.width = e.data1;
            this.size.height = e.data2;
            this.redraw(); // TODO: remove here or here
            printParams();
            break;

        case SDL_WINDOWEVENT_SIZE_CHANGED:
            this.redraw(); // TODO: remove here or here
            break;

        case SDL_WINDOWEVENT_MINIMIZED:
            this._minimized = true;
            break;

        case SDL_WINDOWEVENT_MAXIMIZED:
            this._maximized = true;
            break;

        case SDL_WINDOWEVENT_RESTORED:
            // NOTE: I didn't get it: SDL logic is: window can't be semultaniously maximized and minimized?  -
            //       so it emits RESTORED on unminimization and on un maximization?
            this._minimized = true;
            break;

        case SDL_WINDOWEVENT_ENTER:
            break;

        case SDL_WINDOWEVENT_LEAVE:
            break;

        case SDL_WINDOWEVENT_FOCUS_GAINED:
            break;

        case SDL_WINDOWEVENT_FOCUS_LOST:
            break;

        case SDL_WINDOWEVENT_CLOSE:
            // TODO: catch this somehow and don't allow SDL to emit SDL_QUIT
            break;

            /* case SDL_WINDOWEVENT_TAKE_FOCUS:
            break;

        case SDL_WINDOWEVENT_HIT_TEST:
            break; */
        }
    }

    void redraw()
    {
        auto f = getForm();
        if (f is null)
        {
            writeln("form not attached");
            return;
        }

        f.redraw();
    }

    void printParams()
    {
        writeln(
                title , " : " , this.point.x , " " , this.point.y, " " , this.size.width , " " , this.size.height);
    }

    PlatformI getPlatform()
    {
        return platform;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        return drawing_surface;
    }

    void setForm(FormI form)
    {
        form = form;
    }

    FormI getForm()
    {
        return form;
    }

    Point getPoint()
    {
        return point;
    }

    Tuple!(bool, Point) setPoint(Point point)
    {
        this.point = point;
        return tuple(true, this.point);
    }

    Size getSize()
    {
        return size;
    }

    Tuple!(bool, Size) setSize(Size size)
    {
        this.size = size;
        return tuple(true, this.size);
    }

    Point getFormPoint()
    {
        return form_point;
    }

    Size getFormSize()
    {
        return form_size;
    }

    string getTitle()
    {
        return title;
    }

    void setTitle(string value)
    {
        title = value;
    }

}
