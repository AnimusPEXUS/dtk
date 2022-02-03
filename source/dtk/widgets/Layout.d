module dtk.widgets.Layout;

import std.conv;
import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;
import std.exception;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.LayoutEngineI;
import dtk.interfaces.LayoutChildSettingsI;


import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;

import dtk.widgets.Form;
import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.signal_tools;

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

// Each Layout Engine have it's own set of parameters for each child,
// so LayoutChild somehow have to store settings for any engine child.
// here's how it does this.
PropSetting("gsun", "LayoutChildSettingsI", "settings", "Settings", "null"),
];


class LayoutChild
{
	ContainerableI child;
	
    mixin mixin_multiple_properties_define!(LayoutChildProperties);
    mixin mixin_multiple_properties_forward!(LayoutChildProperties, false);
    this(ContainerableI widget) {
    	mixin(mixin_multiple_properties_inst(LayoutChildProperties));
    }
}


const auto LayoutProperties = cast(PropSetting[]) [
PropSetting("gsun", "LayoutEngineI", "vertical_overflow_behavior", "LayoutEngine", "null"),
// PropSetting("gs_w_d", "ulong", "vertical_overflow_behavior", "LayoutOverflowBehavior", "LayoutOverflowBehavior.Resize"),
// PropSetting("gs_w_d", "ulong", "horizontal_overflow_behavior", "LayoutOverflowBehavior", "LayoutOverflowBehavior.Resize"),
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
    
    private {
    	SignalConnection sc_parentChange;
    }
    
    
    this()
    {
    	this([]);
    }
    
    this(LayoutChild[] children) {
    	mixin(mixin_multiple_properties_inst(LayoutProperties));
    	this.children = children;
    	
    	sc_parentChange = connectToParent_onAfterChanged(
    		delegate void(
    			ContainerI o,
    			ContainerI n,
    			)
    		{
    			collectException(writeln("Layout parent change form ", o, " to ", n));
    		}
    		);
    }
    
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
    
    LayoutChild getLayoutChildByChild(ContainerableI child)
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
    	auto la = getLayoutEngine();
    	la.performLayout();
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
    
    override Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
    	auto x = point.x;
        auto y = point.y;
        
        int local_x;
        int local_y;
        {
        	// auto pos = this.getPosition();
        	local_x=x;
        	local_y=y;
        }
        
    	if (children.length == 0)
    	{
    		return tuple(cast(WidgetI)this, Position2D(local_x, local_y));
    	}
    	
    	// TODO: optimize for visible part
    	foreach (c; children)
    	{
    		// auto c_pos = c.getPosition();
    		// auto c_size = c.getSize();
    		int c_pos_x = cast(int) c.getX();
    		int c_pos_y = cast(int) c.getY();
    		auto c_size_w = c.getWidth();
    		auto c_size_h = c.getHeight();
    		
    		if (x >= c_pos_x && x <= (c_pos_x + c_size_w)
    			&& y >= c_pos_y && y <= (c_pos_y + c_size_h))
    		{
    			return c.child.getWidgetAtPosition(Position2D(x - c_pos_x, y - c_pos_y));
    		}
    	}
    	return tuple(cast(WidgetI)this, Position2D(local_x, local_y));
    }
    
    static foreach(v;["X", "Y", "Width", "Height"])
    {
    	import std.format;
    	mixin(
    		q{
    			ulong getChild%1$s(ContainerableI child)
    			{
    				auto c = getLayoutChildByChild(child);
    				if (c is null)
    				{
    					throw new Exception("object is not in layout");
    				}
    				return c.get%1$s();
    			}
    			
    			void setChild%1$s(ContainerableI child, ulong v)
    			{
    				auto c = getLayoutChildByChild(child);
    				if (c is null)
    				{
    					throw new Exception("object is not in layout");
    				}
    				c.set%1$s(v);
    				return;
    			}
    		}.format(v)
    		);
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
    
    override DrawingSurfaceI getDrawingSurface()
    {
    	return super.getDrawingSurface();
    }
}
