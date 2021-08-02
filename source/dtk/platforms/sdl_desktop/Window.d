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
import dtk.platforms.sdl_desktop.utils;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.WindowCreationSettings;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.miscs.KeyboardProcessor;

class Window : WindowI
{
    private
    {
        SDLDesktopPlatform _platform;

        DrawingSurface _drawing_surface;

        FormI _form;

        Point _point;
        Size _size;

        Point _form_point;
        Size _form_size;

        string _title;

        bool _minimized;
        bool _maximized;

        bool _visible;

        KeyboardProcessor _kbp;

        /* void delegate(EventWindow event) eventWindowCB;
        void delegate(EventKeyboard event) eventKeyboardCB;
        void delegate(EventMouse event) eventMouseCB; */
    }

    SDL_Window* _sdl_window;

    typeof (SDL_WindowEvent.windowID) _sdl_window_id;

    @disable this();

    this(WindowCreationSettings window_settings, SDLDesktopPlatform platform)
    {
        _platform = platform;
        _title = window_settings.title;

        if (!window_settings.size.isNull())
        {
            this._size = window_settings.size.get();
        }

        _kbp = new KeyboardProcessor;
        _drawing_surface = new DrawingSurface(this);

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

        _sdl_window = SDL_CreateWindow(cast(char*) window_settings.title, x, y, w, h, flags);
        if (_sdl_window is null)
        {
            throw new Exception("window creation error");
        }

        _sdl_window_id = SDL_GetWindowID(_sdl_window);
        if (_sdl_window_id == 0)
        {
            throw new Exception("error getting window id");
        }

        platform.registerWindow(this);
    }

    ~this()
    {
        _platform.unregisterWindow(this);
    }

    void handle_SDL_Event(SDL_Event* event) {
        writeln("Window::handle_SDL_Event");

        switch (event.type)
        {
        default:
            return;
        case SDL_WINDOWEVENT:
            handle_SDL_WindowEvent(&event.window);
            break;
        case SDL_KEYDOWN:
        case SDL_KEYUP:
            handle_SDL_WindowKeyboard(&event.key);
            break;
        }

    }

    void handle_SDL_WindowEvent(SDL_WindowEvent* event) {
        writeln("Window::handle_SDL_WindowEvent");
        // TODO: ensure event consistency
        auto res = convertSDLWindowEventToDtkEventWindow(event);
        handle_event_window(res);
    }

    void handle_SDL_WindowKeyboard(SDL_KeyboardEvent *event)
    {
        writeln("Window::handle_SDL_WindowKeyboard");
        // TODO: ensure event consistency
        auto res = convertSDLKeyboardEventToDtkEventKeyboard(event);
        handle_event_keyboard(res);
    }

    void handle_event_window(EventWindow* e) {
        writeln("Window::handle_event_window");
    }

    void handle_event_keyboard(EventKeyboard* e) {
        writeln("Window::handle_event_keyboard");
    }

    void handle_event_mouse(EventMouse* e) {
        writeln("Window::handle_event_mouse");
    }

    void handle_event_textinput(EventTextInput* e)
    {
        writeln("Window::handle_event_textinput");
    }

    void redraw()
    {
        writeln("Window redraw() i called 111");
        /* auto f = getForm();
        if (f is null)
        {
            writeln("form not attached");
            return;
        }

        f.redraw(); */
    }

    void printParams()
    {
        writeln(_title, " : ", this._point.x, " ", this._point.y, " ",
                this._size.width, " ", this._size.height);
    }

    PlatformI getPlatform()
    {
        return _platform;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        return _drawing_surface;
    }

    void installForm(FormI form)
    {
        assert(form !is null);

        uninstallForm();

        setForm(form);
        auto x = getForm();
        assert(x !is null);
        x.setWindow(this);
    }

    void uninstallForm()
    {
        auto x = getForm();
        if (x !is null)
            x.unsetWindow();
        this.unsetForm();
    }

    void setForm(FormI form)
    {
        this._form = form;
    }

    void unsetForm()
    {
        this._form = null;
    }

    FormI getForm()
    {
        return _form;
    }

    Point getPoint()
    {
        return _point;
    }

    Tuple!(bool, Point) setPoint(Point point)
    {
        this._point = point;
        return tuple(true, this._point);
    }

    Size getSize()
    {
        return _size;
    }

    Tuple!(bool, Size) setSize(Size size)
    {
        this._size = size;
        return tuple(true, this._size);
    }

    Point getFormPoint()
    {
        return _form_point;
    }

    Size getFormSize()
    {
        return _form_size;
    }

    string getTitle()
    {
        return _title;
    }

    void setTitle(string value)
    {
        _title = value;
    }

    /* void setWindowEventCB(void delegate(EventWindow event) cb)
    {
        eventWindowCB = cb;
    }

    void unsetWindowEventCB(){
        eventWindowCB = null;
    }

    void setKeyboardEventCB(void delegate(EventKeyboard event) cb)
    {
        eventKeyboardCB = cb;
    }

    void unsetKeyboardEventCB()
    {
        eventKeyboardCB = null;
    }

    void setMouseEventCB(void delegate(EventMouse event) cb)
    {
        eventMouseCB = cb;
    }

    void unsetMouseEventCB()
    {
        eventMouseCB = null;
    } */


}
