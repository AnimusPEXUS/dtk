module dtk.interfaces.PlatformI;

interface PlatformI
{
    string getName();
    string getDescription();
    string getSystemTriplet();
    bool canCreateWindow();
    WindowI createWindow();
}
