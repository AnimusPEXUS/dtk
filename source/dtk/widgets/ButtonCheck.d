module dtk.widgets.ButtonCheck;

import std.stdio;
import std.exception;
import std.typecons;

import observable.signal;

// import dtk.interfaces.WidgetI;
// import dtk.interfaces.ContainerI;

import dtk.types.EventMouse;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.EventForm;
import dtk.types.Widget;

import dtk.miscs.RadioGroup;

// import dtk.widgets.Widget;
import dtk.widgets.TextEntry;
import dtk.widgets.Button;
import dtk.widgets.Form;
import dtk.widgets.mixins;

enum ButtonCheckIndicatorAlignment : ubyte
{
	CornerTopLeft,
	CornerTopRight,
	CornerBottomLeft,
	CornerBottomRight,
	
	LeftTop,
	LeftMiddle,
	LeftBottom,
	
	RightTop,
	RightMiddle,
	RightBottom,
	
	TopLeft,
	TopMiddle,
	TopRight,
	
	BottomLeft,
	BottomMiddle,
	BottomRight,
}

const auto ButtonCheckProperties = cast(PropSetting[]) [
PropSetting(
	"gs_w_d",
	"ButtonCheckIndicatorAlignment",
	"indicatorAlignment",
	"IndicatorAlignment",
	"ButtonCheckIndicatorAlignment.LeftTop"
	),
PropSetting("gsun", "RadioGroup", "radio_group", "RadioGroup", "null"),
PropSetting("gs_w_d", "bool", "toggledOn", "ToggledOn", "false"),
];


class ButtonCheck : Widget
{
	private {
    	SignalConnectionContainer con_cont;
    }
    
	mixin mixin_multiple_properties_define!(ButtonCheckProperties);
    mixin mixin_multiple_properties_forward!(ButtonCheckProperties, false);
    
    this()
    {
    	super(0, 1);
    	mixin(mixin_multiple_properties_inst(ButtonCheckProperties));
    	
        con_cont.add(connectToRadioGroup_onBeforeChanged(&handleRadioGroup_onBeforeChanged));
        con_cont.add(connectToRadioGroup_onAfterChanged(&handleRadioGroup_onAfterChanged));
    }
    
    ButtonCheck setTextLabel(dstring text)
    {
    	setChild(Label(text));
    	return this;
    }    
    
    private
    {
    	int indicatorShiftX;
    	int indicatorShiftY;
    }
    
