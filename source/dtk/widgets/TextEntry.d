module dtk.widgets.TextEntry;

import std.stdio;
import std.typecons;
import std.exception;
import std.format;

import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.Property;
import dtk.types.Signal;
import dtk.types.Image;
import dtk.types.Color;
import dtk.types.EventMouse;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;
import dtk.interfaces.FontMgrI;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.TextProcessor;

class TextEntry : Widget, ContainerableWidgetI
{
    // Image textImage;

    TextView text_view;

    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
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
        ]
        );
    
    private {
    	SignalConnectionContainer con_cont;
    	SignalConnection textViewConnCon;
    }
    

    this()
    {
        text_view = new TextView();
        text_view.getFontManager = delegate FontMgrI() 
        {
        	auto f = getForm();
        	if (f is null)
        	{
        		throw new Exception("can't get form");
        	}
        	// auto w = (cast(Form)f).getWindow();
        	auto w = f.getWindow();
        	if (w is null)
        	{
        		throw new Exception("can't get window");
        	}
        	auto p = w.getPlatform();
        	if (p is null)
        	{
        		throw new Exception("can't get platform");
        	}
        	auto fm = p.getFontManager();
        	if (fm is null)
        	{
        		throw new Exception("can't get font manager");
        	}
        	return fm;
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
                ]
            )
        {
            mixin(q{
                pragma(msg, "connectTo%1$s_onAfterChanged");
                con_cont.add(connectTo%1$s_onAfterChanged(
                     delegate void (%2$s v1, %2$s v2)
                    {
                    	collectException(
                    		{
                    			auto err = collectException(applySettingsToTextProcessor());
                    			if (err !is null)
                    				debug writeln(err);
                    		}()
                    		);
                    }
                    ));
                }.format(v.sname, v.tname));
        }

        con_cont.add(connectToText_onAfterChanged(&afterTextChanged));
        
        setMouseEvent("button-click", &on_mouse_click_internal);
        
        textViewConnCon = text_view.connectTo_PerformRedraw(
        	&on_textview_redraw_request
        	);

    }
    
    void on_textview_redraw_request(
    	ulong x,
    	ulong y,
    	ulong width,
    	ulong height
    	)     nothrow
    {
    	collectException(
    		{
    			auto err = collectException(
    				{
    					auto ds = getDrawingSurface();
    					
    					auto rendered_image = text_view.getRenderedImage();
    					
    					for (ulong i = x; i != x+width; i++)
    					{
    						for (ulong j = y; j != y+height; j++)
    						{
    							auto dot = rendered_image.getDot(x,y);
    							ds.drawDot(
    								Position2D(
    									// TODO: I don't like this casts
    									cast(int)(x+2), 
    									cast(int)(y+2)
    									), 
    								dot
    								);
    						}
    					}
    					
    					ds.present();
    				}()
    				);
    			if (err !is null)
    				debug writeln(err);
    		}()
    		);
        
    }
    
    void on_mouse_click_internal(
    	EventMouse* event, 
    	ulong mouseWidget_x, 
    	ulong mouseWidget_y
    	)
    {
        debug writeln(
        	"textentry click x:", 
        	mouseWidget_x, 
        	" y:", 
        	mouseWidget_y
        	);

        if (getDrawBewelAndBackground())
        {
            mouseWidget_x += 2;
            mouseWidget_y += 2;
        }

        text_view.click(mouseWidget_x, mouseWidget_y);
        
        return ;
    }

    private void afterTextChanged(dstring old_val, dstring new_val) nothrow
    {
    	collectException(
    		{
    			
    			auto err = collectException({
    					auto x = getText();
    					text_view.setText(x);
    					auto y = text_view.getTextString();
    					debug writefln("
    						afterTextChanged
    						x: %s
    						y: %s
    						==?: %s
    						", x, y, x == y);
    						applySettingsToTextProcessor();
    			}());
    					if (err !is null)
    						debug writeln(err);
    		}()
    		);
    }

    void applySettingsToTextProcessor()
    {
        debug writeln("TextEntry applySettingsToTextProcessor triggered");

        /* text_view.setText(getText()); */ // NOTE: too expansive probably

        auto tvt = text_view.getText();

        tvt.setFaceFamily(getFontFamily());
        tvt.setFaceStyle(getFontStyle());
        tvt.setFaceSize(getFontSize() * 64);
        tvt.setFaceResolution(72);
        tvt.setBold(getFontBold());
        tvt.setItalic(getFontItalic());
        tvt.setLinesLayout(getLayoutLines());
        tvt.setLineCharsLayout(getLayoutChars());

        auto size = getSize();
        text_view.setWidth(size.width);
        debug writeln("text_view.width = ", text_view.getWidth());
        text_view.setHeight(size.height);

        if (getDrawBewelAndBackground())
        {
            text_view.setWidth(text_view.getWidth()-4);
            text_view.setHeight(text_view.getHeight()-4);
        }

        // this not needed anymore, as TextView manually tracks propery changes
        // text_view.redrawRequired = true;
        
        // debug writeln("before text_view.reprocess");
        // text_view.reprocess();
        // debug writeln("after text_view.reprocess");

        // textImage = text_view.genImage();
        //debug writeln("calling text_view.genImage");
        //text_view.genImage();
    }

    mixin mixin_getWidgetAtPosition;

    override void redraw()
    {
        this.redraw_x(this);
    }
}
