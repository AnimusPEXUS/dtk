module dtk.widgets.ButtonRadio;

import std.stdio;
import std.exception;
import std.typecons;

import observable.signal;

// import dtk.interfaces.WidgetI;
// import dtk.interfaces.ContainerI;

import dtk.types.EventMouse;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.EventForm;
import dtk.types.Widget;

import dtk.miscs.RadioGroup;

// import dtk.widgets.Widget;
import dtk.widgets.Button;
import dtk.widgets.Form;
import dtk.widgets.mixins;


const auto ButtonRadioProperties = cast(PropSetting[]) [
PropSetting("gsun", "RadioGroup", "radio_group", "RadioGroup", "null"),
PropSetting("gs_w_d", "bool", "toggledOn", "ToggledOn", "false"),
];


class ButtonRadio : Widget
{
	private {
    	SignalConnectionContainer con_cont;
    }
    
	mixin mixin_multiple_properties_define!(ButtonRadioProperties);
    mixin mixin_multiple_properties_forward!(ButtonRadioProperties, false);
    mixin mixin_Widget_renderImage!("ButtonRadio");
    
    this()
    {
    	super(0, 1);
    	mixin(mixin_multiple_properties_inst(ButtonRadioProperties));
    	
        con_cont.add(connectToRadioGroup_onBeforeChanged(&handleRadioGroup_onBeforeChanged));
        con_cont.add(connectToRadioGroup_onAfterChanged(&handleRadioGroup_onAfterChanged));
    }
    
    private void handleRadioGroup_onBeforeChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
    	
        collectException(
        	{
        		if (old_v !is null)
        			if (old_v.isIn(this))
                    old_v.remove(this);
            }()
            );
    }
    
    private void handleRadioGroup_onAfterChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
    	
        collectException(
        	{
        		if (new_v !is null)
        			if (!new_v.isIn(this))
                    new_v.add(this);
            }()
            );
    }
    
    // override void focusEnter(Form form, WidgetI widget)
    // {}
    // override void focusExit(Form form, WidgetI widget) 
    // {}
// 
    // override bool isVisuallyPressed()
    // {return false;}
    // override void visualPress(Form form, WidgetI widget, EventForm* event)
    // {}
    // override void visualRelease(Form form, WidgetI widget, EventForm* event)
    // {}
// 
    // override void intMousePress(Form form, WidgetI widget, EventForm* event)
    // {
        // redraw();
    // }
    // override void intMouseRelease(Form form, WidgetI widget, EventForm* event)
    // {
    	// 
    // }
    // override void intMousePressRelease(Form form, WidgetI widget, EventForm* event) 
    // {
    	// auto rg = getRadioGroup();
        // if (rg !is null)
        // {
            // rg.selectButton(this);
        // }
        // redraw();
    // }
    // override void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    // {}
    // override void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    // {}
    // override void intMouseMove(Form form, WidgetI widget, EventForm* event)
    // {}
    // 
         // 
    // override void intKeyboardPress(Form form, WidgetI widget, EventForm* event) {}
    // override void intKeyboardRelease(Form form, WidgetI widget, EventForm* event) {}
    // 
    // override void intTextInput(Form form, WidgetI widget, EventForm* event) {}
    
}
