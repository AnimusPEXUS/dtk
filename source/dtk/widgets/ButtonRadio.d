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
        connectToRadioGroup_onBeforeChanged(&handleRadioGroup_onBeforeChanged);
        connectToRadioGroup_onAfterChanged(&handleRadioGroup_onAfterChanged);
    }

    private void handleRadioGroup_onBeforeChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
        try
        {
            writeln("handleRadioGroup_onBeforeChanged: ", old_v, new_v);
            if (old_v !is null)
                if (old_v.isIn(this))
                    old_v.remove(this);
        }
        catch (Exception e)
        {

        }
    }

    private void handleRadioGroup_onAfterChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
        try
        {
            writeln("handleRadioGroup_onAfterChanged: ", old_v, new_v);
            if (new_v !is null)
                if (!new_v.isIn(this))
                    new_v.add(this);
        }
        catch (Exception e)
        {

        }
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
        if (f !is null)
        {
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

    override void redraw()
    {
        this.redraw_x(this);
    }

}
