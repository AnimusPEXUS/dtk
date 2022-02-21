module dtk.widgets.TextEntry;

import std.stdio;
import std.typecons;
import std.exception;
import std.format;

import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.Property;
import dtk.types.Image;
import dtk.types.Color;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.widgets.Form;
import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.TextProcessor;
import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.signal_tools;

const auto TextEntryProperties = cast(PropSetting[]) [
PropSetting("gs", "dstring", "text", "Text"),
// TODO: use fontconfig instead of this
PropSetting("gs_w_d", "string", "font_family", "FontFamily", "\"Go\""),
PropSetting("gs_w_d", "string", "font_style", "FontStyle", "\"Regular\""),
PropSetting("gs_w_d", "Color", "font_color", "FontColor", q{Color(0)}),
PropSetting("gs_w_d", "ushort", "font_size", "FontSize", "9"),
PropSetting("gs_w_d", "bool", "font_italic", "FontItalic", "false"),
PropSetting("gs_w_d", "bool", "font_bold", "FontBold", "false"),
PropSetting("gs_w_d", "GenVisibilityMapForSubitemsLayout", "layout_lines", "LayoutLines", "GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft"),
PropSetting("gs_w_d", "GenVisibilityMapForSubitemsLayout", "layout_line_chars", "LayoutChars", "GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop"),
PropSetting("gs_w_d", "bool", "draw_bewel_and_background", "DrawBewelAndBackground", "false"),
PropSetting("gs_w_d", "Color", "bewel_background_color", "BewelBackgroundColor", q{Color(cast(ubyte[3])[255,255,255])}),
PropSetting("gs_w_d", "bool", "multiline", "Multiline", "false"),
PropSetting("gs_w_d", "bool", "virtual_wrap_by_char", "VirtualWrapByChar", "false"),
PropSetting("gs_w_d", "bool", "virtual_wrap_by_word", "VirtualWrapByWord", "false"),
PropSetting("gs_w_d", "bool", "force_monowidth", "ForceMonowidth", "false"),
PropSetting("gs_w_d", "bool", "text_selectable", "TextSelectable", "false"),
PropSetting("gs_w_d", "bool", "text_editable", "TextEditable", "false"),
PropSetting("gs_w_d", "bool", "cursor_enabled", "CursorEnabled", "false"),
];

class TextEntry : Widget, WidgetI
{
	
    mixin mixin_multiple_properties_define!(TextEntryProperties);
    mixin mixin_multiple_properties_forward!(TextEntryProperties, false);
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_forward_super_functions!(
    	[
    	"getForm",
    	"getNextFocusableWidget",
    	"getPrevFocusableWidget",
    	"propagatePosAndSizeRecalc",
    	"getChildAtPosition",
    	"getDrawingSurface"
    	]
    	);
    mixin mixin_Widget_renderImage!("TextEntry");
    mixin mixin_widget_redraw_using_parent!();
    
    TextView text_view;
    
    private {
        SignalConnectionContainer con_cont;
        SignalConnection textViewConnCon;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(TextEntryProperties));
    	
        text_view = new TextView();
        text_view.getForm = delegate Form()
        {
            auto f = getForm();
            if (f is null)
            {
                throw new Exception("can't get form");
            }
            
            return f;
        };
        
        text_view.getDrawingSurface = &getDrawingSurfaceForTextView;
        
        text_view.isFocused = delegate bool()
        {
            auto f = getForm();
            if (f is null)
            {
                throw new Exception("can't get form");
            }
            
            return f.getFocusedWidget() == this;
        };        
        
        struct stname {
            string sname;
            string tname;
        }
        
        static foreach(
            v;
            [
            stname("FontFamily", "string"),
            stname("FontStyle", "string"),
            stname("FontColor", "Color"),
            stname("FontSize", "ushort"),
            stname("FontItalic", "bool"),
            stname("FontBold", "bool"),
            stname("LayoutLines", "GenVisibilityMapForSubitemsLayout"),
            stname("LayoutChars", "GenVisibilityMapForSubitemsLayout"),
            stname("DrawBewelAndBackground", "bool"),
            stname("BewelBackgroundColor", "Color"),
            stname("Multiline", "bool"),
            stname("VirtualWrapByChar", "bool"),
            stname("VirtualWrapByWord", "bool"),
            stname("ForceMonowidth", "bool"),
            stname("TextSelectable", "bool"),
            stname("TextEditable", "bool"),
            stname("CursorEnabled", "bool"),
            ]
            )
        {
            mixin(
                q{
                    con_cont.add(
                        connectTo%1$s_onAfterChanged(
                            delegate void (%2$s v1, %2$s v2)
                            {
                                collectException(
                                    {
                                        auto err = collectException(
                                            applySettingsToTextProcessor()
                                            );
                                        if (err !is null)
                                        {
                                            writeln(err);
                                        }
                                    }()
                                    );
                            }
                            )
                        );
                }.format(v.sname, v.tname));
        }
        
