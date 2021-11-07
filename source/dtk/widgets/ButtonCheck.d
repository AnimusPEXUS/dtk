module dtk.widgets.ButtonCheck;

import std.stdio;

import dtk.types.EventMouse;
import dtk.types.Property;

import dtk.widgets;

class ButtonCheck : Button
{
    private
    {
        mixin Property_gs_w_d!(bool, "checked", false);
    }

    mixin Property_forwarding!(bool, checked, "Checked");

    this()
    {
        setFocusable(true);
        
        setMouseEvent("button-click", &on_mouse_click_internal);
        setMouseEvent("button-down", &on_mouse_down_internal);
        setMouseEvent("button-up", &on_mouse_up_internal);
    }

    override void on_mouse_click_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        debug writeln("ButtonCheck click");
        setChecked(!getChecked());
        redraw();
        return ;
    }

    override void on_mouse_down_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        auto f = getForm();
        if (f !is null)
        {
            f.focusTo(this);
        }

        debug writeln("ButtonCheck down");
        redraw();
        return ;
    }

    override void on_mouse_up_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        debug writeln("ButtonCheck up");
        return ;
    }

    override void redraw()
    {
        this.redraw_x(this);
    }

}
