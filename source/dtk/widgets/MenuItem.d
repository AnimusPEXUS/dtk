module dtk.widgets.MenuItem;

import dtk.types.Property;
import dtk.types.Widget;

import dtk.widgets.Menu;
import dtk.widgets.mixins;

const auto MenuItemProperties = cast(PropSetting[]) [
PropSetting("gsun", "Menu", "submenu", "Submenu", q{null}),
// PropSetting("gsun", "Widget", "widget", "Submenu", q{null}),
];

class MenuItem : Widget
{
	mixin mixin_multiple_properties_define!(MenuItemProperties);
    mixin mixin_multiple_properties_forward!(MenuItemProperties, false);
    mixin mixin_Widget_renderImage!("MenuItem");
    
    this(Widget w = null)
    {
    	mixin(mixin_multiple_properties_inst(MenuItemProperties));
    	setWidget(w);
    }
    
    private
    {
    	WidgetChild widget;
    }
    
    MenuItem setWidget(Widget w)
    {
    	if (w is null)
    	{
    		if (this.widget)
    		{
    			this.widget.child.setParent(null);
    		}
    		this.widget = null;
    	}
    	else
    	{
    		this.widget = new WidgetChild(this, w);
    		w.setParent(this);
    	}
    	return this;
    }
    
    Widget getWidget()
    {
    	return this.widget.child;
    }
    
	override WidgetChild[] calcWidgetChildrenArray()
    {
    	WidgetChild[] ret;
    	if (this.widget)
    		ret ~= this.widget;
    	return ret;
    }
}
