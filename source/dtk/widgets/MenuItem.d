// MenuItem should be used as a placeholder for other widgets.
// Usual MenuItem is used with Label child and looks like usual menu item with
// text (and all it's common things, like hotkey textual representation)
module dtk.widgets.MenuItem;

import std.typecons;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.Property;


import dtk.widgets.Widget;
import dtk.widgets.mixins;

class MenuItem : Widget, ContainerableI
{
	mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
	
    private
    {
        ContainerableI _contained;
    }
    
    override void propagatePosAndSizeRecalc()
    {
    }
    
}
