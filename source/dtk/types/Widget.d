module dtk.types.Widget;

import std.stdio;
import std.exception;
import std.typecons;
import std.variant;
import std.format;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LafI;
import dtk.interfaces.LayoutEngineI;
import dtk.interfaces.LayoutChildSettingsI;

import dtk.types.Property;
import dtk.types.Image;
import dtk.types.Event;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.VisibilityMap;

import dtk.miscs.signal_tools;
import dtk.miscs.calculateVisiblePart;
import dtk.miscs.DrawingSurfaceShift;

import dtk.signal_mixins.Widget;

const auto WidgetChildProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "int", "x", "X", "0"),
PropSetting("gs_w_d", "int", "y", "Y", "0"),
PropSetting("gs_w_d", "int", "width", "Width", "0"),
PropSetting("gs_w_d", "int", "height", "Height", "0"),

// Each Layout Engine have it's own set of parameters for each child,
// so LayoutChild somehow have to store settings for any engine child.
// here's how it does this.
PropSetting("gsun", "LayoutChildSettingsI", "settings", "Settings", "null"),
];


class WidgetChild
{
	Widget child;
	
    mixin mixin_multiple_properties_define!(WidgetChildProperties);
    mixin mixin_multiple_properties_forward!(WidgetChildProperties, false);
    this(Widget child)
    {
    	mixin(mixin_multiple_properties_inst(WidgetChildProperties));
    	this.child = child;
    }
}

const auto WidgetProperties = cast(PropSetting[]) [
PropSetting("gsun", "Widget", "parent", "Parent", q{null}),
PropSetting("gsun", "LafI", "localLaf", "LocalLaf", q{null}),

PropSetting("gsun", "LayoutEngineI", "layout_engine", "LayoutEngine", "null"),

PropSetting("gs_w_d", "int", "viewportX", "ViewPortX", "0"),
PropSetting("gs_w_d", "int", "viewportY", "ViewPortY", "0"),
PropSetting("gs_w_d", "int", "viewportWidth", "ViewPortWidth", "0"),
PropSetting("gs_w_d", "int", "viewportHeight", "ViewPortHeight", "0"),

PropSetting("gs_w_d", "bool", "visuallyPressed", "VisuallyPressed", "0"),
PropSetting("gs_w_d", "bool", "toggledOn", "ToggledOn", "0"),
];

alias renderFunctionLinkType = void delegate(Widget e, DrawingSurfaceI ds);

class Widget
{
	mixin(mixin_WidgetSignals(false));
	mixin mixin_multiple_properties_define!(WidgetProperties);
    mixin mixin_multiple_properties_forward!(WidgetProperties, false);
    
    private
    {
		WidgetChild[] children;
		
		int childrenMin;
		int childrenMax;

		VisibilityMap!(Widget) vm;
    }
    
        
    invariant
    {
        assert(childrenMin >= 0);
        assert(childrenMax >= childrenMin && childrenMin >= -1);
    }
    
	public
	{
		bool visuallyPressed;
		bool toggledOn;
	}
	
	private
    {
    	SignalConnection sc_windowChange;
    	SignalConnection sc_focusedWidgetChange;
    	
    	SignalConnection sc_windowOtherEvents;
    	SignalConnection sc_windowEvents;
    	
    	SignalConnection sc_formEventHandler;
    }
    
	this()
	{
		mixin(mixin_multiple_properties_inst(WidgetProperties));
	}
	

    
	static foreach(v; ["Width", "Height", "X", "Y"])
	{
		mixin(
			q{
				int get%1$s()
				{
					int ret;
					auto parent = getParent();
					auto window = getWindow();
					if (parent !is null)
					{
						ret = parent.getChild%1$s(this);
					}
					else if (window !is null)
					{
						static if ("%1$s" == "X" || "%1$s" == "Y")
						{
							ret = 0;
						}
						else
						{
							ret = window.getForm%1$s();
						}
					}
					else
					{
						ret = 0;
					}
					
					return ret;
				}
				
				Widget set%1$s(int value)
				{
					int ret;
					auto parent = getParent();
					auto window = getWindow();
					if (parent !is null)
					{
						parent.setChild%1$s(this, value);
					}
					else if (window !is null)
					{
						// TODO: make this possible by influencing window
						throw new Exception(
							"root element can't change it's width/height"
							~"/x/y by it's own will"
							);
					}
					else
					{
						throw new Exception("root doesn't have parent so can't change own size or position");
					}
					
					return this;
				}
			}.format(v)
			);
	}
	
