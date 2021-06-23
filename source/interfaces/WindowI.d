module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Point;
import dtk.types.Size;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;

interface WindowI
{
    DrawingSurfaceI getDrawingSurface();
    void setForm(FormI form);
    FormI getForm();

    Point getPoint();
    Tuple!(bool, Point) setPoint(Point point);

    Size getSize();
    Tuple!(bool, Size) setSize(Size size);

    Point getFormPoint();
    Size getFormSize();

    string getTitle();
    void setTitle(string value);

}
