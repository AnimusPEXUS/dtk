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
// PropSetting("gs_w_d", "float", "value", "Value", q{0.2}),
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
    	
    	float value = 0;
    	// TODO: for a while this is constant here. but should be moved to LaF
    	const buttonSize = 16;
    	
    	// corresponding to something scrollable. set by user via function
    	int min;
    	int max;
    	
    	// graphical. pixels
    	// (total scrollable space (without buttons))
    	// (changes via scrollbar resize)
    	int scopeSpaceSize;
    	// bewel inside of scopeSpaceSize
    	int scopeBewelSize;
    	
    	// scopeSpaceSize - scopeBewelSize
    	int scopeFreeSpaceSize;
    	
    	// graphical. pixels. depends on scrollbar space size and current Value
    	int scopeBewelX;
    	int scopeBewelY;
    	int scopeBewelW;
    	int scopeBewelH;
    	
    	// minimum x or y for left or top edge of bewel relative to DS (DS includes buttons)
    	// (pixels)
    	int minVisible;
    	// maximum x or y for right or bottom edge of bewel relative to DS (DS includes buttons):
    	// this is widget size - button size - bewel size;
    	// (pixels)
    	int maxVisible;
    	
    	// (pixels)
    	const minVisibleValue = 0;
    	// (pixels) same as scopeFreeSpaceSize. should not be changed
    	alias maxVisibleValue = scopeFreeSpaceSize;
    	
    	float onePixelValue;
    	
    	// this should be true, if scrollbar size doesn't allows sanely drag bewel.
    	// if true, scrollbar should not allow user to interact with scope
    	// space and bewel.
    	bool scopeSpaceActionsDisabled;
    }
    
    private
    {
    	// SignalConnection sc_valueChange;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(ScrollBarProperties));
    	
    	{
    		auto x = new Button().setTextLabel("⯇");
    		x.setParent(this);
    		button0 = new WidgetChild(this, x);
    		
    		x = new Button().setTextLabel("⯈");
    		x.setParent(this);
    		button1 = new WidgetChild(this, x);
    	}
    }
    
    private
    {
    	WidgetChild button0;
    	WidgetChild button1;
    }
    
    Widget getButton0()
    {
    	return button0.child;
    }
    
    Widget getButton1()
    {
    	return button1.child;
    }
    
	override WidgetChild[] calcWidgetChildrenArray()
    {
    	// NOTE: scrollbar always have those buttons, so checking isn't needed
    	return [button0, button1];
    }    
    
    // TODO: make this better. even better is to modify property,
    // so Value's Propery BeforeChange event could allow to modify passed value
    typeof(this) setValue(float value)
    {
    	debug writeln("value ", value);
    	if (value < 0)
    		value = 0;
    	if (value > 1)
    		value = 1;
    	debug writeln("value 01 ", value);
    	
    	this.value = value;
    	
    	recalcIndicatorAndChildrenPositions();
    	redraw();
    	return this;
    }
    
    float getValue()
    {
    	return value;
    }
    
    private void recalcScrollBar()
    {
    	recalcScopeSpaceAndBewelSize();
    	recalcIndicatorAndChildrenPositions();
    }
    
    private void recalcScopeSpaceAndBewelSize()
    {
    	
    	auto orient = getOrientation();
    	
    	if (orient == Orientation.horizontal)
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
    	
    	scopeFreeSpaceSize = scopeSpaceSize - scopeBewelSize;
    	
    	if (scopeBewelSize < buttonSize)
    		scopeBewelSize = buttonSize;
    	
    	if (scopeFreeSpaceSize < buttonSize)
    		scopeFreeSpaceSize = buttonSize;
    	
    	// this assumes button 0 is always present;
    	minVisible = buttonSize;
    	
    	{
    		if (orient == Orientation.horizontal)
    		{
    			maxVisible =  getWidth();
    		}
    		else
    		{
    			maxVisible = getHeight();
    		}
    		
    		maxVisible -= buttonSize;
    	}
    	
    	onePixelValue = 1.0 / scopeFreeSpaceSize;
    }
    
    // separate bewel calculations
    private void recalcIndicatorAndChildrenPositions()
    {
    	auto c0 = getButton0();
    	auto c1 = getButton1();
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
    			cast(float)buttonSize + (scopeFreeSpaceSize * getValue())
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
    			cast(float)buttonSize + (scopeFreeSpaceSize * getValue())
    			);
    		scopeBewelW = thisWidth;
    		scopeBewelH = scopeBewelSize;
    	}
    }
    
    override void propagatePosAndSizeRecalc()
    {
    	recalcScrollBar();
    	super.propagatePosAndSizeRecalc();
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
    			event.event.mouseX,
    			event.event.mouseY,
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
    	int newX, int newY,
    	int relX, int relY
    	)
    {
    	// debug writeln(
    	// ("intInternalDraggingEvent happened\n"~
    	// "ini x: %s, y: %s\n"~
    	// "new x: %s, y: %s\n"~
    	// "rel x: %s, y: %s"~
    	// "").format(
    	// initX, initY,
    	// newX, newY,
    	// relX, relY
    	// )
    	// );
    	
    	int delta;
    	
    	if (getOrientation() == Orientation.horizontal)
    	{
    		delta = relX;
    	}
    	else
    	{
    		delta = relY;
    	}
    	
    	float newValue = intInternalDraggingEventStartValue + (onePixelValue * delta);
    	if (getValue() != newValue)
    	{
    		setValue(newValue);
    	}
    }
    
    override void intInternalDraggingEventEnd(
    	Widget widget,
    	EnumWidgetInternalDraggingEventEndReason reason,
    	int initX, int initY,
    	int newX, int newY,
    	int relX, int relY
    	)
    {
    	if (reason != EnumWidgetInternalDraggingEventEndReason.success)
    	{
    		setValue(intInternalDraggingEventStartValue);
    	}
    	else
    	{
    		int delta;
    		
    		if (getOrientation() == Orientation.horizontal)
    		{
    			delta = relX;
    		}
    		else
    		{
    			delta = relY;
    		}
    		
    		float newValue = intInternalDraggingEventStartValue + (onePixelValue * delta);
    		if (getValue() != newValue)
    		{
    			setValue(newValue);
    		}
    	}
    }
    
    private
    {
    	float intInternalDraggingEventStartValue;
    	int intInternalDraggingEventStartVisualValue;
    }
    
    override void intInternalDraggingEventStart(
    	Widget widget,
    	int initX, int initY
    	)
    {
    	if (getOrientation() == Orientation.horizontal)
    	{
    		intInternalDraggingEventStartVisualValue = initX;
    	}
    	else
    	{
    		intInternalDraggingEventStartVisualValue = initY;
    	}
    	
    	intInternalDraggingEventStartValue = getValue();
    }
}