module dtk.widgets.Picture;

import std.typecons;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.Property;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class Picture : Widget, ContainerableI
{
	mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();

    override void propagatePosAndSizeRecalc()
    {
    }
}
