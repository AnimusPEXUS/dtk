/++
ToolBar should/can be both used for buttons and menus
+/
module dtk.widgets.Bar;

// TODO: decide, whatever I need one class for menu and tool bars, or different
// classes for each

import std.typecons;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Position2D;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

/++
Test documentation
+/
class Bar : Widget, ContainerableI
{
    
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    
    private
    {
        ContainerableI[] _children;
    }
    
    override void propagatePosAndSizeRecalc()
    {
    }
    
        
    override void redraw()
    {
    }

    override Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI)this, point);
    }
    
}
