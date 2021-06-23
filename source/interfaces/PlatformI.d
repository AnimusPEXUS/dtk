module dtk.interfaces.PlatformI;

import dtk.interfaces.WindowI;

interface PlatformI
{
    string getName();
    string getDescription();
    string getSystemTriplet();

    bool canCreateWindow();
    WindowI createWindow();

    int mainLoop();
}
