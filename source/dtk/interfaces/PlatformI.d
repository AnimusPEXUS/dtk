module dtk.interfaces.PlatformI;

import dtk.interfaces.WindowI;
import dtk.interfaces.ThemeI;

import dtk.types.WindowCreationSettings;

interface PlatformI
{
    string getName();
    string getDescription();
    string getSystemTriplet();

    ThemeI getTheme();
    void setTheme(ThemeI);
    void unsetTheme();

    bool canCreateWindow();
    WindowI createWindow(WindowCreationSettings window_settings);

    bool getFormCanResizeWindow();

    void init();
    void mainLoop();
    void destroy_();
}
