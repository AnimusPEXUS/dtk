module dtk.widgets.Layout;

import std.conv;
import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.LayoutI;


import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}



enum LayoutType : ubyte
{
    undefined,
    linearScrolled,
    linearWrapped,
}

class LayoutChild
{
	ContainerableWidgetI widget;
	// float halign;
	// float valign;
	
    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])
        [
        // X, Y, Width and Height is for storring real effective values
        // users should not change those unless Layout is set to use
        // free positioning for widgets.
        PropSetting("gs_w_d", "ulong", "x", "X", "0"),
        PropSetting("gs_w_d", "ulong", "y", "Y", "0"),
        PropSetting("gs_w_d", "ulong", "width", "Width", "0"),
        PropSetting("gs_w_d", "ulong", "height", "Height", "0"),
        
        // CA stends for 'Child Asks'. through this properties, 
        // child widget can ask certain desirable settings for it,
        // but Layout can ignore those if it need so. Child can leave 
        // those properties unset if it not doesn't have need for them
        PropSetting("gsu", "ulong", "ca_x", "CAX", "0"),
        PropSetting("gsu", "ulong", "ca_y", "CAY", "0"),
        PropSetting("gsu", "ulong", "ca_width", "CAWidth", "0"),
        PropSetting("gsu", "ulong", "ca_height", "CAHeight", "0"),
        
        PropSetting("gs_w_d", "bool", "ca_hfill", "CAHFill", "false"),
        PropSetting("gs_w_d", "bool", "ca_vfill", "CAVFill", "false"),
        
        PropSetting("gs_w_d", "bool", "ca_hexpand", "CAHExpand", "false"),
        PropSetting("gs_w_d", "bool", "ca_vexpand", "CAVExpand", "false"),
        ]
        );	
}

/++

new layouts can be implimented by inheriting Layout and overriding functions
such as positionAndSizeRequest() and redraw().

NOTE: Layout should not do any changes to any positions and sizes of it's
own children.

+/
class Layout : Widget, ContainerableWidgetI, LayoutI
{

    // children field is public and is a normal array. you can use it to
    // add, remove or rearrange layout's children. checkChildren() method is 
    // needed to be called after you've done what you wanted with children 
    // array.
    LayoutChild[] children;
	
    private
    {
        
        mixin Property_gs_w_d!(
        	LayoutOverflowBehavior,
        	"vertical_overflow_behavior", 
        	LayoutOverflowBehavior.Resize
        	);
        
        mixin Property_gs_w_d!(
        	LayoutOverflowBehavior,
        	"horizontal_overflow_behavior", 
        	LayoutOverflowBehavior.Resize
        	);
    }
    
    mixin Property_forwarding!(
    	LayoutOverflowBehavior,
    	vertical_overflow_behavior, 
    	"VerticalOverflowBehavior"
    	);
    mixin Property_forwarding!(
    	LayoutOverflowBehavior,
    	vertical_overflow_behavior, 
    	"HorizontalOverflowBehavior"
    	);
    
    void checkChildren()
    {
    	foreach_reverse (i, v; children)
    	{
    		if (v.widget is null)
    		{
    			children = children[0 .. i] ~ children[i+1 .. $];
    			continue;
    		}
    		if (v.widget.getParent() != this)
    		{
    			v.widget.setParent(this);
    		}
    	}
    }
    
    LayoutChildI getLayoutChildByWidget(ContainerableWidgetI widget)
    {
    	foreach (v; children)
    	{
    		if (v.widget == widget)
    		{
    			return v;
    		}
    	}
    	return null;
    }
    
    override void positionAndSizeRequest(Position2D position, Size2D size)
    {
        super.positionAndSizeRequest(position, size);
        this.recalculateChildrenPositionsAndSizes();
    }
    
    override void recalculateChildrenPositionsAndSizes()
    {
        foreach (size_t counter, v; children)
        {
            v.recalculateChildrenPositionsAndSizes();
        }
    }
    
    override void redraw()
    {
    	
        super.redraw();
        
        this.redraw_x(this);
        
        
        foreach (size_t i, v; children)
        {
            v.redraw();
        }
    }
    
    mixin mixin_getWidgetAtPosition;
}
