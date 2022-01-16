module dtk.interfaces.PlatformI;


import dtk.interfaces.WindowI;
import dtk.interfaces.LafI;
import dtk.interfaces.FontMgrI;

import dtk.types.WindowCreationSettings;
import dtk.types.Event;

import dtk.miscs.signal_tools;

import dtk.signal_mixins.Platform;


interface PlatformI
{
    string getName();
    string getDescription();
    string getSystemTriplet();

    LafI getLaf();
    PlatformI setLaf(LafI);
    PlatformI unsetLaf();

    FontMgrI getFontManager();

    bool canCreateWindow();
    WindowI createWindow(WindowCreationSettings window_settings);

    bool getFormCanResizeWindow();
    
    void init();
    void mainLoop();
    void destroy();
    
    mixin(mixin_PlatformSignals(true));
    
    //SignalConnection connectToSignal_Timer500( void delegate() nothrow );
    //SignalConnection connectToSignal_Event( void delegate(Event*) nothrow );
}
