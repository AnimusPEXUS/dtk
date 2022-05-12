module dtk.widgets.MenuItem;

import dtk.types.Property;
import dtk.types.Widget;

import dtk.widgets.Menu;
import dtk.widgets.mixins;

const auto MenuItemProperties = cast(PropSetting[]) [
PropSetting("gsun", "Menu", "submenu", "Submenu", q{null}),
];

class MenuItem : Widget
{
	mixin mixin_multiple_properties_define!(MenuItemProperties);
    mixin mixin_multiple_properties_forward!(MenuItemProperties, false);
    mixin mixin_Widget_renderImage!("MenuItem");
    
    this()
    {
    	super(1, 1);
    	mixin(mixin_multiple_properties_inst(MenuItemProperties));
    }
    
}
