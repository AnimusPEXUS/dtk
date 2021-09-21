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
    }


    override bool on_mouse_click_internal(EventMouse* event)
    {
        writeln("ButtonCheck click");
        setChecked(!getChecked());
        redraw();
        return false;
    }

    override bool on_mouse_down_internal(EventMouse* event)
    {
        auto f = getForm();
        if (f !is null){
            f.focusTo(this);
        }

        writeln("ButtonCheck down");
        redraw();
        return false;
    }

    override bool on_mouse_up_internal(EventMouse* event)
    {
        writeln("ButtonCheck up");
        return false;
    }

}