        /* con_cont.add(
        connectToSize_onAfterChanged(
        delegate void(Size2D old_value, Size2D new_value)
        {
        collectException(
        {
        auto err = collectException(
        applySettingsToTextProcessor()
        );
        if (err !is null)
        {
        writeln(err);
        }
        }()
        );
        }
        )
        ); */
        
        /*  con_cont.add(connectToText_onAfterChanged(&afterTextChanged)); */
        
        /*  setMouseEvent("button-click", &on_mouse_click_internal);
        setTextInputEvent("text-input", &on_text_input_internal);
        
        setKeyboardEvent("key-down", &on_keyboard_down_internal);
        setKeyboardEvent("key-up", &on_keyboard_up_internal); */
        
        // textViewConnCon = text_view.connectTo_PerformRedraw(
        // &on_textview_redraw_request
        // );
        
        // textViewTimerConnection = getForm()
        
    }
    
    DrawingSurfaceI getDrawingSurfaceForTextView()
    {
    	/*        auto p = getPosition();
        if (getDrawBewelAndBackground())
        {
        p.x+=2;
        p.y+=2;
        }
        return new DrawingSurfaceShift(getParent().getDrawingSurface(), p.x,p.y); */
        return null;
    }
    
    void on_mouse_click_internal(
        EventMouse* event,
        ulong x,
        ulong y
        )
    {
        auto f = getForm();
        f.focusTo(this);
        
        if (getDrawBewelAndBackground())
        {
            if (x <= 2 || y <= 2)
                return;
            x -= 2;
            y -= 2;
        }
        
        text_view.click(x, y);
        
        return ;
    }
    
    void on_text_input_internal(
        EventTextInput* event,
        ulong x,
        ulong y
        )
    {
        text_view.textInput(event.text);
        redraw(); // TODO: maybe this is too expansive and optimization is required
    }
    
    void on_keyboard_internal(
    	string type, // TODO: better type for parameter
        EventKeyboard* event,
        ulong x,
        ulong y
        )
    {
    	debug writeln("EventKeyboard: ");        
    	debug writeln(" key_state: ", event.key_state);        
    	debug writeln("      type: ", type);        
    	debug writeln("    repeat: ", event.repeat);        
    	debug writeln("    keysym: ", event.keysym);
    	
        text_view.keyboardInput(type, event);
    }
    
    void on_keyboard_up_internal(
        EventKeyboard* event,
        ulong x,
        ulong y
        )
    {
    	on_keyboard_internal("up", event, x,y);
    }
    
    void on_keyboard_down_internal(
        EventKeyboard* event,
        ulong x,
        ulong y
        )
    {
    	on_keyboard_internal("down", event, x,y);    	      
    }
    
    private void afterTextChanged(dstring old_val, dstring new_val) nothrow
    {
        collectException(
            {
            	
                auto err = collectException(
                    {
                        auto x = getText();
                        text_view.setText(x);
                        // auto y = text_view.getTextString();
                        
                        applySettingsToTextProcessor();
                    }()
                    );
                if (err !is null)
                {
                    writeln(err);
                }
            }()
            );
    }
    
    void applySettingsToTextProcessor()
    {
        /* text_view.setText(getText()); */ // NOTE: too expansive probably
        /*         
        auto tvt = text_view.getText();
        
        tvt.setFaceFamily(getFontFamily());
        tvt.setFaceStyle(getFontStyle());
        tvt.setFaceSize(getFontSize() * 64);
        tvt.setDefaultFGColor(getFontColor());
        tvt.setFaceResolution(72);
        tvt.setBold(getFontBold());
        tvt.setItalic(getFontItalic());
        tvt.setLinesLayout(getLayoutLines());
        tvt.setLineCharsLayout(getLayoutChars());
        
        auto size = getSize();
        text_view.setWidth(size.width);
        text_view.setHeight(size.height);
        
        if (getDrawBewelAndBackground())
        {
        // TODO: optimize this: must be as less view redrawings as possible
        text_view.setWidth(text_view.getWidth()-4);
        text_view.setHeight(text_view.getHeight()-4);
        tvt.setDefaultBGColor(getBewelBackgroundColor());
        } else {
        // TODO: get default form color from Theme
        tvt.setDefaultBGColor(Color(0xc0c0c0));
        }
        
        text_view.setTextSelectionEnabled(getTextSelectable());
        text_view.setReadOnly(!getTextEditable());
        text_view.setCursorEnabled(getCursorEnabled()); */
    }
    
    //mixin mixin_getWidgetAtPosition;
    
    override void propagatePosAndSizeRecalc()
    {
    }
    
    override void propagateRedraw()
    {
    }
    
    override Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI)this, point);
    	// return tuple(cast(WidgetI)null, point);
    }
}
