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
import dtk.interfaces.WindowDecorationI;

import dtk.interfaces.FormI;
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
import dtk.types.ArtificalWDSpawner;

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
    PropSetting("gsun", "PlatformI", "platform", "Platform", "null"),
    PropSetting("gsun", "FormI", "form", "Form", "null"),

    PropSetting("gsun", "LaFI", "forced_laf", "ForcedLaf", "null"),
    // PropSetting("gsun", "WindowEventMgrI", "emgr", "WindowEventMgr", "null"),
    PropSetting("gsun", "DrawingSurfaceI", "drawing_surface", "DrawingSurface", "null"),

    // Window Title storage
    PropSetting("gs_w_d", "dstring", "title", "Title", q{""d}),

    // platform uses this to track mouse position on events which doesn't pass
    // mouse coordinates
    PropSetting("gs", "Position2D", "storedMousePosition", "StoredMousePosition", "null"),

    // set to true to override platform-wide value
    PropSetting("gs_w_d", "bool", "prefereArtificalWD", "PrefereArtificalWD", q{false}),

    // if this is set - it will be used instead of platform-wide AWD spawner
    PropSetting("gsun", "ArtificalWDSpawner", "preferedArtificalWDSpawner", "PreferedArtificalWDSpawner", q{}),

    // here is places actuall installed AWD if any
    PropSetting("gsun", "WindowDecorationI", "installedArtificalWD", "InstalledArtificalWD", q{}),
];

class Window : WindowI
{

    mixin mixin_multiple_properties_define!(WindowProperties);
    mixin mixin_multiple_properties_forward!(WindowProperties, false);

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
        SignalConnection cs_PreferedArtificalWD;

        SignalConnection platform_signal_connection;
    }

    @disable this();

    this(WindowCreationSettings window_settings)
    {
        mixin(mixin_multiple_properties_inst(WindowProperties));


        setDrawingSurface(new DrawingSurface(this));

        // without this SDL makes fullscreen window;
        auto flags = cast(SDL_WindowFlags) 0;

        if (window_settings.resizable)
        {
            flags |= SDL_WINDOW_RESIZABLE;
        }

        if (window_settings.popupMenu)
        {
            flags |= SDL_WINDOW_POPUP_MENU;
        }

        string tt = to!string(window_settings.title);

        debug writeln("SDL_CreateWindow");
        // TODO: check x, y, w, h usage
        sdl_window = SDL_CreateWindow(
            "DTK app window temporary title",
            window_settings.x,
            window_settings.y,
            window_settings.w,
            window_settings.h,
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
                    PlatformI old_value,
                    PlatformI new_value
                    ) {
            collectException({
                if (old_value == new_value)
                    return;

                platform_signal_connection.disconnect();

                if (old_value !is null)
                    old_value.removeWindow(cast(WindowI)this);

                if (new_value !is null)
                {
                    if (!new_value.haveWindow(cast(WindowI)this))
                        new_value.addWindow(cast(WindowI)this);
                    platform_signal_connection = new_value.connectToSignal_Event(
                        &onPlatformEvent
                        );
                }
            }());
        });

        cs_FormChange = connectToForm_onAfterChanged(
            delegate void(FormI old_value, FormI new_value) {
            collectException({
                if (old_value == new_value)
                    return;

                if (old_value !is null)
                    old_value.unsetWindow();

                if (new_value !is null && new_value.getWindow() != this)
                    new_value.setWindow(this);
            }());
        });

//         cs_PreferedArtificalWD = connectToPreferedArtificalWD_onAfterChanged(
//             delegate void(
//                 WindowDecorationI old_value,
//                 WindowDecorationI new_value
//             ) {
//             collectException({
//                 if (old_value == new_value)
//                     return;

//                 if (old_value !is null)
//                     if (old_value.getWindow() == this)
//                         old_value.unsetWindow();

//                 if (new_value !is null && new_value.getWindow() != this)
//                     new_value.setWindow(this);
//             }());
//         });

        if (window_settings.prefereArtificalWD)
            installArtificalWD();
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

        if (isSetInstalledArtificalWD())
        {
            auto bs = getInstalledArtificalWD().getBorderSizes();
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
                        if (isSetInstalledArtificalWD())
                        {
                            auto bs = getInstalledArtificalWD().getBorderSizes();
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
        if (!isSetInstalledArtificalWD())
        {
            return true;
        }
        else
        {
            WindowBorderSizes bs;

            bs = getInstalledArtificalWD().getBorderSizes();

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
        auto f = getInstalledArtificalWD();
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
        auto f = getInstalledArtificalWD();
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
        if (isSetInstalledArtificalWD())
        {
            auto exc = collectException(
                {
                    getInstalledArtificalWD().redraw();
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

    bool isBorderless()
    {
        return isSDLBorderless() && (!isSetInstalledArtificalWD());
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
            getPlatform().printPlatformError();
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

        if (isSetInstalledArtificalWD())
        {
            auto t = getInstalledArtificalWD().getBorderSizes();
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
        /* if (zyxuq())
        {
            auto awdbs = abcdefg().getBorderSizes();
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
        /* if (zyxuq())
        {
            auto awdbs = abcdefg().getBorderSizes();
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
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
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
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
            size = size.sub(awdbs.leftTop);
            size = size.sub(awdbs.rightBottom);
        }
        return size;
    }

    Window setPosition(Position2D pos)
    {
        /* if (zyxuq())
        {
            auto awdbs = abcdefg().getBorderSizes();
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
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
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
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
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

    void installArtificalWD()
    {
        setPrefereArtificalWD(true);
        auto wd_spawner = calcArtificalWDSpawnerToUse();
        if (!wd_spawner)
            throw new Exception("got null instead of ArtificalWDSpawner");
        auto wd = wd_spawner(this);
        setInstalledArtificalWD(wd);
    }

    void uninstallArtificalWD()
    {
        unsetInstalledArtificalWD();
    }

    void reinstallArtificalWD()
    {
        uninstallArtificalWD();
        installArtificalWD();
    }

    bool usingArtificalWD()
    {
        return isSetInstalledArtificalWD();
    }

    // calculates true if Window should use AWD at all.
    bool shouldUseArtificalWD()
    {
        if (getPrefereArtificalWD())
            return true;
        auto p = getPlatform();
        if (!p)
            return false;
        if (p.getPrefereArtificalWD())
            return true;
        return false;
    }

    // this should not include installedAWD. it should be used to determine
    // AWD to be installed
    ArtificalWDSpawner calcArtificalWDSpawnerToUse()
    {
        if (!shouldUseArtificalWD())
            return null;
        if (isSetPreferedArtificalWDSpawner())
            return getPreferedArtificalWDSpawner();
        auto p = getPlatform();
        if (!p)
            return null;
        return p.getPreferedArtificalWDSpawner();
    }
}
// isSetInstalledArtificalWD
// getInstalledArtificalWD