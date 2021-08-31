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
        /* mixin Property_gsu!(DrawingSurfaceI, "drawing_surface"); */
        mixin Property_gsu!(ContainerableWidgetI, "child");

        mixin Property_gsu!(WidgetI, "focused_widget");

    }

    mixin Property_forwarding!(WindowI, window, "Window");
    mixin Property_forwarding!(ThemeI, theme, "Theme");
    /* mixin Property_forwarding!(DrawingSurfaceI, drawing_surface, "DrawingSurface"); */
    mixin Property_forwarding!(ContainerableWidgetI, child, "Child");

    mixin Property_forwarding!(WidgetI, focused_widget, "FocusedWidget");

    private
    {

    }

    this()
    {
        connectToChild_onAfterChanged(&onChildChanged);
    }

    void onChildChanged() nothrow
    {
        try {
            writeln("Form child changed");
            auto c = getChild();
            c.setParent(this);
            /* c.setPosition(Position2D(5,5));
            auto = this_size
            c.setSize(Size2D()); */
            this.recalculateChildrenPositionsAndSizes();
        } catch (Exception e) {

        }

    }

    override DrawingSurfaceI getDrawingSurface()
    {
        DrawingSurfaceI ret = null;
        if (isSetWindow())
            ret = getWindow().getDrawingSurface();
        return ret;
    }

    /* private nothrow void onwindowchanged()
    {
        try {
            writeln("onwindowchanged()");
        } catch (Exception e) {
            // TODO:
        }
    } */

    override typeof(this) setParent(WidgetI widget)
    {
        return null;
    }

    override typeof(this) unsetParent()
    {
        return null;
    }

    override WidgetI getParent()
    {
        return null;
    }

    override Form getForm()
    {
        return this;
    }

    override void positionAndSizeRequest(Position2D position, Size2D size)
    {
        super.positionAndSizeRequest(position, size);
        this.recalculateChildrenPositionsAndSizes();
    }

    override void recalculateChildrenPositionsAndSizes()
    {
        auto position = getPosition();
        auto size = getSize();
        if (isSetChild()) {
            auto c = getChild();
            c.positionAndSizeRequest(
                Position2D(position.x+5, position.y+5),
                Size2D(size.width-10, size.height-10)
                );
        }
    }


    override void redraw() {
        super.redraw();

        if (isSetChild()) {
            writeln("getChild().redraw();");
            getChild().redraw();
        }

        auto ds = getDrawingSurface();
        ds.present();
    }

    mixin mixin_getWidgetAtVisible;

    WidgetI focusNextWidget()
    {
        return this;
    }
    WidgetI focusPrevWidget()
    {
        return this;
    }


}
