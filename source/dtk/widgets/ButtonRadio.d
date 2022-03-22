module dtk.widgets.ButtonRadio;

import std.stdio;
import std.exception;
import std.typecons;

import observable.signal;

import dtk.interfaces.WidgetI;
import dtk.interfaces.ContainerI;

import dtk.types.EventMouse;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.EventForm;

import dtk.miscs.RadioGroup;

import dtk.widgets.Widget;
import dtk.widgets.Button;
import dtk.widgets.Form;
import dtk.widgets.mixins;


const auto ButtonRadioProperties = cast(PropSetting[]) [
PropSetting("gsun", "RadioGroup", "radio_group", "RadioGroup", "null"),
PropSetting("gs_w_d", "bool", "checked", "Checked", "false"),
];


class ButtonRadio : Button, WidgetI
{
	private {
    	SignalConnectionContainer con_cont;
    }
    
	mixin mixin_multiple_properties_define!(ButtonRadioProperties);
    mixin mixin_multiple_properties_forward!(ButtonRadioProperties, false);
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("ButtonRadio");
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
    	mixin(mixin_multiple_properties_inst(ButtonRadioProperties));
    	
        // setMouseHandler("button-click", &on_mouse_click_internal);
        // setMouseHandler("button-down", &on_mouse_down_internal);
        // setMouseHandler("button-up", &on_mouse_up_internal);
        
        // mixin(mixin_propagateParentChangeEmision_this());
        
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
    
    override void focusEnter(Form form, WidgetI widget)
    {}
    override void focusExit(Form form, WidgetI widget) 
    {}

    override bool isVisualPressed()
    {return false;}
    override void visualPress(Form form, WidgetI widget, EventForm* event)
    {}
    override void visualRelease(Form form, WidgetI widget, EventForm* event)
    {}

    override void intMousePress(Form form, WidgetI widget, EventForm* event)
    {
        redraw();
    }
    override void intMouseRelease(Form form, WidgetI widget, EventForm* event)
    {
    	
    }
    override void intMouseClick(Form form, WidgetI widget, EventForm* event) 
    {
    	auto rg = getRadioGroup();
        if (rg !is null)
        {
            rg.selectButton(this);
        }
        redraw();
    }
    override void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {}
    override void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {}
    override void intMouseMove(Form form, WidgetI widget, EventForm* event)
    {}
    
}
