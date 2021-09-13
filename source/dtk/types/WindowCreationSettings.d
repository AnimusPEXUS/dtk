module dtk.types.WindowCreationSettings;

import std.typecons;

import dtk.interfaces.LafI;

import dtk.types.Position2D;
import dtk.types.Size2D;

struct WindowCreationSettings
{
    string title;

    LafI laf;

    Nullable!Position2D position;
    Nullable!Size2D size;

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
