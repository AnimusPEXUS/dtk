module dtk.widgets.mixins;

import std.stdio;

mixin template mixin_forwardXYWH_from_Widget()
{
	static foreach (v; ["X", "Y", "Width", "Height"])
    {
    	import std.format;
    	mixin(
    		q{
    			override int get%1$s()
    			{
    				return super.get%1$s();
    			}
    			
    			override typeof(this) set%1$s(int v)
    			{
    				super.set%1$s(v);
    				return this;
    			}
    			
    		}.format(v)
    		);
    }
}

string mixin_simple_parent_change_action()
{
	string ret = q{
		con_cont.add(
    		connectToParent_onAfterChanged(
    			delegate void(
    				ContainerI o,
    				ContainerI n
    				)
    			{
    				collectException(
    					{
    						if (o !is null && o.haveChild(this))
    						{
    							o.removeChild();
    						}
    						
    						if (n !is null && !n.haveChild(this))
    						{
    							n.addChild(this);
    						}
    					}()
    					);
    			}
    			)
    		);
    	
	};
	return ret;
}

mixin template mixin_widget_redraw_using_propagateRedraw()
{
	override void redraw()
    {
		auto img = propagateRedraw();
		auto ds = getDrawingSurface();
		ds.drawImage(Position2D(0,0), img);
		ds.present();
    }
}


/* mixin template mixin_widget_redraw_using_parent()
{
override void redraw()
{
auto p = getParent();
if (p !is null)
{
p.redrawChild(this);
if (present)
{
auto ds = getDrawingSurface();
if (ds !is null)
{
ds.present();
}
}
}
}
} */

mixin template mixin_Widget_renderImage(
	string widgetType,
	string override_str="override"
	)
{
	import std.stdio;
	import std.format;
	
	import dtk.types.Image;
	import dtk.widgets.Form;
	
	mixin(
		q{
			%2$s Image renderImage()
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
				
				// static if (__traits(hasMember, this, "renderImageBeforeDraw"))
				// {
					// this.renderImageBeforeDraw(ds);
				// }
				
				laf.draw%1$s(this, ds);
				
				// static if (__traits(hasMember, this, "renderImageAfterDraw"))
				// {
					// this.renderImageAfterDraw(ds);
				// }
				
				return ds;
			}
			
			%2$s Image renderImage(int x, int y, int w, int h)
			{
				return renderImage().getImage(x,y,w,h);
			}
			
		}.format(widgetType, override_str)
		);
}

mixin template mixin_forward_super_functions(string[] names)
{
	import std.format;
	import std.traits;
	import std.meta;
	
	static foreach (v; names)
	{
		mixin(
			q{
				override ReturnType!(super.%1$s) %1$s(AliasSeq!(Parameters!(super.%1$s)) args)
				{
					return super.%1$s(args);
				}
			}.format(v)
			);
	}
}

/* 
mixin template mixin_propagateRedraw_children_none(string override_str="override")
{
	import std.format;
	mixin(
		q{
			%1$s Image propagateRedraw()
			{
				auto img = this.renderImage();
				return img;
			}
    	}.format(override_str)
    	);
} */

/* mixin template mixin_propagateRedraw_children_one(string override_str="override")
{
	import std.format;
	mixin(
		q{
			%1$s Image propagateRedraw()
			{
				auto img = this.renderImage();
				
				// pragma(msg, "typeof this ", typeof(getChild));
				
				auto c = getChild();
				if (c !is null)
				{
					auto c_img = c.propagateRedraw();
					this.drawChild(img, c, c_img);
				}
				return img;
			}
		}.format(override_str)
		);
}
 */

/* string mixin_propagateParentChangeEmission_this()
{
return q{
import core.sync.mutex;
propagateParentChangeEmission_recursion_protection_mtx = new Mutex();
};
} */

/* mixin template mixin_propagateParentChangeEmission()
{
	private
    {
		import core.sync.mutex;
    	bool propagateParentChangeEmission_recursion_protection;
    	Mutex propagateParentChangeEmission_recursion_protection_mtx;
    }
    
    override void propagateParentChangeEmission()
    {
    	import dtk.miscs.recursionGuard;
    	import core.sync.mutex;
    	
    	synchronized
    	{
    		if (propagateParentChangeEmission_recursion_protection_mtx is null)
    			propagateParentChangeEmission_recursion_protection_mtx = new Mutex();
    		
    		recursionGuard(
    			propagateParentChangeEmission_recursion_protection,
    			propagateParentChangeEmission_recursion_protection_mtx,
    			0,
    			delegate int() {
    				import dtk.widgets.Form;
    				
    				static if (is(typeof(this) == Form))
    				{
    					pragma(msg, "propagateParentChangeEmission for Form");
    					setWindow(getWindow());
    				}
    				else
    				{
    					pragma(msg, "propagateParentChangeEmission for simple widget");
    					setParent(getParent());
    				}
    				
    				static if (__traits(hasMember, this, "children"))
    				{
    					foreach (c; children)
    					{
    						c.child.propagateParentChangeEmission();
    					}
    				}
    				else static if (__traits(hasMember, this, "getChild"))
    				{
    					auto c = getChild();
    					if (c !is null)
    						c.propagateParentChangeEmission();
    				}
    				return 0;
    			}
    			);
    	}
    }
} */

