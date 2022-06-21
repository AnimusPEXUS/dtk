module dtk.backends.sdl_desktop.Window;

import std.conv;
import std.string;
import std.typecons;
import std.stdio;
import std.algorithm;
import std.exception;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;

// import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;

// import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.LaFI;

import dtk.backends.sdl_desktop.DrawingSurface;
import dtk.backends.sdl_desktop.Platform;
import dtk.backends.sdl_desktop.utils;

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

// import dtk.miscs.WindowEventMgr;
// import dtk.miscs.mixin_event_handler_reg;
import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.signal_tools;
import dtk.miscs.isPointInRegion;

import dtk.widgets.Form;
import dtk.widgets.Menu;

import dtk.wm.WindowDecoration;

// import dtk.signal_mixins.Window;

const auto WindowProperties = cast(PropSetting[])[
    PropSetting("gsun", "Platform", "platform", "Platform", "null"),
    PropSetting("gsun", "Form", "form", "Form", "null"),
    PropSetting("gsun", "WindowDecoration", "artificalWD", "ArtificalWD", "null"),
    PropSetting("gsun", "LaFI", "forced_laf", "ForcedLaf", "null"),
    // PropSetting("gsun", "WindowEventMgrI", "emgr", "WindowEventMgr", "null"),
    PropSetting("gsun", "DrawingSurfaceI", "drawing_surface", "DrawingSurface", "null"),

    PropSetting("gs_w_d", "dstring", "title", "Title", q{""d}),
];

class Window : WindowI
{

    // TODO: maybe this shouldn't be public
    public
    {
        SDL_Window* sdl_window;
        typeof(SDL_WindowEvent.windowID) sdl_window_id;

        dstring debug_name;

        bool mouseIn;
        int mouseX;
        int mouseY;
    }

    private
    {
        SignalConnection cs_PlatformChange;
        SignalConnection cs_FormChange;
        SignalConnection cs_ArtificalWDChange;

        SignalConnection platform_signal_connection;
    }

    mixin mixin_multiple_properties_define!(WindowProperties);
    mixin mixin_multiple_properties_forward!(WindowProperties, false);

    @disable this();

    this(WindowCreationSettings window_settings)
    {
        mixin(mixin_multiple_properties_inst(WindowProperties));


        setDrawingSurface(new DrawingSurface(this));

        // without this SDL makes fullscreen window;
        auto flags = cast(SDL_WindowFlags) 0;

        if (!window_settings.resizable.isNull() && window_settings.resizable.get())
        {
            flags |= SDL_WINDOW_RESIZABLE;
        }

        if (!window_settings.popup_menu.isNull() && window_settings.popup_menu.get())
        {
            flags |= SDL_WINDOW_POPUP_MENU;
        }

        string tt = to!string(window_settings.title);

        sdl_window = SDL_CreateWindow(
            "DTK app window temporary title",
            window_settings.x.get(),
            window_settings.y.get(),
            window_settings.width.get(),
            window_settings.height.get(),
            flags
            );
        if (sdl_window is null)
        {
            throw new Exception("window creation error");
        }

        setTitle(window_settings.title);

        {
            SDL_CreateRenderer(sdl_window, -1, SDL_RENDERER_SOFTWARE);

            // SDL_CreateRenderer(sdl_window, -1, SDL_RENDERER_ACCELERATED);

            // SDL_CreateRenderer(
            // sdl_window,
            // -1,
            // SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
            // );

            // TODO: add SDL info print on debug build?
            // auto r = SDL_GetRenderer(sdl_window);
            // SDL_RendererInfo ri;
            // SDL_GetRendererInfo(r, &ri);
        }

        sdl_window_id = SDL_GetWindowID(sdl_window);
        if (sdl_window_id == 0)
        {
            throw new Exception("error getting SDL window id");
        }

        // setWindowEventMgr(new WindowEventMgr(this));

        cs_PlatformChange = connectToPlatform_onAfterChanged(
                delegate void(
                    Platform old_value,
                    Platform new_value
                    ) {
            collectException({
                if (old_value == new_value)
                    return;

                platform_signal_connection.disconnect();

                if (old_value !is null)
                    old_value.removeWindow(this);

                if (new_value !is null)
                {
                    if (!new_value.haveWindow(this))
                        new_value.addWindow(this);
                    platform_signal_connection = new_value.connectToSignal_Event(
                        &onPlatformEvent
                        );
                }
            }());
        });

        cs_FormChange = connectToForm_onAfterChanged(
            delegate void(Form old_value, Form new_value) {
            collectException({
                if (old_value == new_value)
                    return;

                if (old_value !is null)
                    old_value.unsetWindow();

                if (new_value !is null && new_value.getWindow() != this)
                    new_value.setWindow(this);
            }());
        });

        cs_ArtificalWDChange = connectToForm_onAfterChanged(
            delegate void(Form old_value, Form new_value) {
            collectException({
                if (old_value == new_value)
                    return;

                if (old_value !is null)
                    if (old_value.getWindow() == this)
                        old_value.unsetWindow();

                if (new_value !is null && new_value.getWindow() != this)
                    new_value.setWindow(this);
            }());
        });

        // installArtificalWD();
    }

