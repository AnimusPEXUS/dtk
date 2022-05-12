module dtk.widgets.Layout;

import core.sync.mutex;
import std.conv;
import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;
import std.exception;

// import dtk.interfaces.ContainerI;
// import dtk.interfaces.Widget;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.LayoutChildSettingsI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Image;
import dtk.types.VisibilityMap;
import dtk.types.Event;
import dtk.types.Widget;

import dtk.widgets.Form;
import dtk.widgets.mixins;

import dtk.miscs.signal_tools;
import dtk.miscs.calculateVisiblePart;
import dtk.miscs.DrawingSurfaceShift;


const auto LayoutProperties = cast(PropSetting[]) [
];


class Layout : Widget
{
    mixin mixin_multiple_properties_define!(LayoutProperties);
    mixin mixin_multiple_properties_forward!(LayoutProperties, false);
    mixin mixin_Widget_renderImage!("Layout");
    
    this()
    {
    	super(0, -1);
    	mixin(mixin_multiple_properties_inst(LayoutProperties));
    }
    
}