    void recalcIndicatorAndChildPositions()
    {
    	auto iA = getIndicatorAlignment();
    	
    	const auto indicatorSize = 12;
    	const auto indicatorSizeHalf =
    	cast(typeof(indicatorSize)) indicatorSize / 2;
    	
    	auto thisWidth = getWidth();
    	auto thisHeight = getHeight();
    	// cast(typeof(thisWidth)) thisWidthHalf / 2;
    	// cast(typeof(thisHeight)) thisWidthHalf / 2;
    	
    	int indicatorX2;
    	int indicatorY2;
    	
    	// align indicator
    	final switch (iA)
    	{
    	case ButtonCheckIndicatorAlignment.CornerTopLeft:
    		indicatorShiftX = 0;
    		indicatorShiftY = 0;
    		indicatorX2 = indicatorShiftX + indicatorSize;
    		indicatorY2 = indicatorShiftY + indicatorSize;
    		break;
    	case ButtonCheckIndicatorAlignment.CornerTopRight:
    		indicatorShiftX = thisWidth - indicatorSize;
    		indicatorShiftY = 0;
    		indicatorX2 = thisWidth;
    		indicatorY2 = indicatorShiftY + indicatorSize;
    		break;
    	case ButtonCheckIndicatorAlignment.CornerBottomLeft:
    		indicatorShiftX = 0;
    		indicatorShiftY = thisHeight - indicatorSize;
    		indicatorX2 = indicatorShiftX + indicatorSize;
    		indicatorY2 = thisHeight;
    		break;
    	case ButtonCheckIndicatorAlignment.CornerBottomRight:
    		indicatorShiftX = thisWidth - indicatorSize;
    		indicatorShiftY = thisHeight - indicatorSize;
    		indicatorX2 = thisWidth;
    		indicatorY2 = thisHeight;
    		break;
    		
    	case ButtonCheckIndicatorAlignment.LeftTop:
    		goto case ButtonCheckIndicatorAlignment.CornerTopLeft;
    	case ButtonCheckIndicatorAlignment.LeftMiddle:
    		indicatorShiftX = 0;
    		indicatorShiftY = thisHeight/2 - indicatorSizeHalf;
    		indicatorX2 = indicatorShiftX + indicatorSize;
    		indicatorY2 = thisHeight/2 + indicatorSizeHalf;
    		break;
    	case ButtonCheckIndicatorAlignment.LeftBottom:
    		goto case ButtonCheckIndicatorAlignment.CornerBottomLeft;
    		
    	case ButtonCheckIndicatorAlignment.RightTop:
    		goto case ButtonCheckIndicatorAlignment.CornerTopRight;
    	case ButtonCheckIndicatorAlignment.RightMiddle:
    		indicatorShiftX = thisWidth - indicatorSize;
    		indicatorShiftY = thisHeight/2 - indicatorSizeHalf;
    		indicatorX2 = thisWidth;
    		indicatorY2 = thisHeight/2 + indicatorSizeHalf;
    		break;
    	case ButtonCheckIndicatorAlignment.RightBottom:
    		goto case ButtonCheckIndicatorAlignment.CornerBottomRight;
    		
    	case ButtonCheckIndicatorAlignment.TopLeft:
    		goto case ButtonCheckIndicatorAlignment.CornerTopLeft;
    	case ButtonCheckIndicatorAlignment.TopMiddle:
    		indicatorShiftX = thisWidth/2 - indicatorSizeHalf;
    		indicatorShiftY = 0;
    		indicatorX2 = thisWidth/2 + indicatorSizeHalf;
    		indicatorY2 = indicatorShiftY + indicatorSize;
    		break;
    	case ButtonCheckIndicatorAlignment.TopRight:
    		goto case ButtonCheckIndicatorAlignment.CornerTopRight;
    		
    	case ButtonCheckIndicatorAlignment.BottomLeft:
    		goto case ButtonCheckIndicatorAlignment.CornerBottomLeft;
    	case ButtonCheckIndicatorAlignment.BottomMiddle:
    		int tw = thisWidth/2;
    		int th = thisHeight/2;
    		indicatorShiftX = tw - indicatorSizeHalf;
    		indicatorShiftY = th - indicatorSizeHalf;
    		indicatorX2 = tw + indicatorSizeHalf;
    		indicatorY2 = th + indicatorSizeHalf;
    		break;
    	case ButtonCheckIndicatorAlignment.BottomRight:
    		goto case ButtonCheckIndicatorAlignment.CornerBottomRight;
    	}
    	
    	auto child = getChild();
    	
    	if (child !is null)
    	{
    		// align child
    		final switch (iA)
    		{
    		case ButtonCheckIndicatorAlignment.CornerTopLeft:    		
    		case ButtonCheckIndicatorAlignment.CornerTopRight:
    		case ButtonCheckIndicatorAlignment.CornerBottomLeft:
    		case ButtonCheckIndicatorAlignment.CornerBottomRight:
    			break;
    			
    		case ButtonCheckIndicatorAlignment.LeftTop:
    		case ButtonCheckIndicatorAlignment.LeftMiddle:
    		case ButtonCheckIndicatorAlignment.LeftBottom:
    			child.setX(indicatorSize);
    			child.setY(0);
    			child.setWidth(thisWidth-indicatorSize);
    			child.setHeight(thisHeight);
    			break;
    		case ButtonCheckIndicatorAlignment.RightTop:
    		case ButtonCheckIndicatorAlignment.RightMiddle:
    		case ButtonCheckIndicatorAlignment.RightBottom:
    			child.setX(0);
    			child.setY(0);
    			child.setWidth(thisWidth-indicatorSize);
    			child.setHeight(thisHeight);
    			break;
    		case ButtonCheckIndicatorAlignment.TopLeft:
    		case ButtonCheckIndicatorAlignment.TopMiddle:
    		case ButtonCheckIndicatorAlignment.TopRight:
    			child.setX(0);
    			child.setY(indicatorSize);
    			child.setWidth(thisWidth);
    			child.setHeight(thisHeight-indicatorSize);
    			break;
    		case ButtonCheckIndicatorAlignment.BottomLeft:
    		case ButtonCheckIndicatorAlignment.BottomMiddle:
    		case ButtonCheckIndicatorAlignment.BottomRight:
    			child.setX(0);
    			child.setY(0);
    			child.setWidth(thisWidth);
    			child.setHeight(thisHeight-indicatorSize);
    			break;
    		}
    	}
    	
    }
    
    override void propagatePosAndSizeRecalcBefore()
    {
    	recalcIndicatorAndChildPositions();
    }
    
    override Image renderImage()
    {
    	debug writeln(this, ".renderImage() called");
    	Form form = this.getForm();
    	if (form is null)
    	{
    		throw new Exception(
    			this.toString() ~ ".renderImage() can't get Form"
    			);
    	}
    	
    	auto laf = form.getLaf();
    	if (laf is null)
    	{
    		throw new Exception("Laf not set");
    	}
    	
    	auto w = getWidth();
    	auto h = getHeight();
    	
    	auto ds = new Image(w, h);
    	
    	if (getRadioGroup() is null)
    	{
    		laf.drawButtonCheck(this, ds);
    	}
    	else
    	{
    		laf.drawButtonRadio(this, ds);
    	}
    	
    	return ds;
    }
    
    private void handleRadioGroup_onBeforeChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
    	
        collectException(
        	{
        		if (old_v !is null)
        			if (old_v.isIn(this))
                    old_v.remove(this);
            }()
            );
    }
    
    private void handleRadioGroup_onAfterChanged(RadioGroup old_v, RadioGroup new_v) nothrow
    {
    	
        collectException(
        	{
        		if (new_v !is null)
        			if (!new_v.isIn(this))
                    new_v.add(this);
            }()
            );
    }
    
    override void intMousePressRelease(Widget widget, EventForm* event)
    {
    	auto rg = getRadioGroup();
    	if (rg !is null)
    	{
    		rg.selectButton(this);
    	} 
    	else
    	{
    		setToggledOn(!getToggledOn());
    	}
    	redraw();
    }
}
