// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import std.stdio;
import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.ThemeI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerableWidgetI;

import dtk.types.Point;
import dtk.types.Size;
/* import dtk.types.Theme; */
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
        mixin Property_gs!(ThemeI, "theme");
        mixin Property_gsu!(DrawingSurfaceI, "drawing_surface");
    }

    mixin Property_forwarding!(WindowI, window, "Window");
    mixin Property_forwarding!(ThemeI, theme, "Theme");
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

    void onWindowResize(){}

}
