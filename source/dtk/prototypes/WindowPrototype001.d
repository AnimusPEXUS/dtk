module dtk.prototypes.WindowPrototype001;

import std.conv;
import std.string;
import std.typecons;
import std.stdio;
import std.algorithm;
import std.exception;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WindowDecorationI;

import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;

// import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.LaFI;

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

    PropSetting("gs_w_d", "dstring", "debugName", "DebugName", q{""}),
];

class WindowPrototype001 : WindowI
{

    mixin mixin_multiple_properties_define!(WindowProperties);
    mixin mixin_multiple_properties_forward!(WindowProperties, false);

    // TODO: maybe this shouldn't be public
    // private
    // {
    //     bool mouseIn;
    //     int mouseX;
    //     int mouseY;
    // }

    private
    {
        SignalConnection cs_PlatformChange;
        SignalConnection cs_FormChange;
        SignalConnection cs_TitleChange;
        SignalConnection cs_PreferedArtificalWD;

        SignalConnection platform_signal_connection;
    }

    @disable this();

    this(WindowCreationSettings window_settings)
    {
        mixin(mixin_multiple_properties_inst(WindowProperties));

        setDrawingSurface(makePlatformDrawingSurface(this));

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

        cs_TitleChange = connectToForm_onAfterChanged(
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

        if (window_settings.prefereArtificalWD)
            installArtificalWD();
    }

    WindowI setPlatformTitle(dstring value)
    {
        return this;
    }

    DrawingSurfaceI makePlatformDrawingSurface(WindowI)
    {
        // TODO: make this abstract
        return null;
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

    LaFI calcLaf()
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

    void onPlatformEvent(Event* event) nothrow
    {
        auto exc = collectException(
            {
                if (event.window is null)
                    throw new Exception(
                        "event.window is null - this shouldn't be happening"
                        );

                if (event.window != this)
                {
                    return;
                }

                if (event.type == EventType.none)
                {
                    debug writeln("event.type == EventType.none");
                    return;
                }

                if (event.type == EventType.window)
                {
                    debug writeln(
                        "window \"%s\" got event %s".format(
                            getDebugName(), 
                            event.ew.eventId
                        )
                    );

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
        else
        {
            debug writeln("sendWindowEventToForm no form");
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
        else
        {
            debug writeln("sendWindowEventToArtificalWD no wd");
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

    // Tuple!(bool, Position2D) getSavedMousePosition()
    // {
    //     return tuple(mouseIn, Position2D(mouseX, mouseY));
    // }

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
        return isPlatformBorderless() && (!isSetInstalledArtificalWD());
    }

    bool isPlatformBorderless()
    {
        return false;
    }

    WindowBorderSizes getPlatformBorderSizes()
    {
        WindowBorderSizes ret;
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

        if (!isPlatformBorderless())
        {
            auto res = getPlatformBorderSizes();
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

                    WindowI set%3$s%1$s(int val)
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
        Position2D pos = getPlatformPosition();
        /* if (zyxuq())
        {
            auto awdbs = abcdefg().getBorderSizes();
            pos = pos.sub(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        } */
        if (!isPlatformBorderless())
        {
            auto sdlbs = getPlatformBorderSizes();
            pos = pos.sub(
                sdlbs.leftTop.width,
                sdlbs.leftTop.height
                );
        }
        return pos;
    }

    Position2D getPlatformPosition()
    {
        Position2D pos;
        return pos;
    }

    Size2D getPlatformSize()
    {
        Size2D size;
        return size;
    }

    WindowI setPlatformPosition(Position2D)
    {
        Position2D pos;
        return this;
    }

    WindowI setPlatformSize(Size2D)
    {
        Size2D size;
        return this;
    }

    Size2D getSize()
    {
        Size2D size = getPlatformSize();
        /* if (zyxuq())
        {
            auto awdbs = abcdefg().getBorderSizes();
            size = size.add(awdbs.leftTop);
            size = size.add(awdbs.rightBottom);
        } */
        if (!isPlatformBorderless())
        {
            auto sdlbs = getPlatformBorderSizes();
            size = size.add(sdlbs.leftTop);
            size = size.add(sdlbs.rightBottom);
        }
        return size;
    }

    Position2D getFormPosition()
    {
        Position2D pos = getPlatformPosition();
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
        Size2D size = getPlatformSize();
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
            size = size.sub(awdbs.leftTop);
            size = size.sub(awdbs.rightBottom);
        }
        return size;
    }

    WindowI setPosition(Position2D pos)
    {
        /* if (zyxuq())
        {
            auto awdbs = abcdefg().getBorderSizes();
            pos = pos.add(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        } */
        if (!isPlatformBorderless())
        {
            auto sdlbs = getPlatformBorderSizes();
            pos = pos.add(
                sdlbs.leftTop.width,
                sdlbs.leftTop.height
                );
        }
        setPlatformPosition(pos);
        return this;
    }

    WindowI setSize(Size2D size)
    {
        if (!isPlatformBorderless())
        {
            auto sdlbs = getPlatformBorderSizes();
            size = size.sub(sdlbs.leftTop);
            size = size.sub(sdlbs.rightBottom);
        }
        setPlatformSize(size);
        return this;
    }


    WindowI setFormPosition(Position2D pos)
    {
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
            pos = pos.sub(
                    awdbs.leftTop.width,
                    awdbs.leftTop.height
                );
        }
        setPlatformPosition(pos);
        return this;
    }

    WindowPrototype001 setFormSize(Size2D size)
    {
        if (isSetInstalledArtificalWD())
        {
            auto awdbs = getInstalledArtificalWD().getBorderSizes();
            size = size.add(awdbs.leftTop);
            size = size.add(awdbs.rightBottom);
        }
        setPlatformSize(size);
        return this;
    }

    Size2D getArtificalWDSize()
    {
        Size2D size = getPlatformSize();
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

        {
            auto wds = p.getPreferedArtificalWDSpawner();
            if (wds)
                return wds;
        }

        {
            auto wds = p.getBuiltinWDSpawner();
            if (wds)
                return wds;
        }
        return null;
    }
}
// isSetInstalledArtificalWD
// getInstalledArtificalWD