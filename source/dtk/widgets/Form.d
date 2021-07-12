// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import std.stdio;

import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerableWidgetI;

import dtk.types.Size;
import dtk.types.Theme;

import dtk.widgets.mixins;

class Form : FormI, WidgetI
{
    private
    {
        /* bool _visible; */
        WindowI _window;
        Size _size;
        Theme _theme;
        DrawingSurfaceI _drawing_surface;
        ContainerableWidgetI child;
    }

    mixin mixin_getWidgetType!"Form";

    DrawingSurfaceI getDrawingSurface()
    {
        return _drawing_surface;
    }

    void setParent(WidgetI widget)
    {
        return;
    }

    void nullifyParent()
    {
        return;
    }

    WidgetI getParent()
    {
        return null;
    }

    Theme getTheme()
    {
        return _theme;
    }

    void setTheme(Theme theme)
    {
        _theme = theme;
    }

    FormI getForm()
    {
        return this;
    }

    Size calculateSizesAndPositions(Size size)
    {
        return Size();
    }

    void redraw()
    {
        writeln("Form redraw() requested");
    }

}
