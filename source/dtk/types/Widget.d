module dtk.types.Widget;

import core.sync.mutex;

import std.stdio;
import std.exception;
import std.typecons;
import std.variant;
import std.format;

import dtk.interfaces.PlatformI;
import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LaFI;
// import dtk.interfaces.LayoutChildSettingsI;

import dtk.types.Property;
import dtk.types.Image;
import dtk.types.Event;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.VisibilityMap;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;

import dtk.miscs.signal_tools;
import dtk.miscs.calculateVisiblePart;
import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.recursionGuard;

import dtk.widgets.Form;
import dtk.widgets.Menu;

// import dtk.signal_mixins.Widget;

enum ViewPortChildrenPosAndSizeReaction : ubyte
{
    Ignore, // do nothing
    Clip = Ignore, // don't draw overflows
    Scroll, // show scrollbars
    Resize, // resize ViewPort by contents
}

// enum WidgetAgainstViewPortSizePolicy : ubyte
// {
// ViewPortResizeByWidget,
// WidgetResizeByViewPort,
// }

// enum WidgetResizeAndViewportPolicy : ubyte
// {
// WidgetDictatesChild
// }

// enum LayoutType : ubyte
// {
// undefined,
// linearScrolled,
// linearWrapped,
// }


const auto WidgetChildProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "int", "x", "X", q{0}),
PropSetting("gs_w_d", "int", "y", "Y", q{0}),
PropSetting("gs_w_d", "int", "width", "Width", q{0}),
PropSetting("gs_w_d", "int", "height", "Height", q{0}),

// Each Layout Engine have it's own set of parameters for each child,
// so LayoutChild somehow have to store settings for any engine child.
// here's how it does this.
//PropSetting("gsun", "LayoutChildSettingsI", "settings", "Settings", "null"),
];


class WidgetChild
{
	Widget self;
	Widget child;
	
    mixin mixin_multiple_properties_define!(WidgetChildProperties);
    mixin mixin_multiple_properties_forward!(WidgetChildProperties, false);
    
    this(Widget self, Widget child)
    {
    	mixin(mixin_multiple_properties_inst(WidgetChildProperties));
    	
    	this.self = self;
    	this.child = child;
    }
    
}

const auto WidgetProperties = cast(PropSetting[]) [
PropSetting("gsun", "Widget", "parent", "Parent", q{null}),

PropSetting("gs_w_d_nrp", "int", "desiredX", "DesiredX", q{0}),
PropSetting("gs_w_d_nrp", "int", "desiredY", "DesiredY", q{0}),
PropSetting("gs_w_d_nrp", "int", "desiredWidth", "DesiredWidth", q{0}),
PropSetting("gs_w_d_nrp", "int", "desiredHeight", "DesiredHeight", q{0}),


PropSetting("gsun", "LaFI", "localLaf", "LocalLaf", q{null}),

PropSetting("gs_w_d", "bool", "visuallyPressed", "VisuallyPressed", "false"),

/* PropSetting(
"gs_w_d",
"bool",
"triggerPropagatePosAndSizeRecalcOnChildrenPosSizeChange",
"TriggerPropagatePosAndSizeRecalcOnChildrenPosSizeChange",
"true"
), */

// PropSetting("gs_w_d", "bool", "toggledOn", "ToggledOn", "0"),
];

// alias renderFunctionLinkType = void delegate(Widget e, DrawingSurfaceI ds);

class Widget
{
	// mixin(mixin_WidgetSignals(false));
	mixin mixin_multiple_properties_define!(WidgetProperties);
    mixin mixin_multiple_properties_forward!(WidgetProperties, false);
    
	private
    {
    	SignalConnection sc_windowChange;
    	SignalConnection sc_focusedWidgetChange;
    	
    	SignalConnection sc_windowOtherEvents;
    	SignalConnection sc_windowEvents;
    	
    	SignalConnection sc_formEventHandler;
    	
    	SignalConnection sc_desiredXChange;
    	SignalConnection sc_desiredYChange;
    	SignalConnection sc_desiredWidthChange;
    	SignalConnection sc_desiredHeightChange;
    }
    
