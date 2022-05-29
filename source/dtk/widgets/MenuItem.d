module dtk.widgets.MenuItem;

import std.stdio;
import std.format;

import dtk.types.Property;
import dtk.types.Widget;
import dtk.types.EventForm;
import dtk.types.WindowCreationSettings;

import dtk.widgets.Form;
import dtk.widgets.Menu;
import dtk.widgets.TextEntry;
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
    	performLayout = delegate void(Widget w1)
    	{
    		auto w = cast(MenuItem) w1;
    		auto c = w.getWidget();
    		
    		if (c)
    		{
    			debug writeln("MenuItem propagates PL to child");
    			c.propagatePerformLayout();
    			debug writeln(" [[MenuItem propagates PL to child]]:end");
    			auto dw = c.getDesiredWidth();
    			auto dh = c.getDesiredHeight();
    			debug writeln(" [[MenuItem child desired WxH]]: %sx%s".format(dw,dh));
    			
    			setDesiredWidth(dw+5);
    			setDesiredHeight(dh+5);
    			
    			c.setWidth(w.getWidth());
    			c.setHeight(w.getHeight());
    			
    			// c.propagatePerformLayout();
    			
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
    		{
    			auto w2 = cast(TextEntry) w;
    			if (w2)
    			{
    				w2.captionMode=true;
    			}
    		}
    	}
    	return this;
    }
    
    Widget getWidget()
    {
    	if (widget && widget.child)
    		return widget.child;
    	return null;
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
    	// if (onMousePressRelease)
    		// onMousePressRelease(event);
    	showSubmenu();
    }
    
    void showSubmenu()
    {
    	auto pos = calcPosRelativeToForm(getLeftBottomPos());
    	
    	auto win = getForm().getWindow(); 
    	
    	auto p = win.getPlatform();

    	auto borderSizes = win.getBorderSizes();
    	
    	// auto window_pos = win.getPosition();
    	
    	pos.x += borderSizes.leftTop.height + win.getX();
    	pos.y += borderSizes.leftTop.width + win.getY();
    	
    	WindowCreationSettings wcs = {
    		title: "Popup",
    		x: pos.x,
    		y: pos.y,
    		width: 50,
    		height: 50,
    		resizable: true,
    		//popup_menu: true,
    	};
    	
    	auto w = p.createWindow(wcs);
    	
    	auto f = new Form();
    	w.setForm(f);
    	f.setMainWidget(getSubmenu());
    	
    	f.performLayout = delegate void(Widget w1)
    	{
    		auto w = cast(Form) w1;
    		auto c = w.getMainWidget();
    		if (c)
    		{
    			c.propagatePerformLayout();
    			
    			auto cdw = c.getDesiredWidth();
    			auto cdh = c.getDesiredHeight();
    			
    			// TODO: make those functions work in Form
    			w.setDesiredWidth(cdw);
    			w.setDesiredHeight(cdh);
    			
    			c.setWidth(cdw);
    			c.setHeight(cdh);
    			
    			alignParentChild(0.5, 0.5, this, c);
    		}
    	};
    	
    }
}
