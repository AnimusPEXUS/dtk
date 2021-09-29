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
        mixin Property_gs_w_d!(ushort, "font_size",9);
        mixin Property_gs_w_d!(bool, "font_italic",false);
        mixin Property_gs_w_d!(bool, "font_bold",false);
    }

    mixin Property_forwarding!(string, text, "Text");
    mixin Property_forwarding!(ushort, font_size, "FontSize");
    mixin Property_forwarding!(bool, font_italic, "FontItalic");
    mixin Property_forwarding!(bool, font_bold, "FontBold");

    override void redraw()
    {
        this.redraw_x(this);
    }
}
