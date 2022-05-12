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
    
    private
    {
		WidgetChild[] children;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(LayoutProperties));
    }

	override WidgetChild[] calcWidgetServiceChildrenArray()
    {
    	return [];
    }

    override WidgetChild[] calcWidgetNormalChildrenArray()
    {
    	return children;
    }

    public
    {
    	void delegate(Widget child) exceptionIfChildInvalid; 
    }

    final Widget getChild(int i)
    {
    	if (children.length == 0)
    		return null;
    	if (!(i >= 0 && i < children.length))
    		return null;
    	return children[i].child;
    }
    
    final Widget addChild(Widget child)
    {
    	if (exceptionIfChildInvalid !is null)
    	{
    		exceptionIfChildInvalid(child);
    	}
    	// if (childMaxCount != -1 && children.length == childMaxCount)
    	// {
    		// throw new Exception("maximum children count reached");
    	// }
    	if (!haveChild(child))
    	{
    		children ~= new WidgetChild(child);
    		fixChildParent(child);
    	}
    	return this;
    }
    
    final Widget removeChild(Widget child)
    {
    	// if (children.length == childMinCount)
    	// {
    		// throw new Exception("minimum children count reached");
    	// }
    	if (!haveChild(child))
    		return this;
    	
    	Widget[] removed;
    	
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
    	return this;
    }
    
    final Widget removeAllChildren()
    {
    	auto children_copy = children;
    	foreach(v; children_copy)
    	{
    		if (v.child !is null)
    		{
    			removeChild(v.child);
    		}
    	}
    	return this;
    }
    
    final bool haveCompleteChild(Widget e)
	{
		foreach (v; calcWidgetCompleteChildrenArray())
		{
			if (v.child == e)
			{
				return true;
			}
		}
		return false;
	}

	final override bool haveChild(Widget e)
	{
		foreach (v; children)
		{
			if (v.child == e)
			{
				return true;
			}
		}
		return false;
	}
	
	// TODO: do something with this
	void fixChildrenParents()
    {
    	foreach_reverse (i, v; children)
    	{
    		// TODO: maybe it's better to throw exception, instead of 
    		//       trying to guess fix
    		if (v.child is null)
    		{
    			children = children[0 .. i] ~ children[i+1 .. $];
    			continue;
    		}
    	}
    	
    	foreach (v; calcWidgetCompleteChildrenArray())
    	{
    		fixChildParent(v.child);
    	}
    }
    
	

}
