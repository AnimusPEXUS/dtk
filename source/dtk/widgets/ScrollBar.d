module dtk.widgets.ScrollBar;


import std.stdio;
import std.typecons;
import std.exception;
import std.format;

import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.Property;
import dtk.types.Image;
import dtk.types.Color;
import dtk.types.Event;
import dtk.types.Widget;
import dtk.types.Orientation;

// import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
// import dtk.interfaces.Widget;
// import dtk.interfaces.FormI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.mixins;

import dtk.miscs.TextProcessor;
import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.signal_tools;


const auto ScrollBarProperties = cast(PropSetting[]) [
// TODO: use fontconfig instead of this
PropSetting(
	"gs_w_d",
	"Orientation",
	"orientation",
	"Orientation",
	q{Orientation.horizontal}
	),
PropSetting("gs_w_d", "float", "minValue", "MinValue", q{0}),
PropSetting("gs_w_d", "float", "maxValue", "MaxValue", q{1}),
PropSetting("gs_w_d", "float", "value", "Value", q{0.2}),
PropSetting("gs_w_d", "float", "buttonStep", "ButtonStep", q{0.1}),
PropSetting("gs_w_d", "float", "visibleScope", "VisibleScope", q{0.3}),
];

class ScrollBar : Widget
{
	
    mixin mixin_multiple_properties_define!(ScrollBarProperties);
    mixin mixin_multiple_properties_forward!(ScrollBarProperties, false);
    mixin mixin_Widget_renderImage!("ScrollBar");
    
    private
    {
    	const buttonSize = 12;
    	
    	int scopeBewelX;
    	int scopeBewelY;
    	int scopeBewelW;
    	int scopeBewelH;
    	
    	int scopeSpaceSize;
    	int scopeBewelSize;
    }
    
    this()
    {
    	super(2, 2);
    	mixin(mixin_multiple_properties_inst(ScrollBarProperties));
    	addChild(new Button().setTextLabel("1"));
    	addChild(new Button().setTextLabel("2"));
    }
    
    void recalcScopeSpaceAndBewelSize()
    {
    	if (getOrientation() == Orientation.horizontal)
    	{
    		scopeSpaceSize = getWidth() - (buttonSize * 2);
    	}
    	else
    	{
    		scopeSpaceSize = getHeight() - (buttonSize * 2);
    	}
    	
    	if (scopeSpaceSize < 0)
    		scopeSpaceSize = 0;
    	
    	scopeBewelSize = cast(int)(
    		cast(float)scopeSpaceSize * getVisibleScope()
    		);
    }
    
    void recalcIndicatorAndChildrenPositions()
    {
    	recalcScopeSpaceAndBewelSize();
    	auto c0 = getChild(0);
    	auto c1 = getChild(1);
    	auto thisWidth = getWidth();
    	auto thisHeight = getHeight();
    	if (getOrientation() == Orientation.horizontal)
    	{
    		c0.setX(0);
    		c0.setY(0);
    		c0.setWidth(buttonSize);
    		c0.setHeight(thisHeight);
    		
    		c1.setX(thisWidth-buttonSize);
    		c1.setY(0);
    		c1.setWidth(buttonSize);
    		c1.setHeight(thisHeight);
    		
    		scopeBewelX = buttonSize; // here
    		scopeBewelY = thisHeight;
    		scopeBewelW = scopeBewelSize;
    		scopeBewelH = thisHeight;
    	}
    	else
    	{
    		c0.setX(0);
    		c0.setY(0);
    		c0.setWidth(thisWidth);
    		c0.setHeight(buttonSize);
    		
    		c1.setX(0);
    		c1.setY(thisHeight-buttonSize);
    		c1.setWidth(thisWidth);
    		c1.setHeight(buttonSize);
    		
    		scopeBewelX = thisWidth;
    		scopeBewelY = buttonSize; // here
    		scopeBewelW = thisWidth;
    		scopeBewelH = scopeBewelSize;
    	}
    }
    
    override void propagatePosAndSizeRecalcBefore()
    {
    	recalcIndicatorAndChildrenPositions();
    }
    
}