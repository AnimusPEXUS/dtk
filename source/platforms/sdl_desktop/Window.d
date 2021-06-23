module dtk.platforms.sdl_desktop.Window;

import std.typecons;

import bindbc.sdl;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;

import dtk.platforms.sdl_desktop.DrawingSurface;

import dtk.types.Point;
import dtk.types.Size;

class Window : WindowI
{
    private
    {
        SDL_Window* _window;

        DrawingSurface _drawing_surface;

        FormI _form;

        Point _point;
        Size _size;

        Point _form_point;
        Size _form_size;

        string _title;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        return _drawing_surface;
    }

    void setForm(FormI form)
    {
        _form = form;
    }

    FormI getForm()
    {
        return _form;
    }

    Point getPoint()
    {
        return _point;
    }

    Tuple!(bool, Point) setPoint(Point point)
    {
        _point = point;
        return tuple(true, _point);
    }

    Size getSize()
    {
        return _size;
    }

    Tuple!(bool, Size) setSize(Size size)
    {
        _size = size;
        return tuple(true, _size);
    }

    Point getFormPoint()
    {
        return _form_point;
    }

    Size getFormSize()
    {
        return _form_size;
    }

    string getTitle()
    {
        return _title;
    }

    void setTitle(string title)
    {
        _title = title;
    }

}
