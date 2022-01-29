module dtk.widgets.Layout;

import std.conv;
import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
// import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.LayoutI;


import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;

import dtk.widgets.Form;
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

const auto LayoutChildProperties = cast(PropSetting[]) [
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
];
  

class LayoutChild
{
	ContainerableI child;
	// float halign;
	// float valign;
	
    mixin mixin_multiple_properties_define!(LayoutChildProperties);	
    mixin mixin_multiple_properties_forward!(LayoutChildProperties, false);	
    this(ContainerableI widget) {
    	mixin(mixin_multiple_properties_inst(LayoutChildProperties));
    }
}


const auto LayoutProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "ulong", "vertical_overflow_behavior", "LayoutOverflowBehavior", "LayoutOverflowBehavior.Resize"),
PropSetting("gs_w_d", "ulong", "horizontal_overflow_behavior", "LayoutOverflowBehavior", "LayoutOverflowBehavior.Resize"),
// PropSetting("gsun", "ContainerI", "parent_container", "Parent", "null")
];

/++

new layouts can be implimented by inheriting Layout and overriding functions
such as positionAndSizeRequest() and redraw().

NOTE: Layout should not do any changes to any positions and sizes of it's
own children.

+/
class Layout : Widget, ContainerI //, LayoutI
{

    // children field is public and is a normal array. you can use it to
    // add, remove or rearrange layout's children. checkChildren() method is 
    // needed to be called after you've done what you wanted with children 
    // array.
    LayoutChild[] children;
	
    mixin mixin_multiple_properties_define!(LayoutProperties);	
    mixin mixin_multiple_properties_forward!(LayoutProperties, false);	
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    
    this()
    {
    	this([]);
    }
    
    this(LayoutChild[] children) {
    	mixin(mixin_multiple_properties_inst(LayoutProperties));
    	this.children = children;
    }

    /*
    override Layout setParent(ContainerI container)
    {
    	return super().setParent(container);
    }
    
    override Layout unsetParent()
    {
    	return super().unsetParent();
    }
    
    override ContainerI getParent()
    {
    	return super().getParent();
    } */

    
    void checkChildren()
    {
    	foreach_reverse (i, v; children)
    	{
    		if (v.child is null)
    		{
    			children = children[0 .. i] ~ children[i+1 .. $];
    			continue;
    		}
    		
    		if (v.child.getParent() != this)
    		{
    			v.child.setParent(this);
    		}
    	} 
    }
    
    LayoutChild getLayoutChildByWidget(ContainerableI child)
    {
    	foreach (v; children)
    	{
    		if (v.child == child)
    		{
    			return v;
    		}
    	}
    	return null;
    }
    
    override void propagatePosAndSizeRecalc()
    {
    	foreach (v; children)
        {
        	v.child.propagatePosAndSizeRecalc();
        }
    }
    
    override void redraw()
    {
    	mixin(mixin_widget_redraw("Layout"));
        
        foreach (v; children)
        {
            v.child.redraw();
        } 
    }
    
    // mixin mixin_getWidgetAtPosition;
    
    override Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
/*     	auto x = point.x;
        auto y = point.y;
        
        ulong local_x;
        ulong local_y;
        {
        	// auto pos = this.getPosition();
        	local_x=x;
        	local_y=y;
        }
        
    	auto children = getChildren();
    	
    	if (children.length == 0)
    	{
    		return tuple(cast(WidgetI)this, Position2D(local_x, local_y));
    	}
    	
    	// TODO: optimize for visible part
    	foreach (c; children)
    	{
    		auto c_pos = c.getPosition();
    		auto c_size = c.getSize();
    		int c_pos_x = c_pos_x;
    		int c_pos_y = c_pos_y;
    		auto c_size_w = c_size.width;
    		auto c_size_h = c_size.height;
    		
    		if (x >= c_pos_x && x <= (c_pos_x + c_size_w) 
    			&& y >= c_pos_y && y <= (c_pos_y + c_size_h))
    		{
    			return c.getWidgetAtPosition(Position2D(x - c_pos_x, y - c_pos_y));
    			}
    			}
    			return tuple(cast(WidgetI)this, Position2D(local_x, local_y)); */
    			return tuple(cast(WidgetI)null, Position2D(0, 0));
    }
    
    ulong getChildX(ContainerableI child)
    {
    	return 0;
    }
    
    ulong getChildY(ContainerableI child)
    {
    	return 0;
    }
    
    ulong getChildWidth(ContainerableI child)
    {
    	return 0;
    }
    
    ulong getChildHeight(ContainerableI child)
    {
    	return 0;
    }
    
    void setChildX(ContainerableI child, ulong v)
    {
    }
    
    void setChildY(ContainerableI child, ulong v)
    {
    }
    
    void setChildWidth(ContainerableI child, ulong v)
    {
    }
    
    void setChildHeight(ContainerableI child, ulong v)
    {
    }
    
    void addChild(ContainerableI child)
    {
    	if (!haveChild(child))
    	{
    		children ~= new LayoutChild(child);
    		if (child.getParent() != this)
    		{
    			child.setParent(this);
    		}
    	}
    }
    
    void removeChild(ContainerableI child)
    {
    	if (!haveChild(child))
    		return;
    		
    	ContainerableI[] removed;
    	
    	foreach_reverse (i, v; children)
    	{
    		if (v.child == child)
    		{
    			removed~=v.child;
    			children = children[0 .. i] ~ children[i+1 .. $]; 
    		}
    	}
    	
    	foreach(v;removed)
    	{
    		v.unsetParent();
    	}
    }
    
    bool haveChild(ContainerableI child)
    {
    	foreach(v;children)
    	{
    		if (v.child == child)
    			return true;
    	}
    	return false;
    }

}
