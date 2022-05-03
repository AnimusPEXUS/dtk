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
import dtk.types.EnumWidgetInternalDraggingEventEndReason;

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
PropSetting("gs_w_d", "float", "value", "Value", q{0.2}),
PropSetting("gs_w_d", "float", "buttonStep", "ButtonStep", q{0.1}),
PropSetting("gs_w_d", "float", "visibleScope", "VisibleScope", q{0.3}),
];

class ScrollBar : Widget
{
	
    mixin mixin_multiple_properties_define!(ScrollBarProperties);
    mixin mixin_multiple_properties_forward!(ScrollBarProperties, false);
    mixin mixin_Widget_renderImage!("ScrollBar");
    
    public
    {
    	const float minValue = 0;
    	const float maxValue = 1;
    	const buttonSize = 16;
    	
    	int min;
    	int max;
    	
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
    	addChild(new Button().setTextLabel("⯇"));
    	addChild(new Button().setTextLabel("⯈"));
    }
    
    private void recalcScrollBar()
    {
    	recalcScopeSpaceAndBewelSize();
    	recalcIndicatorAndChildrenPositions();
    }
    
    private void recalcScopeSpaceAndBewelSize()
    {
    	if (getOrientation() == Orientation.horizontal)
    	{
    		scopeSpaceSize = getWidth();
    	}
    	else
    	{
    		scopeSpaceSize = getHeight();
    	}
    	
    	scopeSpaceSize -= (buttonSize * 2);
    	
    	// TODO: this method of checking maybe and error prone. redo
    	if (scopeSpaceSize < 0)
    		scopeSpaceSize = 0;
    	
    	scopeBewelSize = cast(int)(
    		cast(float)scopeSpaceSize * getVisibleScope()
    		);
    	
    	if (scopeBewelSize < buttonSize)
    		scopeBewelSize = buttonSize;
    }
    
    private void recalcIndicatorAndChildrenPositions()
    {
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
    		
    		scopeBewelX = cast(int)(
    			cast(float)buttonSize + (scopeSpaceSize * getValue())
    			);
    		scopeBewelY = 0;
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
    		
    		scopeBewelX = 0;
    		scopeBewelY = cast(int)(
    			cast(float)buttonSize + (scopeSpaceSize * getValue())
    			);
    		scopeBewelW = thisWidth;
    		scopeBewelH = scopeBewelSize;
    	}
    }
    
    override void propagatePosAndSizeRecalcBefore()
    {
    	recalcScrollBar();
    }
    
    void setScrollingFromIntegers(int min, int max, int sMin, int sMax)
    {
    	if (min > max)
    	{
    		throw new Exception("invalid min/max");
    	}
    	
    	if (sMin > sMax)
    	{
    		throw new Exception("invalid min/max");
    	}
    	
    	// TODO: allow scrolling outside of area
    	if (sMin < min || sMax > max)
    	{
    		throw new Exception("visibility area is larger than area itself");
    	}
    	
    	this.min = min;
    	this.max = max;
    	
    	// TODO: replace divisions with multiplications, 
    	//       or make exclusions on zero divisions
    	
    	setVisibleScope((cast(float)max-min) / (sMax-sMin));
    	if (sMin < min)
    		setValue(0);
    	else if ((sMin >= max))
    		setValue(1);
    	else
    		setValue(1.0/((cast(float)max-min)/sMin));
    	recalcScrollBar();
    	redraw();
    }
    
    Tuple!(int, int, int, int) calcScrollingIntegers()
    {
    	int sMin;
    	int sMax;
    	
    	sMin = cast(int)(
    		min + ((cast(float)max-min)*getValue())
    		);
    	
    	sMax = cast(int)(
    		sMin+((cast(float)max-min)*getVisibleScope())
    		);
    	
    	return tuple(min, max, sMin, sMax);
    }
    
    override void intMousePress(Widget widget, EventForm* event)
    {
    	debug writeln("ScrollBar Mouse down");
    	
    	// TODO: check precision
    	if 
    	(
    		event.mouseFocusedWidgetX >= scopeBewelX 
    		&& event.mouseFocusedWidgetX < scopeBewelX+scopeBewelW
    		
    		&&
    		
    		event.mouseFocusedWidgetY >= scopeBewelY 
    		&& event.mouseFocusedWidgetY < scopeBewelY+scopeBewelH
    	) 
    	{
    		debug writeln("ScrollBar scope bewel Mouse down");
    		
    		auto p = findPlatform();
    		assert(p !is null);
    		if (p is null)
    		{
    			throw new Exception("can't get platform");
    		}
    		
    		p.widgetInternalDraggingEventStart(
    			this,
    			event.mouseFocusedWidgetX,
    			event.mouseFocusedWidgetY,
    			delegate EnumWidgetInternalDraggingEventEndReason(Event *e)
    			{
    				if (e.type == EventType.mouse 
    					&& e.em.type==EventMouseType.button
    				&&	((e.em.button & EnumMouseButton.bl) != 0)
    				&& e.em.buttonState == EnumMouseButtonState.released
    				)
    				{
    					debug writeln("SB drag success");
    					return EnumWidgetInternalDraggingEventEndReason.success;
    				}
    				return  EnumWidgetInternalDraggingEventEndReason.notEnd;
    			}
    			);
    	}
    }
    
    override void intInternalDraggingEvent(
    	Widget widget, 
    	int initX, int initY,
    	int newX, int newY
    	) 
    {
    	debug writeln("intInternalDraggingEvent happened");
    }
}