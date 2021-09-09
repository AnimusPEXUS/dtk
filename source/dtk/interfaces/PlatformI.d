module dtk.interfaces.PlatformI;

import dtk.interfaces.WindowI;
import dtk.interfaces.LafI;

import dtk.types.WindowCreationSettings;

interface PlatformI
{
    string getName();
    string getDescription();
    string getSystemTriplet();

    LafI getLaf();
    void setLaf(LafI);
    void unsetLaf();

    bool canCreateWindow();
    WindowI createWindow(WindowCreationSettings window_settings);

    bool getFormCanResizeWindow();

    void init();
    void mainLoop();
    void destroy();
}
