/++
    Menu is rectangular window containing MenuItems.

    Menu can dropdown from other MenuItems, can be shown as popup context menu
    or by other means.
+/

module dtk.widgets.Menu;

import std.typecons;

import dtk.interfaces.ContainerableWidgetI;
import dtk.miscs.SizeGroup;

import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.Size2D;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

class Menu : Widget
{
    private
    {
        SizeGroup _menu_item_icon_size_group;
        SizeGroup _menu_item_text_size_group;
        SizeGroup _menu_item_hotkey_size_group;
    }

}
