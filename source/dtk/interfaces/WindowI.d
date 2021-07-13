module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Point;
import dtk.types.Size;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;

interface WindowI
{
    PlatformI getPlatform();

    void installForm(FormI form);
    void uninstallForm();

    void setForm(FormI form);
    FormI getForm();

    DrawingSurfaceI getDrawingSurface();

    Point getPoint();
    Tuple!(bool, Point) setPoint(Point point);

    Size getSize();
    Tuple!(bool, Size) setSize(Size size);

    Point getFormPoint();
    Size getFormSize();

    string getTitle();
    void setTitle(string value);
}
