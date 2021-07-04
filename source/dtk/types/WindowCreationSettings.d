module dtk.types.WindowCreationSettings;

import std.typecons;

import dtk.types.Point;
import dtk.types.Size;

/* import dtk.types.UndefinedNoYes; */

struct WindowCreationSettings
{
    string title;

    Nullable!Point position;
    Nullable!Size size;

    Nullable!bool fullscreen;
    Nullable!bool fullscreen_desktop;

    // TODO: probably some interface have to be made to pass options specific to platform
    Nullable!bool opengl;
    Nullable!bool vulkan;
    Nullable!bool metal;
    Nullable!bool hidden;
    Nullable!bool borderless;
    Nullable!bool resizable;
    Nullable!bool minimized;
    Nullable!bool maximized;
    Nullable!bool input_grabbed;
    Nullable!bool allow_highdpi;
}
