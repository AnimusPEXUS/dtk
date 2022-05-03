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
import dtk.types.Event;
import dtk.types.Widget;

// import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
// import dtk.interfaces.Widget;
// import dtk.interfaces.FormI;
import dtk.interfaces.FontMgrI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.widgets.Form;
// import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.TextProcessor;
import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.signal_tools;

const auto TextEntryProperties = cast(PropSetting[]) [
// TODO: use fontconfig instead of this
PropSetting("gs_w_d", "string", "font_family", "FontFamily", "\"Go\""),
PropSetting("gs_w_d", "string", "font_style", "FontStyle", "\"Regular\""),
PropSetting("gs_w_d", "Color", "font_color", "FontColor", q{Color(0)}),
PropSetting("gs_w_d", "ushort", "font_size", "FontSize", "9"),
PropSetting("gs_w_d", "bool", "font_italic", "FontItalic", "false"),
PropSetting("gs_w_d", "bool", "font_bold", "FontBold", "false"),
PropSetting("gs_w_d", "GenVisibilityMapForSubitemsLayout", "layout_lines", "LayoutLines", "GenVisibilityMapForSubitemsLayout.verticalTopToBottomAlignLeft"),
PropSetting("gs_w_d", "GenVisibilityMapForSubitemsLayout", "layout_line_chars", "LayoutChars", "GenVisibilityMapForSubitemsLayout.horizontalLeftToRightAlignTop"),
PropSetting("gs_w_d", "bool", "draw_bewel_and_background", "DrawBewelAndBackground", "true"),
PropSetting("gs_w_d", "Color", "bewel_background_color", "BewelBackgroundColor", q{Color(cast(ubyte[3])[255,255,255])}),
PropSetting("gs_w_d", "bool", "multiline", "Multiline", "false"),
PropSetting("gs_w_d", "bool", "virtual_wrap_by_char", "VirtualWrapByChar", "false"),
PropSetting("gs_w_d", "bool", "virtual_wrap_by_word", "VirtualWrapByWord", "false"),
PropSetting("gs_w_d", "bool", "force_monowidth", "ForceMonowidth", "false"),
PropSetting("gs_w_d", "bool", "text_selectable", "TextSelectable", "false"),
PropSetting("gs_w_d", "bool", "text_editable", "TextEditable", "false"),
PropSetting("gs_w_d", "bool", "cursor_enabled", "CursorEnabled", "false"),
PropSetting("gs_w_d", "bool", "view_resize_by_content", "ViewResizeByContent", "false"),
PropSetting("gs_w_d", "bool", "entry_resize_by_content", "EntryResizeByContent", "false"),
PropSetting("gs_w_d", "bool", "fixedSoftWrapSizeEnabled", "FixedSoftWrapSizeEnabled", "false"),
PropSetting("gs_w_d", "int", "fixedSoftWrapSize", "FixedSoftWrapSize", "300"),
];

TextEntry LineEditor(dstring text)
{
	return new TextEntry().setModePreset("line-editor").setText(text);
}

TextEntry Label(dstring text)
{
	return new TextEntry().setModePreset("label").setText(text);
}

class TextEntry : Widget
{
	
    mixin mixin_multiple_properties_define!(TextEntryProperties);
    mixin mixin_multiple_properties_forward!(TextEntryProperties, false);
    mixin mixin_Widget_renderImage!("TextEntry");
    
    TextView text_view;
    
    private {
        SignalConnectionContainer con_cont;
        SignalConnection textViewConnCon;
    }
    
