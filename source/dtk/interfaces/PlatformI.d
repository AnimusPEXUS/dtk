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
    
    void setOnGetLaf(LafI delegate());
    LafI getLaf();
    
    FontMgrI getFontManager();
    
    bool canCreateWindow();
    WindowI createWindow(WindowCreationSettings window_settings);
    
    void addWindow(WindowI win);
    void removeWindow(WindowI win);
    bool haveWindow(WindowI win);
    
    bool getFormCanResizeWindow();
    
    void init();
    void mainLoop();
    void destroy();
    
    mixin(mixin_PlatformSignals(true));
}
