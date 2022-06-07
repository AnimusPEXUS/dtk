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
				if (!form)
					throw new Exception(
						this.toString() ~ ".renderImage() can't get Form"
						);
				
				auto laf = form.getLaf();
				if (!laf)
					throw new Exception("Laf not set");
				
				auto w = getWidth();
				auto h = getHeight();
				
				auto ds = new Image(w, h);
				
				laf.draw%1$s(this, ds);
				
				return ds;
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
