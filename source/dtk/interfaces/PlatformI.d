module dtk.interfaces.PlatformI;

import observable.signal;

import dtk.interfaces.WindowI;
import dtk.interfaces.LafI;
import dtk.interfaces.FontMgrI;

import dtk.types.WindowCreationSettings;

interface PlatformI
{
    string getName();
    string getDescription();
    string getSystemTriplet();

    LafI getLaf();
    void setLaf(LafI);
    void unsetLaf();

    FontMgrI getFontManager();

    bool canCreateWindow();
    WindowI createWindow(WindowCreationSettings window_settings);

    bool getFormCanResizeWindow();
    
    void init();
    void mainLoop();
    void destroy();
    
    SignalConnection connectTo_Timer500( void delegate() nothrow );
}
