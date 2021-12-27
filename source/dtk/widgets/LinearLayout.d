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
	
	this(Layout layout_widget)
	{
		this.layout_widget = layout_widget;
	}		
	
	void performLayout()
	{
		ulong max_size = 
			(direction == horizontal? 
				layout_widget.getInnerWidth 
				: layout_widget.getInnerHeight);
		
		ulong perp_size = 
			(direction == horizontal ? 
				layout_widget.getInnerHeight 
				: layout_widget.getInnerWidth);
			
		LayoutChild[] children_with_expand;
		
		foreach (v; layout_widget.children)
		{
			
		}
	}
}