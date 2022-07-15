module dtk.interfaces.PlatformI;

import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.LaFI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.MouseCursorMgrI;
import dtk.interfaces.WindowDecorationI;

import dtk.types.WindowCreationSettings;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.Widget;
import dtk.types.Position2D;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;
import dtk.types.EnumWindowDraggingEventEndReason;
import dtk.types.ArtificalWDSpawner;


import dtk.miscs.signal_tools;

import dtk.signal_mixins.Platform;

interface PlatformI
{
    string getName();
    string getDescription();

    typeof(this) setOnGetLaf(LaFI delegate());
    LaFI getLaf();

    FontMgrI getFontManager();
    MouseCursorMgrI getMouseCursorManager();
    Position2D getMouseCursorPosition();

    typeof(this) setPrefereArtificalWD(bool val);
    bool getPrefereArtificalWD();

    typeof(this) setPreferedArtificalWDSpawner(ArtificalWDSpawner wds);
    ArtificalWDSpawner getPreferedArtificalWDSpawner();

    // WindowDecorationI calcArtificalWD();

    bool canCreateWindow();

    WindowI createWindow(WindowCreationSettings window_settings);

    void addWindow(WindowI win);
    void removeWindow(WindowI win);
    bool haveWindow(WindowI win);

    bool getFormCanResizeWindow();

    // void init();
    void mainLoop();
    void destroy();

    void widgetInternalDraggingEventStart(
        Widget e,
        int initX, int
        initY,
        EnumWidgetInternalDraggingEventEndReason
            delegate(Event* e) widgetInternalDraggingStopCheck
        );
    void widgetInternalDraggingEventEnd(
        Event* e,
        EnumWidgetInternalDraggingEventEndReason reason
        );

    void windowDraggingEventStart(
        WindowI window,
        EnumWindowDraggingEventEndReason
            delegate(Event* e) windowDraggingEventStopCheck
        );
    void windowDraggingEventEnd(
        Event* e,
        EnumWindowDraggingEventEndReason reason
        );

    Tuple!(int, string) getPlatformError();
    Tuple!(int, string) printPlatformError();
    Tuple!(int, string) printPlatformError(Tuple!(int, string) input);

    mixin(mixin_PlatformSignals(true));
}