	static foreach(v;["X", "Y", "Width", "Height"])
    {
    	
    	mixin(
    		q{
    			int getChild%1$s(Widget child)
    			{
    				auto c = getWidgetChildByChild(child);
    				if (c is null)
    				{
    					debug writeln(child, " is not a layout child");
    					// TODO: is this good place for exception
    					throw new Exception("object is not in layout");
    				}
    				return c.get%1$s();
    			}
    			
    			void setChild%1$s(Widget child, int v)
    			{
    				auto c = getWidgetChildByChild(child);
    				if (c is null)
    				{
    					debug writeln(child, " is not a layout child");
    					// TODO: is this good place for exception
    					throw new Exception("object is not in layout");
    				}
    				c.set%1$s(v);
    				return;
    			}
    		}.format(v)
    		);
    }
    
	Widget getRoot()
	{
		// TODO: add recursion protection
		Widget cur;
		
		cur = this;
		
		while (true)
		{
			
			auto p = cur.getParent();
			
			if (p is null)
			{
				return cur;
			}
			
			cur = p;
		}
	}
	
	Widget getRootDefaultWidget()
	{
		return getRoot().getLocalDefaultWidget();
	}
	
	Widget getRootFocusedWidget()
	{
		return getRoot().getLocalFocusedWidget();
	}
	
	void setRootDefaultWidget(Widget e)
	{
		getRoot().setLocalDefaultWidget(e);
		return;
	}
	
	void setRootFocusedWidget(Widget e)
	{
		getRoot().setLocalFocusedWidget(e);
		return;
	}
	
    int getChildMinCount()
    {
    	return 0;
    }
    
    int getChildMaxCount()
    {
    	return -1;
    }
    
    int getChildCount()
    {
    	return cast(int) children.length;
    }
    
    Widget getChild()
    {
    	if (children.length == 0)
    	{
    		return null;
    	}
    	else
    	{
    		return children[0].child;
    	}
    }
    
    Widget getChild(int i)
    {
    	if (children.length == 0)
    		return null;
    	if (!(i >= 0 && i < children.length))
    		return null;
    	return children[i].child;
    }
    
    void addChild(Widget child)
    {
    	if (!haveChild(child))
    	{
    		children ~= new WidgetChild(child);
    		if (child.getParent() != this)
    		{
    			child.setParent(this);
    		}
    	}
    }
    
    void removeChild(Widget child)
    {
    	if (!haveChild(child))
    		return;
    	
    	Widget[] removed;
    	
    	foreach_reverse (i, v; children)
    	{
    		if (v.child == child)
    		{
    			removed~=v.child;
    			children = children[0 .. i] ~ children[i+1 .. $];
    		}
    	}
    	
    	foreach(v;removed)
    	{
    		v.unsetParent();
    	}
    }
    
	bool haveChild(Widget e)
	{
		foreach (v;children)
		{
			if (v.child == e)
			{
				return true;
			}
		}
		return false;
	}
	
	Tuple!(Widget, Position2D) getChildAtPosition(Position2D point)
    {
    	Widget c;
    	Position2D cp;
    	{
    		auto res = vm.getByPoint(point, false);
    		if (res.length == 0)
    			return tuple(cast(Widget)this, point);
    		auto x = res[$-1];
    		c = x[0].o;
    		cp = x[1];
    		assert(c !is null);
    	}
    	
    	return c.getChildAtPosition(cp);
    }
    
