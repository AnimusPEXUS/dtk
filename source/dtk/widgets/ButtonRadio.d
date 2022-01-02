module dtk.widgets.ButtonRadio;

import std.stdio;
import std.exception;

import observable.signal;

import dtk.types.EventMouse;
import dtk.types.Property;

import dtk.miscs.RadioGroup;

import dtk.widgets.Button;

class ButtonRadio : Button
{
	private {
    	SignalConnectionContainer con_cont;
    }
    
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
        // setFocusable(true);
        
        setMouseEvent("button-click", &on_mouse_click_internal);
        setMouseEvent("button-down", &on_mouse_down_internal);
        setMouseEvent("button-up", &on_mouse_up_internal);
        
        con_cont.add(connectToRadioGroup_onBeforeChanged(&handleRadioGroup_onBeforeChanged));
        con_cont.add(connectToRadioGroup_onAfterChanged(&handleRadioGroup_onAfterChanged));
    }

    private void handleRadioGroup_onBeforeChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
        
        collectException({
            if (old_v !is null)
                if (old_v.isIn(this))
                    old_v.remove(this);
        }());
        
    }

    private void handleRadioGroup_onAfterChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
        
        collectException({
            if (new_v !is null)
                if (!new_v.isIn(this))
                    new_v.add(this);
        }());
    }

    override void on_mouse_click_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        auto rg = getRadioGroup();
        if (rg !is null)
        {
            rg.selectButton(this);
        }
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

        redraw();
        return ;
    }

    override void on_mouse_up_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        return ;
    }

    override void redraw()
    {
    	if (getForm() is null)
    		return;
        this.redraw_x(this);
    }

}
