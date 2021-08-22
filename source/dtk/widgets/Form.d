// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import observable.signal;

import std.stdio;
import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.ThemeI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerableWidgetI;

import dtk.types.Position2D;
import dtk.types.Size2D;
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
        mixin Property_gsu!(ThemeI, "theme");
        mixin Property_gsu!(DrawingSurfaceI, "drawing_surface");
        mixin Property_gsu!(ContainerableWidgetI, "child");

        SignalConnection onwindowchanged_sc;
    }

    mixin Property_forwarding!(WindowI, window, "Window");
    mixin Property_forwarding!(ThemeI, theme, "Theme");
    mixin Property_forwarding!(DrawingSurfaceI, drawing_surface, "DrawingSurface");
    mixin Property_forwarding!(ContainerableWidgetI, child, "Child");

    this()
    {
        // window.onAfterChanged.socket.connect(onwindowchanged_sc, &onwindowchanged);
    }

    /* private nothrow void onwindowchanged()
    {
        try {
            writeln("onwindowchanged()");
        } catch (Exception e) {
            // TODO:
        }
    } */

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

    void onWindowResize(){
        redraw();
    }

    override void redraw() {
        super.redraw();
    }


}