    DrawingSurfaceI shiftDrawingSurfaceForChild(
		DrawingSurfaceI ds,
		Widget child
		)
    {
    	if (!haveChild(child))
    		throw new Exception("not a child");
    	
        auto vp_x = getViewPortX();
    	auto vp_y = getViewPortY();
    	auto vp_w = getViewPortWidth();
    	auto vp_h = getViewPortHeight();
    	
    	auto cx = getChildX(child);
    	auto cy = getChildY(child);
    	auto cw = getChildWidth(child);
    	auto ch = getChildHeight(child);
    	
    	auto res = calculateVisiblePart(
    		vp_x,
    		vp_y,
    		vp_w,
    		vp_h,
    		cx,
    		cy,
    		cw,
    		ch
    		);
    	
        auto ret = new DrawingSurfaceShift(
        	ds,
        	cast(int)res[5],
        	cast(int)res[6]
        	);
        
        return ret;
    }
    
    void propagatePosAndSizeRecalc()
    {
    	auto w = getWidth();
    	auto h = getHeight();
    	
    	setViewPortWidth(w);
    	setViewPortHeight(h);
    	
    	auto la = getLayoutEngine();
    	
    	if (la !is null)
    		la.performLayout();
    	
    	foreach (v; children)
        {
        	v.child.propagatePosAndSizeRecalc();
        }
        
        recalcVisibilityMap();
    }
    
    Image propagateRedraw()
    {
    	auto img = this.renderImage();
    	// auto ds = getDrawingSurface();
    	// ds.drawImage(Position2D(0,0),img);
    	
    	foreach (c; vm.map)
    	{
    		assert(c.o !is null);
    		auto c_img = c.o.propagateRedraw();
    		this.drawChild(img, c.o, c_img);
    	}
    	return img;
    }
    
    void recalcVisibilityMap()
    {
    	vm.init(
    		getViewPortX(),
    		getViewPortY(),
    		getViewPortWidth(),
    		getViewPortHeight()
    		);
    	
    	bool started;
    	foreach (v; children)
    	{
    		auto res = vm.put(
    			v.getX(),
    			v.getY(),
    			v.getWidth(),
    			v.getHeight(),
    			v.child
    			);
    		if (!started && res)
    			started=true;
    		if (started && !res)
    			break;
    	}
    	
    	return;
    }
    
    WidgetChild getWidgetChildByChild(Widget child)
    {
    	foreach (v; children)
    	{
    		if (v.child == child)
    		{
    			return v;
    		}
    	}
    	return null;
    }
    
    void drawChild(Widget child, Image img)
    {
    	auto ds = getDrawingSurface();
    	drawChild(ds, child, img);
    	return;
    }
    
    void drawChild(DrawingSurfaceI ds, Widget child, Image img)
    {
    	ds = shiftDrawingSurfaceForChild(ds, child);
    	
    	auto vp_x = getViewPortX();
    	auto vp_y = getViewPortY();
    	auto vp_w = getViewPortWidth();
    	auto vp_h = getViewPortHeight();
    	
    	auto cx = getChildX(child);
    	auto cy = getChildY(child);
    	auto cw = getChildWidth(child);
    	auto ch = getChildHeight(child);
    	
    	auto res = calculateVisiblePart(
    		vp_x,
    		vp_y,
    		vp_w,
    		vp_h,
    		cx,
    		cy,
    		cw,
    		ch
    		);
    	if (!res[0])
    		return;
    	
    	// auto img = child.renderImage(cast(int)res[1], res[2], res[3], res[4]);
    	ds.drawImage(
    		Position2D(
    			0, 0
    			// NOTE: ds should be already shifted to correct position
    			// cast(int)res[5], cast(int)res[6]
    			),
    		img.getImage(res[1], res[2], res[3], res[4])
    		);
    }
    
    void redraw()
    {
		auto img = propagateRedraw();
		auto ds = getDrawingSurface();
		ds.drawImage(Position2D(0,0), img);
		ds.present();
    }
    