    Window setDebugName(dstring value)
    {
        debug_name = value;
        return this;
    }

    DrawingSurfaceI getFormDrawingSurface()
    {
        auto ds = getDrawingSurface();
        if (!ds)
            return null;
        if (isSetArtificalWD())
        {
            auto bs = getArtificalWD().getBorderSizes();
            ds = new DrawingSurfaceShift(
                ds,
                bs.leftTop.width,
                bs.leftTop.height
                );
        }
        return ds;
    }

    /* private void windowSyncPosition(bool externalStronger)
    {
        auto pos = getFormPosition();

        Position2D fpos = Position2D(getFormX(), getFormY());

        bool changed_x = (pos.x != fpos.x);
        bool changed_y = (pos.y != fpos.y);

        if (externalStronger)
        {
            if (changed_x)
                setFormX(pos.x);
            if (changed_y)
                setFormY(pos.y);
        }
        else
            setFormPosition(fpos);
    }

    private void windowSyncSize(bool externalStronger)
    {
        auto size = getFormSize();

        Size2D fsize = Size2D(getFormWidth(), getFormHeight());

        bool changed_w = (size.width != fsize.width);
        bool changed_h = (size.height != fsize.height);

        if (externalStronger)
        {
            if (changed_w)
                setFormWidth(size.width);
            if (changed_h)
                setFormHeight(size.height);
        }
        else
            setFormSize(fsize);
    } */

    LaFI getLaf()
    {
        auto l = getForcedLaf();
        if (l !is null)
            return l;
        auto p = getPlatform();
        if (p is null)
        {
            throw new Exception("getLaf(): both ForcedLaf and Platform is not set");
        }
        l = p.getLaf();
        if (l is null)
        {
            throw new Exception("Platform returned null Laf");
        }
        return l;
    }

    // calculate if current system sizing functions include border size
    // NOTE: this function is incorrect as sdl sizes are allways related to
    //       form XY
    /* private bool sdlWindowSizesIncludesBorderSizes()
    {
        if (isSDLBorderless())
            return false;
        SDL_SysWMinfo wminfo;
        SDL_VERSION(&wminfo.version_);
        SDL_bool res = SDL_GetWindowWMInfo(sdl_window, &wminfo);
        if (res != SDL_TRUE)
        {
            getPlatform().printSDLError();
            throw new Exception("SDL Error");
        }
        switch (wminfo.subsystem)
        {
        default:
        case SDL_SYSWM_X11:
            return true;
        case SDL_SYSWM_WAYLAND:
            // TODO: SDL having problems with this, so this result maybe invalid
            return true;
        }
    } */

    void onPlatformEvent(Event* event) nothrow
    {
        auto exc = collectException(
            {
                if (event.window != this)
                    return;

                if (event.type == EventType.none)
                {
                    debug writeln("event.type == EventType.none");
                    return;
                }

                if (event.type == EventType.window)
                {
                    debug writeln("window \"%s\" got event %s".format(debug_name, event.ew.eventId));

                    switch (event.ew.eventId)
                    {
                    default:
                        break;
                    case EnumWindowEvent.show:
                    case EnumWindowEvent.expose:
                        formDesiredPosSizeChanged();
                        {
                            /* auto exc = collectException(
                                {
                                    redraw();
                                }()
                                );
                            debug if (exc)
                            {
                                writeln("collected exception: ", exc);
                            } */
                        }

                        break;
                    case EnumWindowEvent.unFocus:

                        auto f = getForm();
                        if (!f)
                            break;

                        auto fc = f.getMainWidget();
                        if (!fc)
                            break;

                        auto m = cast(Menu) fc;
                        if (!m)
                            break;

                        if (m.getMode() == MenuMode.popup)
                        {
                            close();
                        }
                        break;
                    case EnumWindowEvent.close:
                        debug writeln("close signal");
                        close();

                    }

                    debug writeln("before sendWindowEventToForm");
                    sendWindowEventToForm(event);

                }
                else
                {
                    debug writeln("before sendNonWindowEventToForm/sendNonWindowEventToArtificalWD");
                    auto pos = Position2D(event.mouseX, event.mouseY);
                    if (isPositionInForm(pos))
                    {
                        if (isSetArtificalWD())
                        {
                            auto bs = getArtificalWD.getBorderSizes();
                            pos = pos.add(Position2D(bs.leftTop.width, bs.leftTop.height));
                        }
                        event.mouseX = pos.x;
                        event.mouseY = pos.y;
                        if (event.type == EventType.mouse)
                        {
                            event.em.x = event.mouseX;
                            event.em.y = event.mouseY;
                        }
                        sendNonWindowEventToForm(event);
                    }
                    else
                        sendNonWindowEventToArtificalWD(event);
                }
        }());
        if (exc)
        {
            collectException({
                debug writeln("onPlatformEvent : exception : %s".format(exc));
                }());
        }
        return;
    }

