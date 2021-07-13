// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import std.stdio;
import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerableWidgetI;

import dtk.types.Point;
import dtk.types.Size;
import dtk.types.Theme;
import dtk.types.LineStyle;
import dtk.types.FillStyle;

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
    }

    mixin mixin_child!("0");

    void setWindow(WindowI win)
    {
        this._window = win;
    }

    void unsetWindow()
    {
        this._window = null;
    }

    void setSize(Size s)
    {
        this._size = s;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        if (_drawing_surface is null)
        {
            assert(_window !is null);
            _drawing_surface = _window.getDrawingSurface();
        }
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
        auto ds = this.getDrawingSurface();
        assert(ds !is null);
        writeln("sd == ",ds);
        ds.DrawRectangle(
            Point(0,0),
            this._size,
            LineStyle(),
            LineStyle(),
            LineStyle(),
            LineStyle(),
            FillStyle()
            );
    }

}
