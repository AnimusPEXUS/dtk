module dtk.widgets.Menu;

import dtk.types.Property;
import dtk.types.Widget;

import dtk.widgets.Layout;
import dtk.widgets.MenuItem;
import dtk.widgets.mixins;

enum MenuMode : ubyte
{
	bar,
	popup
}

const auto MenuProperties = cast(PropSetting[]) [
 PropSetting("gs_w_d", "MenuMode", "mode", "Mode", q{MenuMode.popup}),
];

Menu MenuBar() {return new Menu(MenuMode.bar);}
Menu MenuPopup() {return new Menu(MenuMode.popup);}

class Menu : Widget
{
	mixin mixin_multiple_properties_define!(MenuProperties);
    mixin mixin_multiple_properties_forward!(MenuProperties, false);
    mixin mixin_Widget_renderImage!("Menu");
    
    private
    {
    	WidgetChild layout;
    }
    
    this(MenuMode mode)
    {
    	mixin(mixin_multiple_properties_inst(MenuProperties));
    	
    	setMode(mode);
    	
    	setLayout(new Layout());
    }
    
    Widget getLayout()
    {
    	return layout.child;
    }
    
    Menu setLayout(Layout l)
    {
    	layout = new WidgetChild(this, l);
    	l.setParent(this);
    	
    	l.exceptionIfLayoutChildInvalid = delegate void(Widget child)
    	{
    		if (cast(MenuItem) child is null)
    		{
    			throw new Exception(
    				"child didn'd passed exceptionIfChildInvalid check"
    				);
    		}
    	};
    	return this;
    }
    
	override WidgetChild[] calcWidgetChildrenArray()
    {
    	WidgetChild[] ret;
    	if (this.layout)
    		ret ~= this.layout;
    	return ret;
    }
    
}
