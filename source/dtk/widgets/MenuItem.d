module dtk.widgets.MenuItem;

import std.stdio;
import std.format;

import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.EventForm;

import dtk.widgets.Menu;
import dtk.widgets.mixins;

import dtk.miscs.layoutTools;


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
    	performLayout = delegate void(Widget w)
    	{
    		if (widget && widget.child)
    		{
    			auto c = widget.child;
    			
    			auto dw = c.getDesiredWidth();
    			auto dh = c.getDesiredHeight();
    			
    			setDesiredWidth(dw+5);
    			setDesiredHeight(dh+5);
    			
    			//widget.setWidth(getWidth()-5);
    			//widget.setHeight(getHeight()-5);
    			alignParentChild(0.5, 0.5, this, c);
    			debug writeln(
    				"MenuItem %sx%sx%sx%s".format(
    					getX(),
    					getY(),
    					getWidth(),
    					getHeight()
    					)
    				);
    			debug if (c)
    			{
    				writeln("	child %sx%sx%sx%s ".format(
    					c.getX(),
    					c.getY(),
    					c.getWidth(),
    					c.getHeight()
    					));
    			}
    		}
    	};
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
    
	override WidgetChild[] calcWidgetChildren()
    {
    	WidgetChild[] ret;
    	if (this.widget)
    		ret ~= this.widget;
    	return ret;
    }

    override void intMousePressRelease(Widget widget, EventForm* event)
    {
    	debug writeln("click");
    	if (onMousePressRelease)
    		onMousePressRelease(event);
    }
}