    TextEntry setModePreset(string value)
    {
    	switch (value)
    	{
    	default:
    		throw new Exception("unsupported");
    	case "line-editor":
    		setDrawBewelAndBackground(true);
    		setMultiline(false);
    		setTextEditable(true);
    		setTextSelectable(true);
    		setCursorEnabled(true);
    		setBewelBackgroundColor(Color(cast(ubyte[3])[255,255,255]));
    		setViewResizeByContent(false);
    		setEntryResizeByContent(false);
    		setFixedSoftWrapSizeEnabled(false);
    		break;
    	case "multiline-editor":
    		setDrawBewelAndBackground(true);
    		setMultiline(true);
    		setTextEditable(true);
    		setTextSelectable(true);
    		setCursorEnabled(true);
    		setBewelBackgroundColor(Color(cast(ubyte[3])[255,255,255]));
    		setViewResizeByContent(false);
    		setEntryResizeByContent(false);
    		setFixedSoftWrapSizeEnabled(true);
    		setFixedSoftWrapSize(300);
    		break;
    	case "label":
    	case "label-noninteractive":
    		setDrawBewelAndBackground(false);
    		setMultiline(true);
    		setTextEditable(false);
    		setTextSelectable(false);
    		setCursorEnabled(false);
    		setBewelBackgroundColor(Color(0xc0c0c0));
    		setViewResizeByContent(true);
    		setEntryResizeByContent(true);
    		setFixedSoftWrapSizeEnabled(true);
    		setFixedSoftWrapSize(300);
    		break;
    	case "label-interactive": 
    		setDrawBewelAndBackground(false);
    		setMultiline(true);
    		setTextEditable(true);
    		setTextSelectable(true);
    		setCursorEnabled(true);
    		setBewelBackgroundColor(Color(0xc0c0c0));
    		setViewResizeByContent(true);
    		setEntryResizeByContent(true);
    		setFixedSoftWrapSizeEnabled(true);
    		setFixedSoftWrapSize(300);
    		break;
    	}
    	return this;
    }
    
