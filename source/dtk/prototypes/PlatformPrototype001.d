module dtk.prototypes.PlatformPrototype001;

import core.sync.mutex;

import std.typecons;
import std.format;
import std.stdio;

import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;
import dtk.interfaces.LaFI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.MouseCursorMgrI;
import dtk.interfaces.WindowDecorationI;

import dtk.types.Event;
import dtk.types.Position2D;
import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.WindowCreationSettings;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;
import dtk.types.EnumWindowDraggingEventEndReason;
import dtk.types.ArtificalWDSpawner;

import dtk.miscs.signal_tools;

import dtk.wm.WindowDecoration;

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

    PropSetting("gs_w_d", "bool", "prefereArtificalWD", "PrefereArtificalWD", q{false}),
    PropSetting("gsun", "ArtificalWDSpawner", "preferedArtificalWDSpawner", "PreferedArtificalWDSpawner", q{}),
];

// this is Platform prototype. as Prototype code is common for most platforms,
// it's decided to extrude such common code to prototype
class PlatformPrototype001 : PlatformI
{

    mixin mixin_multiple_properties_define!(PlatformProperties);
    mixin mixin_multiple_properties_forward!(PlatformProperties, false);

    mixin(mixin_PlatformSignals(false));

    protected
    {
        WindowI[] windows;

        bool stop_flag;
    }

    string getName()
    {
        throw new Exception("abstract");
    }

    string getDescription()
    {
        throw new Exception("abstract");
    }

    bool canCreateWindow()
    {
        throw new Exception("abstract");
    }

    bool getFormCanResizeWindow()
    {
        throw new Exception("abstract");
    }

    this()
    {
        mixin(mixin_multiple_properties_inst(PlatformProperties));
    }

    void destroy()
    {
        throw new Exception("abstract");
    }

    WindowI[] getWindowIArray()
    {
        return windows;
    }

    WindowI createWindow(WindowCreationSettings window_settings)
    {
        throw new Exception("abstract");
    }

    LaFI delegate() onGetLaf;

    PlatformI setOnGetLaf(LaFI delegate() cb)
    {
        onGetLaf = cb;
        return this;
    }

    LaFI getLaf()
    {
        if (onGetLaf is null)
            throw new Exception("onGetLaf is not set");
        return onGetLaf();
    }

    ArtificalWDSpawner getBuiltinWDSpawner()
    {
        return &builtinWDSpawner;
    }

    private WindowDecorationI builtinWDSpawner(WindowI win)
    {
        return new WindowDecoration(win);
    }

    void addWindow(WindowI win)
    {
        if (haveWindow(win))
            return;

        windows ~= win;

        if (win.getPlatform() != this)
            win.setPlatform(this);
    }

    void removeWindow(WindowI win)
    {
        size_t[] indexes;
        foreach (size_t i, ref WindowI w; windows)
        {
            if (w == win)
                indexes ~= i;
        }

        foreach_reverse (size_t i; indexes)
        {
            windows = windows[0 .. i] ~ windows[i + 1 .. $];
        }

        if (win.getPlatform() == this)
            win.unsetPlatform();
    }

    bool haveWindow(WindowI win)
    {
        foreach (w; windows)
        {
            if (w == win)
                return true;
        }

        return false;
    }

    void mainLoop()
    {
        // not necessary to override
    }

    void consumeEvent(Event* e)
    {
        if (e.window) {
            auto w = e.window;
            if (e.type == EventType.mouse && e.em.type == EventMouseType.movement)
            {
                // TODO: save relative values too?
                w.setStoredMousePosition(Position2D(e.em.x, e.em.y));
                e.mouseX = e.em.x;
                e.mouseY = e.em.y;
            }
            else
            {
                auto pos = w.getStoredMousePosition();
                e.mouseX = pos.x;
                e.mouseY = pos.y;
            }
        }

        if (widgetInternalDraggingEventActive)
        {
            debug writeln("if (widgetInternalDraggingEventActive) true");
            widgetInternalDraggingEventLoopRoutine(e);
            return;
        }

        if (windowDraggingEventActive)
        {
            debug writeln("if (windowDraggingEventActive) true");
            windowDraggingEventLoopRoutine(e);
            return;
        }

        debug writeln("emitSignal_Event(e)");
        emitSignal_Event(e);
    }