    private bool isPositionInForm(Position2D pos)
    {
        if (!isSetArtificalWD())
        {
            return true;
        }
        else
        {
            WindowBorderSizes bs;

            bs = getArtificalWD().getBorderSizes();

            auto window_size = getFormSize();

            window_size = window_size.sub(
                bs.leftTop.add(
                    bs.rightBottom
                    )
                );

            auto ret = isPointInRegion(
                Position2D(bs.leftTop.width, bs.leftTop.height),
                window_size,
                pos
                );

            return ret;
        }
    }

	private void sendWindowEventToForm(Event* e)
	{
		auto f = getForm();
		if (f)
        {
            debug writeln("sendWindowEventToForm");
			f.windowEventReceiver(e);
        }
	}

    private void sendWindowEventToArtificalWD(Event* e)
	{
        auto f = getArtificalWD();
        if (f)
        {
            debug writeln("sendWindowEventToArtificalWD");
            f.windowEventReceiver(e);
        }
	}

	private void sendNonWindowEventToForm(Event* e)
	{
		auto f = getForm();
		if (f)
        {
            debug writeln("sendNonWindowEventToForm");
			f.nonWindowEventReceiver(e);
        }
	}

    private void sendNonWindowEventToArtificalWD(Event* e)
	{
		auto f = getArtificalWD();
		if (f)
        {
            debug writeln("sendNonWindowEventToArtificalWD");
			f.nonWindowEventReceiver(e);
        }
	}

    void close()
    {
        unsetPlatform();
        SDL_DestroyWindow(sdl_window);
    }

    void formDesiredPosSizeChanged()
    {
        auto f = getForm();
        if (!f)
            return;
        auto w = f.getDesiredWidth();
        auto h = f.getDesiredHeight();
        debug writeln("Window :: form requested size change :: %sx%s".format(w, h));
        // TODO: maybe some policy should be implemented
        setFormSize(Size2D(w, h));
    }

    Tuple!(bool, Position2D) getMousePosition()
    {
        return tuple(mouseIn, Position2D(mouseX, mouseY));
    }

    void redraw()
    {
        if (isSetArtificalWD())
        {
            auto exc = collectException(
                {
                    getArtificalWD().redraw();
                }()
                );
            debug if (exc)
            {
                writeln("collected exception: ", exc);
            }
        }

        if (isSetForm())
        {
            auto exc = collectException(
                {
                    getForm().redraw();
                }()
                );
            debug if (exc)
            {
                writeln("collected exception: ", exc);
            }
        }
    }

    void printParams()
    {
        // import std.format;

        auto pos = getPosition();
        auto size = getSize();
        auto fpos = getFormPosition();
        auto fsize = getFormSize();

        writeln(
            q{printParams()
    title       : %s
    pos.x       : %d
    pos.y       : %d
    size.width  : %d
    size.height : %d
    fpos.x      : %d
    fpos.y      : %d
    fsize.width : %d
    fsize.height: %d
}.format(
                getTitle(),
                pos.x       ,
                pos.y       ,
                size.width  ,
                size.height ,
                fpos.x      ,
                fpos.y      ,
                fsize.width ,
                fsize.height,
                )
                );
    }

    void installArtificalWD()
    {
        if (!isSetArtificalWD())
        {
            auto size = getFormSize();
            auto pos = getFormPosition();
            SDL_SetWindowBordered(sdl_window, SDL_FALSE);
            setArtificalWD(new WindowDecoration(this));
            setFormSize(size);
            setFormPosition(pos);
        }
    }

    bool isBorderless()
    {
        return isSDLBorderless() && (isUnsetArtificalWD());
    }

    private bool isSDLBorderless()
    {
        uint flags = SDL_GetWindowFlags(sdl_window);
        return (flags & SDL_WINDOW_BORDERLESS) != 0;
    }

    deprecated private bool haveSDLBorder()
    {
        return !isSDLBorderless();
    }

