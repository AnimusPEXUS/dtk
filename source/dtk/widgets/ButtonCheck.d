module dtk.widgets.ButtonCheck;

import std.stdio;

import dtk.types.EventMouse;
import dtk.types.Property;

import dtk.widgets.Button;

const auto ButtonCheckProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "bool", "checked", "Checked", "null"),
];


class ButtonCheck : Button
{

	mixin mixin_multiple_properties_define!(ButtonCheckProperties);
    mixin mixin_multiple_properties_forward!(ButtonCheckProperties);
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(ButtonCheckProperties));
        
        setMouseEvent("button-click", &on_mouse_click_internal);
        setMouseEvent("button-down", &on_mouse_down_internal);
        setMouseEvent("button-up", &on_mouse_up_internal);
    }

    override void on_mouse_click_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
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

        redraw();
        return ;
    }

    override void on_mouse_up_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        return ;
    }

    override void redraw()
    {
        this.redraw_x(this);
    }

}