    void widgetInternalDraggingEventLoopRoutine(Event* e)
    {
        if (widgetInternalDraggingEventActive)
        {
            if (widgetInternalDraggingEventStopCheck is null)
            {
                debug writeln("error: widgetInternalDraggingEventStopCheck is null");
                widgetInternalDraggingEventEnd(
                    e,
                    EnumWidgetInternalDraggingEventEndReason.abort
                );
                return;
            }
            if (widgetInternalDraggingEventWidget is null)
            {
                debug writeln("error: widgetInternalDraggingEventWidget is null");
                widgetInternalDraggingEventEnd(
                    e,
                    EnumWidgetInternalDraggingEventEndReason.abort
                );
                return;
            }
            {
                auto res_drag_stop_check = widgetInternalDraggingEventStopCheck(e);
                debug writeln("res_drag_stop_check == %s".format(res_drag_stop_check));
                if (res_drag_stop_check != EnumWidgetInternalDraggingEventEndReason.notEnd)
                {
                    widgetInternalDraggingEventEnd(e, res_drag_stop_check);
                    return;
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
        }
    }

    void windowDraggingEventLoopRoutine(Event* e)
    {
        if (windowDraggingEventActive)
        {
            if (windowDraggingEventStopCheck is null)
            {
                debug writeln("error: windowDraggingEventStopCheck is null");
                windowDraggingEventEnd(
                    e,
                    EnumWindowDraggingEventEndReason.abort
                );
                return;
            }
            if (windowDraggingEventWindow is null)
            {
                debug writeln("error: windowDraggingEventWindow is null");
                windowDraggingEventEnd(
                    e,
                    EnumWindowDraggingEventEndReason.abort
                );
                return;
            }
            {
                auto res_drag_stop_check = windowDraggingEventStopCheck(e);
                debug writeln("res_drag_stop_check == %s".format(res_drag_stop_check));
                if (res_drag_stop_check != EnumWindowDraggingEventEndReason.notEnd)
                {
                    windowDraggingEventEnd(e, res_drag_stop_check);
                    return;
                }
            }

            if (e.type == EventType.mouse && e.em.type == EventMouseType.movement)
            {
                windowDraggingEventMouseMove();
            }
        }
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

    void beforeWidgetInternalDraggingEventStart()
    {}

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

        beforeWidgetInternalDraggingEventStart();

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

    void beforeWidgetInternalDraggingEventEnd()
    {}

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

        beforeWidgetInternalDraggingEventEnd();

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

        WindowI windowDraggingEventWindow;

        EnumWindowDraggingEventEndReason
            delegate(Event* e) windowDraggingEventStopCheck;

        int windowDraggingEventInitX;
        int windowDraggingEventInitY;
        int windowDraggingEventCursorInitX;
        int windowDraggingEventCursorInitY;
    }

    void beforeWindowDraggingEventStart() {}

    void windowDraggingEventStart(
        WindowI window,
        EnumWindowDraggingEventEndReason
            delegate(Event* e) windowDraggingEventStopCheck
        )
    {
        beforeWindowDraggingEventStart();

        windowDraggingEventWindow = window;

        auto pos = window.getPosition();

        windowDraggingEventInitX = pos.x;
        windowDraggingEventInitY = pos.y;

        auto mousePos = getMouseCursorPosition();

        windowDraggingEventCursorInitX = mousePos.x;
        windowDraggingEventCursorInitY = mousePos.y;

        this.windowDraggingEventStopCheck = windowDraggingEventStopCheck;

        windowDraggingEventActive = true;

        assert(windowDraggingEventWindow !is null);
        assert(windowDraggingEventStopCheck !is null);
    }

    void beforeWindowDraggingEventEnd()
    {}

    void windowDraggingEventEnd(
        Event* e,
        EnumWindowDraggingEventEndReason reason
        )
    {
        if (reason == EnumWindowDraggingEventEndReason.notEnd)
        {
            return;
        }

        windowDraggingEventActive = false;
        windowDraggingEventWindow = null;
        windowDraggingEventStopCheck = null;
        debug writeln("windowDraggingEventEnd end");
    }

    void windowDraggingEventMouseMove()
    {
        // TODO: todo
        int x;
        int y;

        auto mousePos = getMouseCursorPosition();

        x = mousePos.x;
        y = mousePos.y;

        debug writeln("global mouse state %sx%s".format(x, y));

        windowDraggingEventWindow.setPosition(
            Position2D(
                windowDraggingEventInitX - (windowDraggingEventCursorInitX - x),
                windowDraggingEventInitY - (windowDraggingEventCursorInitY - y),
            )
        );
    }

    Tuple!(int, string) getPlatformError()
    {
        throw new Exception("abstract");
    }

    Tuple!(int, string) printPlatformError()
    {
        auto res = getPlatformError();
        return printPlatformError(res);
    }

    Tuple!(int, string) printPlatformError(Tuple!(int, string) input)
    {
        if (input[0] == 0)
        {
            writeln(
                "Platform Error (0) Message: %s".format(
                    (input[1].length == 0 ? "No Error" : input[1])
                )
            );
        }
        else
        {
            writeln("Platform Error (%s) Message: %s".format(input[0], input[1]));
        }
        return input;
    }

    Position2D getMouseCursorPosition()
    {
        throw new Exception("abstract");
    }

    // WindowDecorationI calcArtificalWD()
    // {
    //     if (getPrefere)
    // }

}
