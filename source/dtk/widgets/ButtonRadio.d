module dtk.widgets.ButtonRadio;

import std.stdio;

import dtk.types.EventMouse;
import dtk.types.Property;

import dtk.miscs.RadioGroup;

import dtk.widgets;

class ButtonRadio : Button
{
    private
    {
        mixin Property_gsun!(RadioGroup, "radio_group");
        mixin Property_gs_w_d!(bool, "checked", false);
    }

    mixin Property_forwarding!(RadioGroup, radio_group, "RadioGroup");
    mixin Property_forwarding!(bool, checked, "Checked");

    /* public bool checked; */

    this()
    {
        setFocusable(true);
    }

    override bool on_mouse_click_internal(EventMouse* event)
    {
        writeln("ButtonRadio click");
        auto rg = getRadioGroup();
        if (rg !is null)
        {
            rg.selectButton(this);
        }
        redraw();
        return false;
    }

    override bool on_mouse_down_internal(EventMouse* event)
    {
        auto f = getForm();
        if (f !is null){
            f.focusTo(this);
        }

        writeln("ButtonRadio down");
        redraw();
        return false;
    }

    override bool on_mouse_up_internal(EventMouse* event)
    {
        writeln("ButtonRadio up");
        return false;
    }



}
