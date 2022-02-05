module dtk.widgets.ScrollBar;

import std.typecons;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;

import dtk.types.Property;
import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class ScrollBar : Widget, WidgetI
{
    
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    
    override void propagatePosAndSizeRecalc()
    {
    }
    
    
    override void redraw()
    {
    }
    
    override Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI)this, point);
    	// return tuple(cast(WidgetI)null, point);
    }
    
}
