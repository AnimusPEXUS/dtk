module dtk.widgets.LinearLayout;

import dtk.interfaces.LayoutMgrI;

import dtk.widgets.Layout;

enum LinearLayoutDirection : ubyte
{
    horizontal,
    vertical,
}

class LinearLayoutMgr : LayoutMgrI
{
	Layout layout_widget;
	LinearLayoutDirection direction;
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