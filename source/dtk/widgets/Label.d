module dtk.widgets.Label;

import std.typecons;

import dtk.types.Property;
import dtk.types.Size2D;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class Label : Widget, ContainerableWidgetI
{
    private
    {
        mixin Property_gs!(string, "text");
    }

    mixin Property_forwarding!(string, text, "Text");

    override void redraw()
    {
        this.redraw_x(this);
    }
}
