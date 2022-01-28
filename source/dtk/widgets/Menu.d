/++
    Menu is rectangular window containing MenuItems.

    Menu can dropdown from other MenuItems, can be shown as popup context menu
    or by other means.
+/

module dtk.widgets.Menu;

import std.typecons;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;

import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.Property;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.SizeGroup;


class Menu : Widget, ContainerableI
{
	
	mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
	
    private
    {
        SizeGroup _menu_item_icon_size_group;
        SizeGroup _menu_item_text_size_group;
        SizeGroup _menu_item_hotkey_size_group;
    }
    
    override void propagatePosAndSizeRecalc()
    {
    }

}
