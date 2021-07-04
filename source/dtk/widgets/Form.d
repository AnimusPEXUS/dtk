// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Size;
import dtk.types.Theme;

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

    DrawingSurfaceI getDrawingSurface()
    {
        return _drawing_surface;
    }

    Theme getTheme()
    {
        return _theme;
    }

    void setTheme(Theme theme)
    {
        _theme = theme;
    }

    void Resize(uint width, uint height)
    {

    }

    /* @property void visible(bool value)
    {
        _visible = value;
    }

    @property bool visible()
    {
        return _visible;
    } */

    void setParent(WidgetI widget)
    {
    }

    void unsetParent()
    {
    }

    FormI getForm()
    {
        return this;
    }

    Size calculateSize()
    {
        return Size();
    }

    void calculateChildrenPositions()
    {
    }

    void redraw()
    {
    }

}
