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

import dtk.DrawingSurface_collection.sdl_software.DrawingSurface;

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

import dtk.prototypes.WindowPrototype001;

// import dtk.signal_mixins.Window;



class Window : WindowPrototype001
{

    // TODO: maybe this shouldn't be public
    public
    {
        SDL_Window* sdl_window;
        typeof(SDL_WindowEvent.windowID) sdl_window_id;
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

    override DrawingSurfaceI makePlatformDrawingSurface(WindowI win)
    {
        return new DrawingSurface(cast(Window)win);
    }

    override void close()
    {
        super.close();
        SDL_DestroyWindow(sdl_window);
    }

    override bool isPlatformBorderless()
    {
        uint flags = SDL_GetWindowFlags(sdl_window);
        return (flags & SDL_WINDOW_BORDERLESS) != 0;
    }

    override WindowBorderSizes getPlatformBorderSizes()
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

    override Position2D getPlatformPosition()
    {
        Position2D pos;
        // TODO: add error checking
        SDL_GetWindowPosition(this.sdl_window, &(pos.x), &(pos.y));
        return pos;
    }

    override Size2D getPlatformSize()
    {
        Size2D size;
        // TODO: add error checking
        SDL_GetWindowSize(this.sdl_window, &(size.width), &(size.height));
        return size;
    }

    override WindowI setPlatformPosition(Position2D pos)
    {
        // TODO: add error checking
        SDL_SetWindowPosition(this.sdl_window, (pos.x), (pos.y));
        return this;
    }

    override WindowI setPlatformSize(Size2D size)
    {
        // TODO: add error checking
        SDL_SetWindowSize(this.sdl_window, (size.width), (size.height));
        return this;
    }

}
