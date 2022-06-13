module dtk.platforms.sdl_desktop.Window;

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

import dtk.platforms.sdl_desktop.DrawingSurface;
import dtk.platforms.sdl_desktop.SDLDesktopPlatform;
import dtk.platforms.sdl_desktop.utils;

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

import dtk.widgets.Form;
import dtk.widgets.Menu;

import dtk.wm.WindowDecoration;

// import dtk.signal_mixins.Window;

const auto WindowProperties = cast(PropSetting[])[
    PropSetting("gsun", "SDLDesktopPlatform", "platform", "Platform", "null"),
    PropSetting("gsun", "Form", "form", "Form", "null"),
    PropSetting("gsun", "WindowDecoration", "windowDecoration", "WindowDecoration", "null"),
    PropSetting("gsun", "LaFI", "forced_laf", "ForcedLaf", "null"),
    // PropSetting("gsun", "WindowEventMgrI", "emgr", "WindowEventMgr", "null"),
    PropSetting("gsun", "DrawingSurfaceI", "drawing_surface", "DrawingSurface", "null"),

    PropSetting("gs_w_d", "dstring", "title", "Title", q{""d}),

    // XYWH - XY relative to screen. XYWH = [form XYWH] plus window borders
    /* PropSetting("gs_w_d", "int", "x", "X", "0"),
    PropSetting("gs_w_d", "int", "y", "Y", "0"),
    PropSetting("gs_w_d", "int", "width", "Width", "0"),
    PropSetting("gs_w_d", "int", "height", "Height", "0"), */

    // [form XYWH] - XY relative to screen. [form XYWH] = XYWH minus window borders
    /* PropSetting("gs_w_d", "int", "formX", "FormX", "0"),
    PropSetting("gs_w_d", "int", "formY", "FormY", "0"),
    PropSetting("gs_w_d", "int", "formWidth", "FormWidth", "0"),
    PropSetting("gs_w_d", "int", "formHeight", "FormHeight", "0"), */
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
        SignalConnection cs_WindowDecorationChange;

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
                    SDLDesktopPlatform old_value,
                    SDLDesktopPlatform new_value
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

        cs_WindowDecorationChange = connectToForm_onAfterChanged(
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

        /* static foreach (v; ["X", "Y", "Width", "Height"])
        {
            mixin(q{
    				cs_%1$sChange = connectTo%1$s_onAfterChanged(
    					delegate void(
    						int old_value,
    						int new_value
    						)
    					{
    						collectException(
    							{
    								if (old_value == new_value)
    									return;

    								static if ("%1$s" == "X" || "%1$s" == "Y")
    								{
    									intWindowPosChanged();
    								}
    								else
    								{
    									intWindowSizeChanged();
    								}
    							}()
    							);
    					}
    					);

    				cs_Form%1$sChange = connectToForm%1$s_onAfterChanged(
    					delegate void(
    						int old_value,
    						int new_value
    						)
    					{
    						collectException(
    							{
    								if (old_value == new_value)
    									return;

    								static if ("%1$s" == "X" || "%1$s" == "Y")
    								{
    									intWindowFormPosChanged();
    								}
    								else
    								{
    									intWindowFormSizeChanged();
    								}
    							}()
    							);
    					}
    					);
    			}.format(v));
        } */
    }

    void setDebugName(dstring value)
    {
        debug_name = value;
    }

    DrawingSurfaceI getFormDrawingSurface()
    {
        auto ds = getDrawingSurface();
        if (!ds)
            return null;
        auto bs = getBorderSizes();
        auto ret = new DrawingSurfaceShift(
            ds,
            bs.leftTop.width,
            bs.leftTop.height
            );
        return ret;
    }

    /* private void intWindowPosChanged()
    {
        auto validFormXY = positionRemoveWindowBorder(Position2D(getX(), getY()));

        if (getFormX() != validFormXY.x)
            setFormX(validFormXY.x);

        if (getFormY() != validFormXY.y)
            setFormY(validFormXY.y);
    }

    private void intWindowSizeChanged()
    {
        auto validFormWH = sizeRemoveWindowBorder(Size2D(getWidth(), getHeight()));

        if (getFormWidth() != validFormWH.width)
            setFormWidth(validFormWH.width);

        if (getFormHeight() != validFormWH.height)
            setFormHeight(validFormWH.height);
    }

    private void intWindowFormPosChanged()
    {
        auto validXY = positionAddWindowBorder(Position2D(getFormX(), getFormY()));

        if (getX() != validXY.x)
            setX(validXY.x);

        if (getY() != validXY.y)
            setY(validXY.y);
    }

    private void intWindowFormSizeChanged()
    {
        auto validWH = sizeAddWindowBorder(Size2D(getFormWidth(), getFormHeight()));

        if (getWidth() != validWH.width)
            setWidth(validWH.width);

        if (getHeight() != validWH.height)
            setHeight(validWH.height);
    } */

    private void windowSyncPosition(bool externalStronger)
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
    }

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
    private bool sdlWindowSizesIncludesBorderSizes()
    {
        if (isSetWindowDecoration())
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
            return false;
        case SDL_SYSWM_WAYLAND:
            return true;
        }
    }

    void onPlatformEvent(Event* event) nothrow
    {
        auto exc = collectException({
            if (event.window != this)
                return;

            if (event.type == EventType.none)
            {
                debug writeln("event.type == EventType.none");
                return;
            }

            // NOTE: this moved to platform
            // if (event.type == EventType.mouse
            // && event.em.type == EventMouseType.movement)
            // {
            // // TODO: save relative values too?
            // mouseX = event.em.x;
            // mouseY = event.em.y;
            // }
            //
            // {
            // event.mouseX = mouseX;
            // event.mouseY = mouseY;
            // }

            if (event.type == EventType.window)
            {
                debug writeln("window \"%s\" got event %s".format(debug_name, event.ew.eventId));

                switch (event.ew.eventId)
                {
                default:
                    break;
                case EnumWindowEvent.show:
                case EnumWindowEvent.expose:
                case EnumWindowEvent.resize:
                    {
                        /* auto formSize = getFormSize();
                        setFormWidth(formSize.width);
                        setFormHeight(formSize.height); */
                        // intWindowSizeChanged();
                        // windowSyncSize(true);

                        // NOTE: falling through here, because resizing may
                        //       imply movement
                    }
                    goto case;
                case EnumWindowEvent.move:
                    {
                        // auto formPos = getFormPosition();
                        // setFormX(formPos.x);
                        // setFormY(formPos.y);
                        // intWindowPosChanged();
                        // windowSyncPosition(true);
                    }
                    // redraw();
                    // debug printParams();
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
				sendWindowEventToForm(event.ew);

            }
            else
            {
                debug writeln("before sendNonWindowEventToForm/sendNonWindowEventToWindowDecoration");
                auto pos = Position2D(event.mouseX, event.mouseY);
                if (isPositionInForm(pos))
                {
                    pos = positionAddWindowBorder(pos);
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
                    sendNonWindowEventToWindowDecoration(event);
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
        auto bs = getBorderSizes();
        auto ww = getWidth();
        auto wh = getHeight();
        auto px = pos.x;
        auto py = pos.y;
        auto top = bs.leftTop.height;
        auto left = bs.leftTop.width;
        auto bottom = bs.rightBottom.height;
        auto right = bs.rightBottom.width;
        bool ret;
        ret = (
            px >= left
            && px < ww - right
            && py >= top
            && py < wh - bottom
            );
        return ret;
    }

	private void sendWindowEventToForm(EventWindow* e)
	{
		auto f = getForm();
		if (f)
        {
            debug writeln("sendWindowEventToForm");
			f.windowEventReceiver(e);
        }
	}

    private void sendWindowEventToWindowDecoration(EventWindow* e)
	{
        auto f = getWindowDecoration();
        if (f)
        {
            debug writeln("sendWindowEventToWindowDecoration");
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

    private void sendNonWindowEventToWindowDecoration(Event* e)
	{
		auto f = getWindowDecoration();
		if (f)
        {
            debug writeln("sendNonWindowEventToWindowDecoration");
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
        //setFormX(f.getDesiredX());
        //setFormY(f.getDesiredY());
        auto w = f.getDesiredWidth();
        auto h = f.getDesiredHeight();
        debug writeln("Window :: form requested size change :: %sx%s".format(w, h));
        // setFormWidth(w);
        // setFormHeight(h);
        setFormSize(Size2D(w, h));
        /* windowSyncSize(false); */
    }

    Tuple!(bool, Position2D) getMousePosition()
    {
        return tuple(mouseIn, Position2D(mouseX, mouseY));
    }

    void redraw()
    {
        if (isSetWindowDecoration())
            getWindowDecoration().redraw();

        if (isSetForm())
            getForm().redraw();
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
    x           : %d
    y           : %d
    width       : %d
    height      : %d
    form_x      : %d
    form_y      : %d
    form_width  : %d
    form_height : %d
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
                getX(),
                getY(),
                getWidth(),
                getHeight(),
                getFormX(),
                getFormY(),
                getFormWidth(),
                getFormHeight(),
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

	void installWindowDecoration()
	{
		if (!isSetWindowDecoration())
		{
            SDL_SetWindowBordered(sdl_window, SDL_FALSE);
			setWindowDecoration(new WindowDecoration(this));
		}
	}

    // return bool true on success
    WindowBorderSizes getBorderSizes()
    {
		if (isSetWindowDecoration())
			return getWindowDecoration().getBorderSizes();

        WindowBorderSizes ret;
        auto res = SDL_GetWindowBordersSize(
            sdl_window,
            &ret.leftTop.height,
            &ret.leftTop.width,
            &ret.rightBottom.height,
            &ret.rightBottom.width
            );
        // TODO: add exception here
        // NOTE: can't attend to this for now, because it's not in priority.
        //       probably will do it after
        //       https://issues.dlang.org/show_bug.cgi?id=23155 will be fixed.
        if (res != 0)
        {
            getPlatform().printSDLError();
            // throw new Exception("SDL Exception: couldn't determine window border sizes");
			installWindowDecoration();
			return getWindowDecoration().getBorderSizes();
        }
        return ret;
    }

    // convert [value without border](Form Position) to [value with border]
    // window position.
    // Window Form XY should be passed as parameter
    Position2D positionAddWindowBorder(Position2D pos)
    {
        auto bs = getBorderSizes();
        auto ret = Position2D(
            pos.x - bs.leftTop.width,
            pos.y - bs.leftTop.height
            );
        return ret;
    }

    // convert value without border to value with border.
    // Window XY should be passed as parameter
    Position2D positionRemoveWindowBorder(Position2D pos)
    {
        auto bs = getBorderSizes();
        auto ret = Position2D(
            pos.x + bs.leftTop.width,
            pos.y + bs.leftTop.height
            );
        return ret;
    }

    Size2D sizeAddWindowBorder(Size2D size)
    {
        auto bs = getBorderSizes();
        auto ret = Size2D(
            size.width + bs.leftTop.width + bs.rightBottom.width,
            size.height + bs.leftTop.height + bs.rightBottom.height
            );
        return ret;
    }

    Size2D sizeRemoveWindowBorder(Size2D size)
    {
        auto bs = getBorderSizes();
        auto ret = Size2D(
            size.width - (bs.leftTop.width + bs.rightBottom.width),
            size.height - (bs.leftTop.height + bs.rightBottom.height)
            );
        return ret;
    }

    Position2D getPosition()
    {
        Position2D pos;
        SDL_GetWindowPosition(this.sdl_window, &(pos.x), &(pos.y));
        return pos;
    }

    Size2D getSize()
    {
        Size2D size;
        SDL_GetWindowSize(this.sdl_window, &(size.width), &(size.height));
        return size;
    }

    Position2D getFormPosition()
    {
        Position2D pos;
        SDL_GetWindowPosition(this.sdl_window, &(pos.x), &(pos.y));
        if (sdlWindowSizesIncludesBorderSizes())
            pos = positionRemoveWindowBorder(pos);
        return pos;
    }

    Size2D getFormSize()
    {
        Size2D size;
        SDL_GetWindowSize(this.sdl_window, &(size.width), &(size.height));
        if (sdlWindowSizesIncludesBorderSizes())
            size = sizeRemoveWindowBorder(size);
        return size;
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
                        {
                            return get%3$sPosition().%2$s;
                        }
                        else
                        {
                            return get%3$sSize().%2$s;
                        }
                    }

                    Window set%3$s%1$s(int val)
                    {
                        static if ("%1$s" == "X" || "%1$s" == "Y")
                        {
                            auto res = get%3$sPosition();
                        }
                        else
                        {
                            auto res = get%3$sSize();
                        }

                        res.%2$s = val;

                        static if ("%1$s" == "X" || "%1$s" == "Y")
                        {
                            set%3$sPosition(res);
                        }
                        else
                        {
                            set%3$sSize(res);
                        }
                        return this;
                    }

                }.format(v, v.toLower(), vform)
                );
        }
    }

    void setPosition(Position2D pos)
    {
        SDL_SetWindowPosition(sdl_window, pos.x, pos.y);
    }

    void setSize(Size2D size)
    {
        SDL_SetWindowSize(sdl_window, size.width, size.height);
    }

    void setFormPosition(Position2D pos)
    {
        if (sdlWindowSizesIncludesBorderSizes())
            pos = positionAddWindowBorder(pos);
        SDL_SetWindowPosition(sdl_window, pos.x, pos.y);
    }

    void setFormSize(Size2D size)
    {
        if (sdlWindowSizesIncludesBorderSizes())
            size = sizeAddWindowBorder(size);
        SDL_SetWindowSize(sdl_window, size.width, size.height);
    }
}
