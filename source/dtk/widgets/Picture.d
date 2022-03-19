module dtk.widgets.Picture;

import std.typecons;

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
import dtk.widgets.mixins;

class Picture : Widget, WidgetI
{
	mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
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
    mixin mixin_Widget_renderImage!("Picture");
    mixin mixin_widget_redraw_using_propagateRedraw!();
    mixin mixin_propagateRedraw_children_none!();
    mixin mixin_propagateParentChangeEmision!();

    this()
    {
    	// mixin(mixin_propagateParentChangeEmision_this());
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
