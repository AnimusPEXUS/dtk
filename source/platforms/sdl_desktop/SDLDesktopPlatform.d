module dtk.platforms.sdl_desktop.SDLDesktopPlatform;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;

import dtk.platforms.sdl_desktop.Window;

class SDLDesktopPlatform : PlatformI
{
    string getName()
    {
        return "SDL-Desktop";
    }

    string getDescription()
    {
        return "DTK (D ToolKit). on SDL Platform";
    }

    string getSystemTriplet()
    {
        return "x86_64-pc-linux-gnu"; // TODO: fix this
    }

    bool canCreateWindow()
    {
        return true;
    }

    WindowI createWindow()
    {
        auto w = new Window();
        return w;
    }

    int mainLoop()
    {
        return 1;
    }
}
