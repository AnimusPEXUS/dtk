module dtk.widgets.Menu;

import dtk.types.Property;
import dtk.types.Widget;

import dtk.widgets.MenuItem;
import dtk.widgets.mixins;

const auto MenuProperties = cast(PropSetting[]) [
];

class Menu : Widget
{
	mixin mixin_multiple_properties_define!(MenuProperties);
    mixin mixin_multiple_properties_forward!(MenuProperties, false);
    mixin mixin_Widget_renderImage!("Menu");
    
    this()
    {
    	super(0, 1);
    	mixin(mixin_multiple_properties_inst(MenuProperties));
    }
    
    override void exceptionIfChildInvalid(Widget child)
    {
    	if (cast(MenuItem) child is null)
    	{
    		throw new Exception(
    			"child didn'd passed exceptionIfChildInvalid check"
    			);
    	}
    }
}