    LafI getLaf()
    {
    	LafI ret;
    	
    	try_get_local_laf:
    	{
    		auto x = getLocalLaf();
    		if (x !is null) {
    			ret = x;
    			goto ok_exit;
    		}
    	}
    	
    	try_get_parent_laf:
    	{
    		auto p = getParent();
    		if (p is null)
    		{
    			goto try_get_window_laf;
    		}
    		auto func_ret = p.getLaf();
    		if (func_ret !is null)
    		{
    			ret = func_ret;
    			goto ok_exit;
    		}
    	}
    	
    	try_get_window_laf:
    	{
    		auto w = getWindow();
    		if (w is null)
    		{
    			goto fail_exit;
    		}
    		auto func_ret = w.getLaf();
    		if (func_ret !is null)
    		{
    			ret = func_ret;
    			goto ok_exit;
    		}    		
    	}
    	
    	fail_exit:
    	ret = null;
    	ok_exit:
    	return ret;
    }
    
	Image renderImage()
    {
    	// debug writeln(this, ".renderImage() called");
    	// Form form = this.getForm();
    	// if (form is null)
    	// {
    	// throw new Exception(
    	// this.toString() ~ ".renderImage() requires Form to be set"
    	// );
    	// }
    	
    	// auto laf = form.getLaf();
    	// if (laf is null)
    	// {
    	// throw new Exception("Laf not set");
    	// }
    	
    	renderFunctionLinkType renderingFunction;
    	
    	if (getRenderingFunctionCB is null)
    	{
    		throw new Exception("getRenderingFunctionCB must be defined");
    	}
    	
    	LafI llaf = getLaf();
    	
    	if (llaf is null)
    	{
    		throw new Exception(
    			"getLaf returned null: "
    			~"Widget can't determine it's drawing function"
    			);
    	}
    	
    	renderingFunction = getRenderingFunctionCB(llaf);
    	
    	if (renderingFunction is null)
    	{
    		throw new Exception("getRenderingFunctionCB returned null");
    	}
    	
    	auto w = getWidth();
    	auto h = getHeight();
    	
    	auto ds = new Image(w, h);
    	
    	// static if (__traits(hasMember, this, "renderImageBeforeDraw"))
    	// {
    	// this.renderImageBeforeDraw(ds);
    	// }
    	
    	renderingFunction(this, ds);
    	
    	// static if (__traits(hasMember, this, "renderImageAfterDraw"))
    	// {
    	// this.renderImageAfterDraw(ds);
    	// }
    	
    	return ds;
    }
    
    Image renderImage(int x, int y, int w, int h)
    {
    	return renderImage().getImage(x,y,w,h);
    }
    
    DrawingSurfaceI getDrawingSurface()
    {
    	if (isSetWindow())
    	{
    		return getWindow().getDrawingSurface();
        }
        else
        {
        	auto p = getParent();
        	if (p is null)
        		throw new Exception("parent is null");
        	auto ds = p.getDrawingSurface();
        	if (ds is null)
        		throw new Exception("parent drawing surface is null");
        	auto dsc = p.shiftDrawingSurfaceForChild(ds, this);
        	if (dsc is null)
        		throw new Exception("parent drawing surface for child is null");
        	return dsc;
        }
    }
    
    void delegate (Widget form, Widget widget) focusEnter;
    void delegate(Widget form, Widget widget)focusExit;
    bool delegate()isVisuallyPressed;
    void delegate(Widget form, Widget widget, EventRootWidget* event)visuallyPress;
    void delegate(Widget form, Widget widget, EventRootWidget* event)visuallyRelease;
    void delegate(Widget form, Widget widget, EventRootWidget* event)intMousePress;
    void delegate(Widget form, Widget widget, EventRootWidget* event)intMouseRelease;
    void delegate(Widget form, Widget widget, EventRootWidget* event)intMousePressRelease;
    void delegate(Widget form, Widget old_w, Widget new_w, EventRootWidget* event)intMouseLeave;
    void delegate(Widget form, Widget old_w, Widget new_w, EventRootWidget* event)intMouseEnter;
    void delegate(Widget form, Widget widget, EventRootWidget* event)intMouseMove;
    void delegate(Widget form, Widget widget, EventRootWidget* event) intKeyboardPress;
    void delegate(Widget form, Widget widget, EventRootWidget* event) intKeyboardRelease;
    void delegate(Widget form, Widget widget, EventRootWidget* event) intTextInput;
}