	this()
	{
		mixin(mixin_multiple_properties_inst(WidgetProperties));
		
    	sc_desiredXChange = connectToDesiredX_onAfterChanged(&desiredXYWHchangedInformParent);
    	sc_desiredYChange = connectToDesiredY_onAfterChanged(&desiredXYWHchangedInformParent);
    	sc_desiredWidthChange = connectToDesiredWidth_onAfterChanged(&desiredXYWHchangedInformParent);
    	sc_desiredHeightChange = connectToDesiredHeight_onAfterChanged(&desiredXYWHchangedInformParent);
	}
	
	public
    {
    	// Set laying out function.
    	
    	// This function can (but not required to) use children's desired XYWH
    	// to position children on widdget (set children's actual XYWH).
    	
    	// This function is allowed to set desired XYWH of current widget.
    	
    	// THIS FUNCTION SHOULD NOT CHANGE CURRENT WIDGET'S ACTUAL XYWH.
    	
    	// THIS FUNCTION SHOULD NOT CHANGE CHILDREN'S DESIRED XYWH.
    	
    	// CURRENT WIDGET'S ACTUAL XYWH IS ONLY ALLOWED TO BE CHANGED BY
    	// PARRENT'S performLayout().
    	
    	// on widgets with viewport, this function is allowed to change
    	// ViewPort positions (both external and internal) and sizes.
    	
    	// NOTE: Layout ViewPort is never resized by it self. use performLayout to
    	//       position and resize ViewPort
		void delegate(Widget w) performLayout;
	}
	
    Widget setPerformLayout(void delegate(Widget w) performLayout)
    {
    	this.performLayout = performLayout;
    	return this;
    }
    
    private void desiredXYWHchangedInformParent(int int0, int int1) nothrow
    {
    	if (int0 == int1)
    		return;
    	
    	collectException(
    		{
    			auto p = getParent();
    			if (p)
    				p.childWidgetXYWHChanged(this);
    		}()
    		);
    }
    
    private void childWidgetXYWHChanged(Widget w)
    {
    	debug writeln(
    		"%s child %s desired values changed: %sx%s %sx%s".format(
    			this,
    			w,
    			w.getDesiredX(),
    			w.getDesiredY(),
    			w.getDesiredWidth(),
    			w.getDesiredHeight(),
    			)
    		);
    	// if (getTriggerPropagatePosAndSizeRecalcOnChildrenPosSizeChange())
    	// {
    	propagatePerformLayout();
    	// }
    }
    
