/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.stdio;
import std.datetime;
import std.typecons;
import std.exception;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Event;

import dtk.widgets.Widget;
import dtk.widgets.Form;
import dtk.widgets.mixins;

import dtk.miscs.RadioGroup;
import dtk.miscs.signal_tools;
// import dtk.miscs.formEventFilter;

/// Button class
class Button : Widget, WidgetI
{
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("Button");
    mixin mixin_widget_redraw_using_propagateRedraw!();
    mixin mixin_propagateRedraw_children_none!();

    bool button_is_down;
    
    private 
    {
    	SignalConnection sc_parentChange;
    	SignalConnection sc_formEvent;
    }
    
    // mixin mixin_getWidgetAtPosition;
    mixin mixin_forward_super_functions!(
    	[
    	"getForm",
    	"getNextFocusableWidget",
    	"getPrevFocusableWidget",
    	"getChildAtPosition",
    	"getDrawingSurface"
    	]
    	);
    
    mixin mixin_propagateParentChangeEmision!();
    
    this()
    {
    	
    }
    
    override void propagatePosAndSizeRecalc()
	{
	}    
	
    override void focusEnter(Form form, WidgetI widget)
    {}
    override void focusExit(Form form, WidgetI widget) 
    {}
    
    override bool isVisualPressed()
    {
    	return button_is_down;
    }
    override void visualPress(Form form, WidgetI widget, EventForm* event)
    {
    	button_is_down=true;
    	redraw();
    }
    override void visualRelease(Form form, WidgetI widget, EventForm* event)
    {
    	button_is_down=false;
    	redraw();
    }
    
    override void intMousePress(Form form, WidgetI widget, EventForm* event)
    {
    }
    override void intMouseRelease(Form form, WidgetI widget, EventForm* event)
    {
    }
    override void intMouseClick(Form form, WidgetI widget, EventForm* event) 
    {debug writeln("click");}
    override void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {
    }
    override void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {
    }
    override void intMouseMove(Form form, WidgetI widget, EventForm* event)
    {}
    
}