    private WindowBorderSizes getSDLBorderSizes()
    {
        WindowBorderSizes ret;
        auto res = SDL_GetWindowBordersSize(
            sdl_window,
            &ret.leftTop.height, &ret.leftTop.width,
            &ret.rightBottom.height, &ret.rightBottom.width
            );
        if (res != 0)
        {
            getPlatform().printSDLError();
            debug writeln(
                "SDL failed to return window border sizes. " ~
                "forcing artifical decoration usage."
                );
            installArtificalWD();
            WindowBorderSizes empty_ret;
            return empty_ret;
        }

        return ret;
    }

    WindowBorderSizes getBorderSizes()
    {
        WindowBorderSizes ret;

        if (isSetArtificalWD())
        {
            auto t = getArtificalWD().getBorderSizes();
            ret.leftTop = ret.leftTop.add(t.leftTop);
            ret.rightBottom = ret.rightBottom.add(t.rightBottom);
        }

        if (!isSDLBorderless())
        {
            auto res = getSDLBorderSizes();
            ret.leftTop = ret.leftTop.add(res.leftTop);
            ret.rightBottom = ret.rightBottom.add(res.rightBottom);
        }
        return ret;
    }

    static foreach (v ;["X", "Y", "Width", "Height"])
    {
        import std.string;

        static foreach (vform; ["", "Form"])
        {

            mixin(
                q{
                    int get%3$s%1$s()
                    {
                        static if ("%1$s" == "X" || "%1$s" == "Y")
                            return get%3$sPosition().%2$s;
                        else
                            return get%3$sSize().%2$s;
                    }

                    Window set%3$s%1$s(int val)
                    {
                        static if ("%1$s" == "X" || "%1$s" == "Y")
                            auto res = get%3$sPosition();
                        else
                            auto res = get%3$sSize();

                        res.%2$s = val;

                        static if ("%1$s" == "X" || "%1$s" == "Y")
                            set%3$sPosition(res);
                        else
                            set%3$sSize(res);
                        return this;
                    }

                }.format(v, v.toLower(), vform)
                );
        }
    }

    // get position on the screen including border if present
    Position2D getPosition()
    {
        Position2D pos;
        SDL_GetWindowPosition(this.sdl_window, &(pos.x), &(pos.y));
        /* if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            pos = pos.sub(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        } */
        if (!isSDLBorderless())
        {
            auto sdlbs = getSDLBorderSizes();
            pos = pos.sub(
                sdlbs.leftTop.width,
                sdlbs.leftTop.height
                );
        }
        return pos;
    }

    Size2D getSize()
    {
        Size2D size;
        SDL_GetWindowSize(this.sdl_window, &(size.width), &(size.height));
        /* if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            size = size.add(awdbs.leftTop);
            size = size.add(awdbs.rightBottom);
        } */
        if (!isSDLBorderless())
        {
            auto sdlbs = getSDLBorderSizes();
            size = size.add(sdlbs.leftTop);
            size = size.add(sdlbs.rightBottom);
        }
        return size;
    }

    Position2D getFormPosition()
    {
        Position2D pos;
        SDL_GetWindowPosition(this.sdl_window, &(pos.x), &(pos.y));
        if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            pos = pos.add(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        }
        return pos;
    }

    Size2D getFormSize()
    {
        Size2D size;
        SDL_GetWindowSize(this.sdl_window, &(size.width), &(size.height));
        if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            size = size.sub(awdbs.leftTop);
            size = size.sub(awdbs.rightBottom);
        }
        return size;
    }

    Window setPosition(Position2D pos)
    {
        /* if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            pos = pos.add(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        } */
        if (!isSDLBorderless())
        {
            auto sdlbs = getSDLBorderSizes();
            pos = pos.add(
                sdlbs.leftTop.width,
                sdlbs.leftTop.height
                );
        }
        SDL_SetWindowPosition(sdl_window, pos.x, pos.y);
        return this;
    }

    Window setSize(Size2D size)
    {
        if (!isSDLBorderless())
        {
            auto sdlbs = getSDLBorderSizes();
            size = size.sub(sdlbs.leftTop);
            size = size.sub(sdlbs.rightBottom);
        }
        SDL_SetWindowSize(sdl_window, size.width, size.height);
        return this;
    }

    Window setFormPosition(Position2D pos)
    {
        if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            pos = pos.sub(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        }
        SDL_SetWindowPosition(sdl_window, pos.x, pos.y);
        return this;
    }

    Window setFormSize(Size2D size)
    {
        if (isSetArtificalWD())
        {
            auto awdbs = getArtificalWD().getBorderSizes();
            size = size.add(awdbs.leftTop);
            size = size.add(awdbs.rightBottom);
        }
        SDL_SetWindowSize(sdl_window, size.width, size.height);
        return this;
    }

    Size2D getArtificalWDSize()
    {
        Size2D size;
        SDL_GetWindowSize(this.sdl_window, &(size.width), &(size.height));
        return size;
    }
}
