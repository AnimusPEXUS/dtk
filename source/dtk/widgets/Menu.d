/++
Menu is rectangular window containing MenuItems.

Menu can dropdown from other MenuItems, can be shown as popup context menu
or by other means.
+/

module dtk.widgets.Menu;

import std.typecons;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
//import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Position2D;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.SizeGroup;

const auto MenuProperties = cast(PropSetting[]) [
PropSetting("gsun", "WidgetI", "child", "Child", ""),

PropSetting("gsun", "WidgetI", "focused_widget", "FocusedWidget", ""),
PropSetting("gsun", "WidgetI", "default_widget", "DefaultWidget", ""),
];

class Menu : Widget, WidgetI, ContainerI
{
	mixin mixin_multiple_properties_define!(MenuProperties);
    mixin mixin_multiple_properties_forward!(MenuProperties, false);
	mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("Menu");
    mixin mixin_widget_redraw_using_parent!();

    
    private
    {
        SizeGroup _menu_item_icon_size_group;
        SizeGroup _menu_item_text_size_group;
        SizeGroup _menu_item_hotkey_size_group;
    }
    
    mixin mixin_forward_super_functions!(
    	[
    	"getForm",
    	"getNextFocusableWidget",
    	"getPrevFocusableWidget",
    	"propagatePosAndSizeRecalc",
    	"getDrawingSurface"
    	]
    	);
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(MenuProperties));
    }
    
    override Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI) null, Position2D(0,0));
    }
    
    ulong getChildX(WidgetI child)
    {
    	return 0;
    }
    
    ulong getChildY(WidgetI child)
    {
    	return 0;
    }
    
    ulong getChildWidth(WidgetI child)
    {
    	return getWidth();
    }
    
    ulong getChildHeight(WidgetI child)
    {
    	return getHeight();
    }
    
    void setChildX(WidgetI child, ulong v)
    {}
    
    void setChildY(WidgetI child, ulong v)
    {}
    
    void setChildWidth(WidgetI child, ulong v)
    {}
    
    void setChildHeight(WidgetI child, ulong v)
    {}
    
    void addChild(WidgetI child)
    {
    	setChild(child);
    }
    
    void removeChild(WidgetI child)
    {
    	if (haveChild(child))
    	{
    		unsetChild();
    	}
    }
    
    bool haveChild(WidgetI child)
    {
    	return getChild() == child;
    }
    
    override void propagateRedraw()
    {
    }
    
    void redrawChild(WidgetI child)
    {
    	if (getChild() != child)
    		return;
    	
    	auto img = child.renderImage();
    	auto ds = getDrawingSurface();
    	ds.drawImage(Position2D(0, 0), img);
    }
}