/* string mixin_widgetSingleChildSet01(string varname)
{
	import std.format;
	string ret;
	ret = q{
		%s = connectToChild_onAfterChanged(
    		delegate void(
    			WidgetI o,
    			WidgetI n
    			)
    		{
    			collectException(
    				{
    					if (o !is null)
    						o.unsetParent();
    					if (n !is null && n.getParent() != this)
    					{
    						n.setParent(this);
    						debug writeln(n, " setParent ", this);
    					}
    				}()
    				);
    		}
    		);
	}.format(varname);
	return ret;
} */

/* mixin template mixin_WidgetFunctions()
{
	static foreach (
    	code; 
    	[
    	q{void propagateParentChangeEmission()},
    	q{void propagatePosAndSizeRecalc()},
    	q{Image propagateRedraw()},
    	q{void redraw()},
    	q{Image renderImage(int x, int y, int w, int h)},
    	q{Image renderImage()},
    	q{void drawChild(WidgetI child, Image img)},
    	q{void drawChild(DrawingSurfaceI ds, WidgetI child, Image img)},
    	q{int getChildX(WidgetI child)},
    	q{int getChildY(WidgetI child)},
    	q{int getChildWidth(WidgetI child)},
    	q{int getChildHeight(WidgetI child)},
    	q{void setChildX(WidgetI child, int v)},
    	q{void setChildY(WidgetI child, int v)},
    	q{void setChildWidth(WidgetI child, int v)},
    	q{void setChildHeight(WidgetI child, int v)},
    	q{int getChildMinCount()},
    	q{int getChildMaxCount()},
    	q{int getChildCount()},
    	q{WidgetI getChild()},
    	q{WidgetI getChild(int i)},
    	q{void addChild(WidgetI child)},
    	q{void removeChild(WidgetI child)},
    	q{bool haveChild(WidgetI child)},
    	]
    	)
    {
    	mixin(
    		q{
    			%s
    			{
    				static assert(false, "must be reimplemented");
    				throw new Exception("must be reimplemented");
    			}    			
    		}.format(code)
    		);
    }
    
    void focusEnter(Form form, WidgetI widget) {}
    void focusExit(Form form, WidgetI widget) {}
    
    bool isVisuallyPressed() {return false;}
    void visualPress(Form form, WidgetI widget, EventForm* event) {}
    void visualRelease(Form form, WidgetI widget, EventForm* event) {}
    
    void intMousePress(Form form, WidgetI widget, EventForm* event) {}
    void intMouseRelease(Form form, WidgetI widget, EventForm* event) {}
    void intMousePressRelease(Form form, WidgetI widget, EventForm* event) {}
    void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event) {}
    void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event) {}
    void intMouseMove(Form form, WidgetI widget, EventForm* event) {}
    
    void intKeyboardPress(Form form, WidgetI widget, EventForm* event) {}
    void intKeyboardRelease(Form form, WidgetI widget, EventForm* event) {}
    
    void  intTextInput(Form form, WidgetI widget, EventForm* event) {}
}*/

/* mixin template mixin_WidgetChildrenFunctionsSingle()
{
	
} */

/* mixin template mixin_WidgetChildrenFunctionsNone()
{
	void propagateParentChangeEmission()
	void propagatePosAndSizeRecalc()
	Image propagateRedraw()
	void redraw()
	Image renderImage(int x, int y, int w, int h)
	Image renderImage(),
	void drawChild(WidgetI child, Image img)
	void drawChild(DrawingSurfaceI ds, WidgetI child, Image img)
	int getChildX(WidgetI child)
	int getChildY(WidgetI child)
	int getChildWidth(WidgetI child)
	int getChildHeight(WidgetI child)
	void setChildX(WidgetI child, int v)
	void setChildY(WidgetI child, int v)
	void setChildWidth(WidgetI child, int v)
	void setChildHeight(WidgetI child, int v)
	int getChildMinCount()
	int getChildMaxCount()
	int getChildCount()
	WidgetI getChild()
	WidgetI getChild(int i)
	void addChild(WidgetI child)
	void removeChild(WidgetI child)
	bool haveChild(WidgetI child)
	
	
	void focusEnter(Form form, WidgetI widget) {}
    void focusExit(Form form, WidgetI widget) {}
    
    bool isVisuallyPressed() {return false;}
    void visualPress(Form form, WidgetI widget, EventForm* event) {}
    void visualRelease(Form form, WidgetI widget, EventForm* event) {}
    
    void intMousePress(Form form, WidgetI widget, EventForm* event) {}
    void intMouseRelease(Form form, WidgetI widget, EventForm* event) {}
    void intMousePressRelease(Form form, WidgetI widget, EventForm* event) {}
    void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event) {}
    void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event) {}
    void intMouseMove(Form form, WidgetI widget, EventForm* event) {}
    
    void intKeyboardPress(Form form, WidgetI widget, EventForm* event) {}
    void intKeyboardRelease(Form form, WidgetI widget, EventForm* event) {}
    
    void intTextInput(Form form, WidgetI widget, EventForm* event) {}
} */