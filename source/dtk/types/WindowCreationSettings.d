module dtk.types.WindowCreationSettings;

import std.typecons;

import dtk.interfaces.LaFI;

import dtk.types.Position2D;
import dtk.types.Size2D;

struct WindowCreationSettings
{
    dstring title;

    // LaFI laf;

    bool posDefined;
    int x, y;

    bool sizeDefined;
    int w, h;

    bool fullscreen;
    bool fullscreen_desktop;


    // TODO: probably some interface have to be made to pass options specific to platform
    // Nullable!bool opengl;
    // Nullable!bool vulkan;
    // Nullable!bool metal;

    bool visible;
    bool borderless;
    bool resizable;
    bool minimized;
    bool maximized;
    bool inputGrabbed;
    bool allowHighdpi;
    bool popupMenu;
}
