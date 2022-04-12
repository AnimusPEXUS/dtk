module dtk.widgets.ButtonCheck;

import std.stdio;
import std.typecons;

// import dtk.interfaces.LaFI;
// import dtk.interfaces.WidgetI;
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

/*     override Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI)this, point);
    }
    
    override void focusEnter(Form form, WidgetI widget)
    {}
    override void focusExit(Form form, WidgetI widget) 
    {}

    override bool isVisuallyPressed()
    {return false;}
    override void visualPress(Form form, WidgetI widget, EventForm* event)
    {
    	
    }
    
    override void visualRelease(Form form, WidgetI widget, EventForm* event)
    {}

    override void intMousePress(Form form, WidgetI widget, EventForm* event)
    {
    }
    
    override void intMouseRelease(Form form, WidgetI widget, EventForm* event)
    {}
    
    override void intMousePressRelease(Form form, WidgetI widget, EventForm* event) 
    {
    	setChecked(!getChecked());
        redraw();
    }
    
    override void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {}
    
    override void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {}
    
    override void intMouseMove(Form form, WidgetI widget, EventForm* event)
    {}

         
    override void intKeyboardPress(Form form, WidgetI widget, EventForm* event) {}
    override void intKeyboardRelease(Form form, WidgetI widget, EventForm* event) {}
    
    override void intTextInput(Form form, WidgetI widget, EventForm* event) {} */
}
