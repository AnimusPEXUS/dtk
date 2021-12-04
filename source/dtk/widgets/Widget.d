module dtk.widgets.Widget;

import std.stdio;
import std.conv;
import std.typecons;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;
import dtk.types.Property_mixins;
import dtk.types.MoveT;

import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.miscs.DrawingSurfaceShift;

/* import dtk.widgets.WidgetLocator; */
import dtk.widgets;
/* import dtk.widgets.WidgetDrawingSurface; */

class Widget : WidgetI
{
    private
    {
        mixin Property_gsun!(WidgetI, "parent");
    }

    mixin Property_forwarding!(WidgetI, parent, "Parent");

    // =====v===v===v===== [locator] =====v===v===v===== start

    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
            PropSetting("gs_w_d", "bool", "vertical_expand", "VerticalExpand", "false"),
            PropSetting("gs_w_d", "bool", "horizontal_expand", "HorizontalExpand", "false"),
            PropSetting("gs_w_d", "bool", "vertical_fill", "VerticalFill", "false"),
            PropSetting("gs_w_d", "bool", "horizontal_fill", "HorizontalFill", "false"),
            PropSetting("gs", "Position2D", "position", "Position", ""),
            PropSetting("gs_w_d", "Size2D", "size", "Size", q{Size2D(10, 10)}),
            //PropSetting("gs", "Size2D", "size", "Size", ""),
            PropSetting("gsu", "Size2D", "minimal_size", "MinimalSize", ""),
            PropSetting("gsu", "Size2D", "maximal_size", "MaximalSize", ""),
        ]
        );

    // NOTE: those two properties are really a synonym for their //Horizontal//
    //       analogs
    mixin Property_forwarding!(bool, horizontal_expand, "Expand");
    mixin Property_forwarding!(bool, horizontal_fill, "Fill");


    // =====^===^===^===== [locator] =====^===^===^===== end

    // =====v===v===v===== [info] =====v===v===v===== start

    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
            PropSetting("gs_w_d", "bool", "visible", "Visible", "false"),
            PropSetting("gs_w_d", "bool", "enabled", "Enabled", "false"),
            PropSetting("gs_w_d", "bool", "focusable", "Focusable", "false"),
            PropSetting("gs_w_d", "bool", "focus_kb_capture", "FocusKeyboardCapture", "false"),
            PropSetting("gs_w_d", "bool", "uses_text_input", "UsesTextInput", "false"),
            PropSetting("gs_w_d", "MoveT", "move_type", "MoveType", "MoveT.none"),
        ]
        );

    // =====^===^===^===== [info] =====^===^===^===== end

    // TODO: ensure all subclasses calls for super();
    // NOTE: ensured. init called implicitly by dlang
    this()
    {
    }

    /++ return FormI on which this Widget is placed. returns null in case if
    there is no attached form or if this widget is deeper than 200 levels to
    FormI instance (too deep); +/
    FormI getForm()
    {
        WidgetI w = this;
        Form ret;

        for (auto failure_countdown = cast(byte) 200; failure_countdown != -1; failure_countdown--)
        {

            ret = cast(Form) w;
            if (ret !is null)
            {
                return ret;
            }

            if (w.isUnsetParent())
            {
                return null;
            }

            w = w.getParent();
            if (w is null)
            {
                return null;
            }
        }

        return ret;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        auto p = getPosition();
        return new DrawingSurfaceShift(getParent().getDrawingSurface(), p.x, p.y);
    }

    void redraw()
    {
        this.redraw_x(this);
    }

    void redraw_x(T)(T new_this)
    {

        /* alias A1 = typeof(new_this); */

        const id = __traits(identifier, new_this);
        const id_t = __traits(identifier, T);

        static if (!is(T == Widget))
        {
            const drawid = "draw" ~ id_t;

            FormI form = new_this.getForm();
            if (form is null)
            {
                throw new Exception("error: redraw() function couldn't get Form");
            }

            auto theme = form.getLaf();

            if (theme is null)
            {
                throw new Exception("theme not set");
            }

            static if (!__traits(hasMember, theme, drawid))
            {
                return;
            }
            else
            {
                __traits(getMember, theme, drawid)(new_this);
            }
        }        
    }

    void positionAndSizeRequest(Position2D position, Size2D size)
    {
        setPosition(position);
        setSize(size);
    }

    void recalculateChildrenPositionsAndSizes()
    {
        return;
    }

    bool handle_event_keyboard(EventKeyboard* e)
    {
        return false;
    }

    bool handle_event_mouse(EventMouse* e)
    {
        return false;
    }

    bool handle_event_textinput(EventTextInput* e)
    {
        return false;
    }

    Tuple!(WidgetI, ulong, ulong) getWidgetAtPosition(Position2D point)
    {
        return tuple(cast(WidgetI)this, 0UL, 0UL);
    }
    
    WidgetI getNextFocusableWidget()
    {
        return null;
    }

    WidgetI getPrevFocusableWidget()
    {
        return null;
    }
    
    static foreach(v; ["Keyboard", "Mouse", "TextInput"])
    {
    	import std.format;
    	mixin(
    		q{
				private void delegate(
					Event%1$s *e,
    				ulong mouse_widget_local_x,
    				ulong mouse_widget_local_y,
					)[string] handlers%1$s;     			    			
    			void set%1$sEvent(
    				string name, 
    				void delegate(
    					Event%1$s *e,
    					ulong mouse_widget_local_x,
    					ulong mouse_widget_local_y,
    					) handler
    				)
    			{
    				handlers%1$s[name] = handler;
    			}
    			void call%1$sEvent(
    				string name, 
    				Event%1$s* e,
    				ulong mouse_widget_local_x,
    				ulong mouse_widget_local_y,
    				)
    			{
    				if (name in handlers%1$s)
    				{
    					auto ev = handlers%1$s[name];
    					ev(e,mouse_widget_local_x,mouse_widget_local_y);
    				}
    			}
    			void unset%1$sEvent(string name)
    			{
    				handlers%1$s.remove(name);
    			}
    		}.format(v)
    		);
    }
    

}
