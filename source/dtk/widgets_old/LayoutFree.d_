module dtk.widgets.LayoutFree;

import dtk.interfaces.LayoutEngineI;
import dtk.interfaces.LayoutChildSettingsI;

import dtk.types.Property;

import dtk.widgets.Layout;

const auto LayoutFreeChildSettingsProperties = cast(PropSetting[]) [
	PropSetting("gsu", "ulong", "x", "X", "0"),
	PropSetting("gsu", "ulong", "y", "Y", "0"),
	PropSetting("gsu", "ulong", "width", "Width", "0"),
	PropSetting("gsu", "ulong", "height", "Height", "0"),
];

class LayoutFreeChildSettings : LayoutChildSettingsI
{
	mixin mixin_multiple_properties_define!(LayoutFreeChildSettingsProperties);
    mixin mixin_multiple_properties_forward!(LayoutFreeChildSettingsProperties, false);
    this() {
    	mixin(mixin_multiple_properties_inst(LayoutFreeChildSettingsProperties));
    }
}

class LayoutFree : LayoutEngineI
{
	Layout layout_widget;
	
	this(Layout layout_widget)
	{
		this.layout_widget = layout_widget;
	}		
	
	void performLayout()
	{

	}
}