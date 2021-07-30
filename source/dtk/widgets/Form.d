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
import dtk.types.Property;

import dtk.widgets.mixins;
import dtk.widgets.Widget;

class Form : Widget, FormI
{
    private
    {
        mixin Property_gsu!(WindowI, "window");
        mixin Property_gs!(Theme, "theme");
        mixin Property_gsu!(DrawingSurfaceI, "drawing_surface");
    }

    mixin Property_forwarding!(WindowI, window, "Window");
    mixin Property_forwarding!(Theme, theme, "Theme");
    mixin Property_forwarding!(DrawingSurfaceI, drawing_surface, "DrawingSurface");

    override void setParent(WidgetI widget)
    {
        return;
    }

    override void unsetParent()
    {
        return;
    }

    override WidgetI getParent()
    {
        return null;
    }

    override Form getForm()
    {
        return this;
    }

    Size calculateSizesAndPositions(Size size)
    {
        return Size();
    }

    override void redraw()
    {
        writeln("Form redraw() requested");
        auto ds = this.getDrawingSurface();
        assert(ds !is null);
        auto size = this.locator.getCalculatedSize();
        writeln("sd == ",ds);
        ds.DrawRectangle(
            Point(0,0),
            size,
            LineStyle(),
            LineStyle(),
            LineStyle(),
            LineStyle(),
            FillStyle()
            );
    }

    void onWindowResize(){}

}
