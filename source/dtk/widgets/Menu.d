module dtk.widgets.Menu;

import dtk.types.Property;
import dtk.types.Widget;

import dtk.widgets.Layout;
import dtk.widgets.MenuItem;
import dtk.widgets.mixins;

const auto MenuProperties = cast(PropSetting[]) [
];

class Menu : Widget
{
	mixin mixin_multiple_properties_define!(MenuProperties);
    mixin mixin_multiple_properties_forward!(MenuProperties, false);
    mixin mixin_Widget_renderImage!("Menu");
    
    private
    {
    	WidgetChild layout;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(MenuProperties));
    	
    	auto l = new Layout();
    	layout = new WidgetChild(l);
    	
    	l.exceptionIfChildInvalid = delegate void(Widget child)
    	{
    		if (cast(MenuItem) child is null)
    		{
    			throw new Exception(
    				"child didn'd passed exceptionIfChildInvalid check"
    				);
    		}
    	};
    }
    
    Widget getLayout()
    {
    	return layout.child;
    }
    
	override WidgetChild[] calcWidgetServiceChildrenArray()
    {
    	return [layout];
    }
    
    override WidgetChild[] calcWidgetNormalChildrenArray()
    {
    	return [];
    }
    
}
