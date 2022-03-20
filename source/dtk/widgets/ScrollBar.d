module dtk.widgets.ScrollBar;

import std.typecons;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;

import dtk.types.Property;
import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Event;

import dtk.widgets.Widget;
import dtk.widgets.Form;
import dtk.widgets.mixins;

class ScrollBar : Widget, WidgetI
{
	
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("ScrollBar");
    
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
    mixin mixin_widget_redraw_using_propagateRedraw!();
    mixin mixin_propagateRedraw_children_none!();    

    mixin mixin_propagateParentChangeEmision!();
    
    this()
    {
    	// mixin(mixin_propagateParentChangeEmision_this());
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
    {}
    override void intMouseRelease(Form form, WidgetI widget, EventForm* event)
    {}
    override void intMouseClick(Form form, WidgetI widget, EventForm* event) 
    {}
    override void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {}
    override void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {}
    override void intMouseMove(Form form, WidgetI widget, EventForm* event)
    {}
}
