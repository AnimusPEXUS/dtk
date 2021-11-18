module dtk.widgets.TextEntry;

import std.stdio;
import std.typecons;
import std.exception;
import std.format;

import observable.signal;

import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.Property;
import dtk.types.Image;
import dtk.types.Color;
import dtk.types.EventMouse;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.TextProcessor;

class TextEntry : Widget, ContainerableWidgetI
{
    Image textImage;

    TextView text_view;

    mixin mixin_widget_set_multiple_properties!(
        cast(PropSetting[])[
            PropSetting("gs", "dstring", "text", "Text"),
            // TODO: use fontconfig instead of this
            PropSetting("gs_w_d", "string", "font_family", "FontFamily", "\"Go\""),
            PropSetting("gs_w_d", "string", "font_style", "FontStyle", "\"Regular\""),
            PropSetting("gs_w_d", "Color", "font_color", "FontColor", q{Color(0)}),
            PropSetting("gs_w_d", "ushort", "font_size", "FontSize", "9"),
            PropSetting("gs_w_d", "bool", "font_italic", "FontItalic", "false"),
            PropSetting("gs_w_d", "bool", "font_bold", "FontBold", "false"),
            PropSetting("gs_w_d", "GenImageFromSubimagesLayout", "layout_lines", "LayoutLines", "GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft"),
            PropSetting("gs_w_d", "GenImageFromSubimagesLayout", "layout_line_chars", "LayoutChars", "GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop"),
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
    }
    

    this()
    {
        text_view = new TextView();

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
                stname("LayoutLines", "GenImageFromSubimagesLayout"),
                stname("LayoutChars", "GenImageFromSubimagesLayout"),
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
                    {collectException(rerenderTextImage());}
                    ));
                }.format(v.sname, v.tname));
        }

        con_cont.add(connectToText_onAfterChanged(&afterTextChanged));
        
        setMouseEvent("button-click", &on_mouse_click_internal);

    }

    void on_mouse_click_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        debug writeln("textentry click x:", mouseWidget_x, " y:", mouseWidget_y);

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
        collectException({
            auto x = getText();
            text_view.setText(x);
            auto y = text_view.getTextString();
            debug writefln("
afterTextChanged
    x: %s
    y: %s
  ==?: %s
", x, y, x == y);
            rerenderTextImage();
        }());
    }

    void rerenderTextImage()
    {
        debug writeln("Label rerenderTextImage triggered");

        /* auto settings = renderTextSettings(); */
        if (text_view.font_mgr is null)
        {
            text_view.font_mgr = {
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
            }();
        }

        /* text_view.setText(getText()); */ // NOTE: too expansive probably

        auto tvt = text_view.getText();

        tvt.faceFamily = getFontFamily();
        tvt.faceStyle = getFontStyle();
        tvt.faceSize = getFontSize() * 64;
        tvt.faceResolution = 72;
        tvt.bold = getFontBold();
        tvt.italic = getFontItalic();
        tvt.lines_layout = getLayoutLines();
        tvt.chars_layout = getLayoutChars();

        auto size = getSize();
        text_view.width = size.width;
        text_view.height = size.height;

        if (getDrawBewelAndBackground())
        {
            text_view.width -= 4;
            text_view.height -= 4;
        }

        text_view.reprocess();
        /* text_view.printInfo(); */

        textImage = text_view.genImage();
    }

    mixin mixin_getWidgetAtPosition;

    override void redraw()
    {
        if (textImage is null)
        {
            rerenderTextImage();
        }

        this.redraw_x(this);
    }
}
