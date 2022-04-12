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

// import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
//import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Event;
import dtk.types.Widget;

// import dtk.widgets.Widget;
import dtk.miscs.RadioGroup;
import dtk.miscs.signal_tools;
import dtk.miscs.layoutCollection;
import dtk.miscs.DrawingSurfaceShift;

import dtk.widgets.Form;
import dtk.widgets.TextEntry;
import dtk.widgets.mixins;


const auto ButtonProperties = cast(PropSetting[]) [
];

class Button : Widget
{
	mixin mixin_multiple_properties_define!(ButtonProperties);
    mixin mixin_multiple_properties_forward!(ButtonProperties, false);
    mixin mixin_Widget_renderImage!("Button");
    // mixin mixin_widget_redraw_using_propagateRedraw!();
    
    this()
    {
    	super(0, 1);
    	mixin(mixin_multiple_properties_inst(ButtonProperties));
    }
    
    Button setTextLabel(dstring text)
    {
    	setChild(NewLabel(text));
    	return this;
    }
    
    /*     override void propagatePosAndSizeRecalc()
    {
    if (getChild() !is null)
    {
    alignParentChild(
    0.5, 0.5,
    this,
    getChild()
    );
    }
    } */
}
