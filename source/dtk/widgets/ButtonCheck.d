module dtk.widgets.ButtonCheck;

import std.stdio;
import std.typecons;

import dtk.interfaces.WidgetI;
import dtk.interfaces.ContainerI;

import dtk.types.EventMouse;
import dtk.types.EventForm;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;

import dtk.widgets.Button;
import dtk.widgets.Form;
import dtk.widgets.Widget;

import dtk.widgets.mixins;


const auto ButtonCheckProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "bool", "checked", "Checked", "false"),
];


class ButtonCheck : Button, WidgetI
{
	
	mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
	mixin mixin_multiple_properties_define!(ButtonCheckProperties);
    mixin mixin_multiple_properties_forward!(ButtonCheckProperties, false);
    mixin mixin_Widget_renderImage!("ButtonCheck");
    mixin mixin_widget_redraw_using_propagateRedraw!();
    mixin mixin_propagateRedraw_children_none!();
    
    mixin mixin_forward_super_functions!(
    	[
    	"getForm",
    	"getNextFocusableWidget",
    	"getPrevFocusableWidget",
    	"propagatePosAndSizeRecalc",
    	"getChildAtPosition",
    	"getDrawingSurface"
    	]
    	);

    mixin mixin_propagateParentChangeEmision!();

    this()
    {
    	mixin(mixin_multiple_properties_inst(ButtonCheckProperties));
    	
    	// mixin(mixin_propagateParentChangeEmision_this());
        // setMouseHandler("button-click", &on_mouse_click_internal);
        // setMouseHandler("button-down", &on_mouse_down_internal);
        // setMouseHandler("button-up", &on_mouse_up_internal);
    }
    
    void on_mouse_click_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        setChecked(!getChecked());
        redraw();
        return ;
    }
    
    void on_mouse_down_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        auto f = getForm();
        if (f !is null)
        {
            f.focusTo(this);
        }
        
        redraw();
        return ;
    }
    
    void on_mouse_up_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        return ;
    }

    override Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI)this, point);
    }
    
    override void focusEnter(WidgetI widget) {};
    override void focusExit(WidgetI widget) {};
    
    override void visualActivationStart(WidgetI widget, EventForm* event) {};
    override void visualReset(WidgetI widget, EventForm* event) {};
    
    override void intMousePress(WidgetI widget, EventForm* event) {};
    override void intMouseRelease(WidgetI widget, EventForm* event) {};
    override void intMouseLeave(WidgetI old_w, WidgetI new_w, EventForm* event) {};
    override void intMouseEnter(WidgetI old_w, WidgetI new_w, EventForm* event) {};
    override void intMouseMove(WidgetI widget, EventForm* event) {};

}
