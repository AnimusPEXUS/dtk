module dtk.widgets.LayoutFree;

import dtk.interfaces.LayoutEngineI;
import dtk.interfaces.LayoutChildSettingsI;

import dtk.types.Property;

import dtk.widgets.Layout;

const auto LayoutFreeChildSettingsProperties = cast(PropSetting[]) [
	PropSetting("gsu", "ulong", "x", "X", "0"),
	PropSetting("gsu", "ulong", "y", "Y", "0"),
	PropSetting("gsu", "ulong", "width", "Width", "0"),
	PropSetting("gsu", "ulong", "height", "Height", "0"),
];

class LayoutFreeChildSettings : LayoutChildSettingsI
{
	mixin mixin_multiple_properties_define!(LayoutFreeChildSettingsProperties);
    mixin mixin_multiple_properties_forward!(LayoutFreeChildSettingsProperties, false);
    this() {
    	mixin(mixin_multiple_properties_inst(LayoutFreeChildSettingsProperties));
    }
}

enum LayoutFreeDirection : ubyte
{
    horizontal,
    vertical,
}

class LayoutFree : LayoutEngineI
{
	Layout layout_widget;
	LayoutFreeDirection direction;
	ulong spacing;
	
	this(Layout layout_widget)
	{
		this.layout_widget = layout_widget;
	}		
	
	void performLayout()
	{
		/* ulong max_size = 
		(direction == horizontal? 
		layout_widget.getInnerWidth() 
		: layout_widget.getInnerHeight());
		
		ulong perp_size = 
		(direction == horizontal ? 
		layout_widget.getInnerHeight() 
		: layout_widget.getInnerWidth());
		
		LayoutChild[] children_with_expand;
		LayoutChild[] children_without_expand;
		
		foreach (v; layout_widget.children)
		{
		if (v.expand)
		{
		children_with_expand ~= v;
		}
		else
		{
		children_without_expand ~= v;
		}
		}
		
		ulong children_without_expand_size;
		
		foreach (v; children_without_expand)
		{
		auto x = (direction == horizontal ? 
		v.widget.getMinimumWidth() 
		: layout_widget.getMinimumHeight());
		children_without_expand_size += x;			
		}
		
		children_without_expand_size += (children_without_expand.length-1) * spacing;
		*/
		
	}
}