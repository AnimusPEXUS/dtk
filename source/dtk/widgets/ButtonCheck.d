module dtk.widgets.ButtonCheck;

import std.stdio;
import std.typecons;

// import dtk.interfaces.LaFI;
// import dtk.interfaces.Widget;
// import dtk.interfaces.ContainerI;

import dtk.types.EventMouse;
import dtk.types.EventForm;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Widget;

import dtk.widgets.Button;
import dtk.widgets.Form;

import dtk.widgets.mixins;


const auto ButtonCheckProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "bool", "toggledOn", "ToggledOn", "false"),
];


class ButtonCheck : Widget
{
	
	// mixin mixin_multiple_properties_forward!(WidgetProperties, true);
	mixin mixin_multiple_properties_define!(ButtonCheckProperties);
    mixin mixin_multiple_properties_forward!(ButtonCheckProperties, false);
    mixin mixin_Widget_renderImage!("ButtonCheck");
    

    this()
    {
    	super(0, 1);
    	mixin(mixin_multiple_properties_inst(ButtonCheckProperties));
    }
    
    override void intMousePressRelease(Form form, Widget widget, EventForm* event) 
    {
    	setToggledOn(!getToggledOn());
        redraw();
    }
}