    this()
    {
    	super(0, 0);
    	
    	mixin(mixin_multiple_properties_inst(TextEntryProperties));
    	// mixin(mixin_propagateParentChangeEmission_this());
    	
    	setModePreset("multiline-editor");
    	recalcPaddings();
    	
    	{
    		text_view = new TextView();
    		text_view.getForm = delegate Form()
    		{
    			auto f = getForm();
    			if (f is null)
    			{
    				throw new Exception("can't get Form");
    			}
    			
    			return f;
    		};
    		
    		text_view.getDrawingSurface = &getDrawingSurfaceForTextView;
    		
    		text_view.isFocused = delegate bool()
    		{
    			auto f = getForm();
    			if (f is null)
    			{
    				throw new Exception("can't get Form");
    			}
    			
    			return f.getFocusedWidget() == this;
    		};
    		
    		text_view.viewResized = delegate void()
    		{
    			debug writeln("text_view.viewResized called");
    			if (getEntryResizeByContent())
    			{
    				setWidth(text_view.getWidth());
    				setHeight(text_view.getHeight());
    				
    				debug writeln("TextEntry resized by %s x %s".format(getWidth(), getHeight()));
    			}
    		};
        }
        
        
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
            stname("FixedSoftWrapSizeEnabled", "bool"),
            stname("FixedSoftWrapSize", "int"),
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
                                        debug if (err !is null)
                                        {
                                            writeln(err);
                                        }
                                        
                                        static if(is(%1$s == DrawBewelAndBackground))
                                        {
                                        	recalcPaddings();
                                        }
                                    }()
                                    );
                            }
                            )
                        );
                }.format(v.sname, v.tname));
        }
        
    }
    
    dstring getText()
    {
    	return text_view.getText().getText();
    }
    
    TextEntry setText(dstring txt)
    {
    	text_view.setText(txt);
    	
    	/* auto x = collectException({text_view.reprocess();}());
    	if (x !is null)
    	debug writeln("text_view.reprocess error: ", x); */
    	
    	
    	auto x = collectException(
    		{
    			redraw();
    		}()
    		);
    	if (x !is null)
    		debug writeln("redraw error: ", x);
    	
     	return this;
    }
    
    DrawingSurfaceI getDrawingSurfaceForTextView()
    {
    	auto ds = getDrawingSurface();
    	
    	if (getDrawBewelAndBackground())
    	{
    		ds = new DrawingSurfaceShift(
    			ds,
    			cast(int)padding_left,
    			cast(int)padding_top
    			);
        }
        
        return ds;
    }
    
    void on_keyboard_internal(
    	string type, // TODO: better type for parameter
    	EventKeyboard* event,
    	int x,
    	int y
    	)
    {
    	// debug writeln("EventKeyboard: ");
    	// debug writeln("  keyState: ", event.keyState);
    	// debug writeln("      type: ", type);
    	// debug writeln("    repeat: ", event.repeat);
    	// debug writeln("    keysym: ", event.keysym);
    	
    	text_view.keyboardInput(type, event);
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
        
        if (getDrawBewelAndBackground())
        {
        	tvt.setDefaultBGColor(getBewelBackgroundColor());
        } else {
        	tvt.setDefaultBGColor(Color(0xc0c0c0));
        }
        
        text_view.setTextSelectionEnabled(getTextSelectable());
        text_view.setReadOnly(!getTextEditable());
        text_view.setCursorEnabled(getCursorEnabled());
        text_view.setViewResizeByContent(getViewResizeByContent());
        text_view.setFixedSoftWrapSizeEnabled(getFixedSoftWrapSizeEnabled());
        text_view.setFixedSoftWrapSize(getFixedSoftWrapSize());
    }
    
    public
    {
    	int padding_left;
    	int padding_top;
    	int padding_right;
    	int padding_bottom;
    	int tv_width;
    	int tv_height;
    }
    
    void recalcPaddings()
    {
    	if (getDrawBewelAndBackground())
    	{
    		padding_left = 2;
    		padding_top = 2;
    		padding_right = 2;
    		padding_bottom = 2;
    	}
    	else
    	{
    		padding_left = 0;
    		padding_top = 0;
    		padding_right = 0;
    		padding_bottom = 0;
    	}
    }
    
    void recalcTVSize()
    {
    	auto w = getWidth();
    	auto h = getHeight();
    	auto p_lr = padding_left + padding_right;
    	auto p_tb = padding_top + padding_bottom;
    	tv_width = w > p_lr ? w - p_lr : 0;
    	tv_height = h > p_tb ? h - p_tb : 0;
    }
    
    
    override void intMousePressRelease(Widget widget, EventForm* event)
    {
    	text_view.click(
    		event.mouseFocusedWidgetX+padding_left,
    		event.mouseFocusedWidgetY+padding_top
    		);
    }
    
    override void intMouseMove(Widget widget, EventForm* event)
    {
    	on_keyboard_internal(
    		"up",
    		event.event.ek,
    		event.mouseFocusedWidgetX+padding_left,
    		event.mouseFocusedWidgetY+padding_top
    		);
    }
    
    
    override void intKeyboardPress(Widget widget, EventForm* event)
    {
    	on_keyboard_internal(
    		"down",
    		event.event.ek,
    		event.mouseFocusedWidgetX+padding_left,
    		event.mouseFocusedWidgetY+padding_top
    		);
    }
    
    override void intTextInput(Widget widget, EventForm* event)
    {
    	assert(event !is null);
    	assert(event.event !is null);
    	assert(event.event.eti !is null);
    	assert(event.event.eti.text !is null);
    	auto x = event.event.eti.text;
    	text_view.textInput(x);
    	redraw();
    }
    
    override void propagatePosAndSizeRecalc()
    {
    	if (!getViewResizeByContent())
    	{
    		recalcTVSize();
    		text_view.setWidth(tv_width);
    		text_view.setHeight(tv_height);
    	}
    	else
    	{
    		text_view.reprocess();
    		setWidth(text_view.getWidth());
    		setHeight(text_view.getHeight());
    	}
    }
}