 	static foreach(v; ["Width", "Height", "X", "Y"])
	{
		mixin(
			q{
				int get%1$s()
				{
					int ret;
					Widget parent;
					WindowI window;
					Form f;
					
					parent = getParent();
					// if (parent is null)
					// {
					// throw new Exception("couldn't get parent");
					// }
					
					f = cast(Form) this;
					if (f !is null)
					{
						assert(
							!(parent && window),
							"on Form only parent or window can be set semiltaniously"
							);
						window = f.getWindow();
					}
					
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
					Widget parent;
					WindowI window;
					Form f;
					
					parent = getParent();
					
					f = cast(Form) this;
					if (f !is null)
					{
						assert(
							!(parent && window),
							"on Form only parent or window can be set semiltaniously"
							);
						window = f.getWindow();
					}
					
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
						throw new Exception("nor window nor parent is set - can't change own size or position");
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
    					debug writeln(child, " is not a child of current widget");
    					// TODO: is this good place for exception
    					throw new Exception("object is not a child of current widget");
    				}
    				return c.get%1$s();
    			}
    			
    			void setChild%1$s(Widget child, int v)
    			{
    				auto c = getWidgetChildByChild(child);
    				if (c is null)
    				{
    					debug writeln(child, " is not a child of current widget");
    					// TODO: is this good place for exception
    					throw new Exception("object is not a child of current widget");
    				}
    				c.set%1$s(v);
    				return;
    			}
    		}.format(v)
    		);
    }
    
    Image renderImage()
    {
    	throw new Exception("override this");
    }
    
    final Image renderImage(int x, int y, int w, int h)
    {
    	return renderImage().getImage(x,y, w, h);
    }
    
    private
    {
    	bool getForm_recursion_protection_bool;
    	Mutex getForm_recursion_protection_mutex;
    }
    
    final Form getForm()
    {
    	synchronized
    	{
    		if (getForm_recursion_protection_mutex is null)
    			getForm_recursion_protection_mutex = new Mutex();
    		
    		auto ret = recursionGuard(
    			getForm_recursion_protection_bool,
    			getForm_recursion_protection_mutex,
    			delegate Form()
    			{
    				throw new Exception("parent-children circul detected: this is wrong");
    			},
    			delegate Form()
    			{
    				Widget p = this;
    				Form res;
    				
    				while (true)
    				{
    					res = cast(Form) p;
    					if (res !is null)
    					{
    						return res;
    					}
    					
    					p = p.getParent();
    					if (p is null)
    					{
    						return null;
    					}
    				}
    			}
    			);
    		return ret;
    	}
    }
    
    private
    {
    	bool getMenu_recursion_protection_bool;
    	Mutex getMenu_recursion_protection_mutex;
    }
    
    // Returns lates enclosing Menu, if any
    final Menu getMenu()
    {
    	synchronized
    	{
    		if (getMenu_recursion_protection_mutex is null)
    			getMenu_recursion_protection_mutex = new Mutex();
    		
    		auto ret = recursionGuard(
    			getMenu_recursion_protection_bool,
    			getMenu_recursion_protection_mutex,
    			delegate Menu()
    			{
    				throw new Exception("parent-children circul detected: this is wrong");
    			},
    			delegate Menu()
    			{
    				Widget p = this;
    				Menu res;
    				
    				while (true)
    				{
    					res = cast(Menu) p;
    					if (res !is null)
    					{
    						return res;
    					}
    					
    					p = p.getParent();
    					if (p is null)
    					{
    						return null;
    					}
    				}
    			}
    			);
    		return ret;
    	}
    }
    
    final WindowI findWindow()
    {
    	WindowI ret;
    	
    	auto f = getForm();
    	if (f !is null)
    	{
    		ret = f.getWindow();
    	}
    	
    	return ret;
    }
    
    final PlatformI findPlatform()
    {
    	PlatformI ret;
    	
    	auto w = findWindow();
    	if (w !is null)
    	{
    		ret = w.getPlatform();
    	}
    	
    	return ret;
    }
    
    // TODO: delete this function?
	final Widget getFormDefaultWidget()
	{
		return getForm().getDefaultWidget();
	}
	
    // TODO: delete this function?
	final Widget getFormFocusedWidget()
	{
		return getForm().getFocusedWidget();
	}
	
    // TODO: delete this function?
	final void setFormDefaultWidget(Widget e)
	{
		getForm().setDefaultWidget(e);
		return;
	}
	
    // TODO: delete this function?
	final void setFormFocusedWidget(Widget e)
	{
		getForm().setFocusedWidget(e);
		return;
	}
	
	WidgetChild[] calcWidgetChildren()
    {
    	return [];
    }
    
    final int calcWidgetChildrenCount()
    {
    	return cast(int) calcWidgetChildren().length;
    }
    
	final bool haveChild(Widget e)
	{
		foreach (v; calcWidgetChildren())
		{
			if (v.child == e)
			{
				return true;
			}
		}
		return false;
	}
	
	final void fixChildParent(Widget child)
    {
    	if (child.getParent() != this)
    	{
    		child.setParent(this);
    	}
    }
    
	final void fixChildrenParents()
    {
    	foreach_reverse (i, v; calcWidgetChildren())
    	{
    		fixChildParent(v.child);
    	}
    	
    }
    
	void getChildAtPosition(
		Position2D point,
		ref Tuple!(Widget, Position2D)[] breadCrumbs
		)
    {
		breadCrumbs ~= tuple(cast(Widget)this, point);
		
    	auto px = point.x;
		auto py = point.y;
		
		// NOTE: it's better to do in reverse order
		foreach_reverse (v; calcWidgetChildren())
		{
			auto vx = v.getX();
			auto vy = v.getY();
			auto vw = v.getWidth();
			auto vh = v.getHeight();
			
			if (
				px >= vx
			&& px < vx+vw
			
			&& py >= vy
			&& py < vy+vh
			)
			{
				v.child.getChildAtPosition(
					Position2D((px - vx), (py - vy)),
					breadCrumbs
					);
				
				return;
			}
    	}
    	
    	return;
    }
    
    DrawingSurfaceI shiftDrawingSurfaceForChild(
		DrawingSurfaceI ds,
		Widget child
		)
    {
    	if (!haveChild(child))
    		throw new Exception("not a widget child");
    	
    	auto cx = getChildX(child);
    	auto cy = getChildY(child);
    	
        auto ret = new DrawingSurfaceShift(ds, cx, cy);
        
        return ret;
    }
    
    final void propagatePerformLayoutToChildren()
    {
    	foreach (v; calcWidgetChildren())
    	{
    		v.child.propagatePerformLayout();
    	}
    }
    
    void propagatePerformLayout()
    {
    	if (performLayout !is null)
    	{
    		performLayout(this);
    	}
    	else
    	{
    		propagatePerformLayoutToChildren();
    	}
    }
    
    Image propagateRedraw()
    {
    	// if (getForm() is null)
    	// {
    	// return new Image(1, 1);
    	// }
    	
    	auto img = this.renderImage();
    	
    	foreach (c; calcWidgetChildren())
    	{
    		auto cc = c.child;
    		assert(cc !is null);
    		auto c_img = cc.propagateRedraw();
    		this.drawChild(img, cc, c_img);
    	}
    	
    	return img;
    }
    
    WidgetChild getWidgetChildByChild(Widget child)
    {
    	foreach (v; calcWidgetChildren())
    	{
    		if (v.child == child)
    		{
    			return v;
    		}
    	}
    	return null;
    }
    
    final void drawChild(Widget child, Image img)
    {
    	auto ds = getDrawingSurface();
    	drawChild(ds, child, img);
    	return;
    }
    
    final void drawChild(DrawingSurfaceI ds, Widget child, Image img)
    {
    	ds = shiftDrawingSurfaceForChild(ds, child);
    	ds.drawImage(
    		// NOTE: ds should be already shifted to correct position
    		Position2D(0, 0),
    		img
    		);
    }
    
    final void redraw()
    {
		auto img = propagateRedraw();
		auto ds = getDrawingSurface();
		ds.drawImage(Position2D(0,0), img);
		ds.present();
    }
    
    final LaFI getLaf()
    {
    	// TODO: add recursion protection?
    	LaFI ret;
    	
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
    		Form f = cast(Form) this;
    		if (f is null)
    		{
    			goto fail_exit;
    		}
    		auto w = f.getWindow();
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
    
    final DrawingSurfaceI getDrawingSurface()
    {
    	Form f = cast(Form) this;
    	WindowI w;
    	if (f !is null)
    	{
    		w = f.getWindow();
    	}
    	if (w !is null)
    	{
    		return w.getDrawingSurface();
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
    
    // void childChangedXY(WidgetChild c) {}
    // void childChangedWH(WidgetChild c) {}
    // void childChangedXYWH(WidgetChild c) {}
    // void viewPortResizedSelf() {}
    
    // void delegate() propagatePosAndSizeRecalcOverride;
    // void propagatePosAndSizeRecalcBefore() {};
    // void propagatePosAndSizeRecalcAfter() {};
    
    // TODO: mabe remove 'Form form' from events
    void intFocusEnter(Widget widget) {}
    void intFocusExit(Widget widget) {}
    
    bool intIsVisuallyPressed() {return false;}
    
    void intVisuallyPress(Widget widget, EventForm* event) {}
    void intVisuallyRelease(Widget widget, EventForm* event) {}
    
    void intMousePress(Widget widget, EventForm* event) {}
    void intMouseRelease(Widget widget, EventForm* event) {}
    
    public void delegate(EventForm* event) onMousePressRelease;
    
    void intMousePressRelease(Widget widget, EventForm* event) {}
    
    void intMouseLeave(Widget old_w, Widget new_w, EventForm* event) {}
    void intMouseEnter(Widget old_w, Widget new_w, EventForm* event) {}
    void intMouseMove(Widget widget, EventForm* event) {}
    
    void intKeyboardPress(Widget widget, EventForm* event) {}
    void intKeyboardRelease(Widget widget, EventForm* event) {}
    
    void intTextInput(Widget widget, EventForm* event) {}
    
    void intInternalDraggingEventStart(
    	Widget widget,
    	int initX, int initY
    	) {}
    
    void intInternalDraggingEvent(
    	Widget widget,
    	int initX, int initY,
    	int newX, int newY,
    	int relX, int relY
    	) {}
    
    void intInternalDraggingEventEnd(
    	Widget widget,
    	EnumWidgetInternalDraggingEventEndReason reason,
    	int initX, int initY,
    	int newX, int newY,
    	int relX, int relY
    	) {}
}
