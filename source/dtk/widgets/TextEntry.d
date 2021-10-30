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

    private
    {
        mixin Property_gs!(dstring, "text");
        mixin Property_gs_w_d!(string, "font_file", ""); // TODO: use fontconfig instead of this
        mixin Property_gs_w_d!(string, "font_face", "Go Regular");
        mixin Property_gs_w_d!(ushort, "font_size", 9);
        mixin Property_gs_w_d!(bool, "font_italic", false);
        mixin Property_gs_w_d!(bool, "font_bold", false);
        mixin Property_gs_w_d!(
            GenImageFromSubimagesLayout,
            "layout_lines",
            GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft
            );
        mixin Property_gs_w_d!(
            GenImageFromSubimagesLayout,
            "layout_line_chars",
            GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop
            );
        mixin Property_gs_w_d!(bool, "draw_bewel_and_background", false);
        mixin Property_gs_w_d!(Color, "bewel_background_color", Color(cast(ubyte[3])[255,255,255]));
        mixin Property_gs_w_d!(bool, "multiline", false);
        mixin Property_gs_w_d!(bool, "virtual_wrap_by_char", false);
        mixin Property_gs_w_d!(bool, "virtual_wrap_by_word", false);
        mixin Property_gs_w_d!(bool, "enforce_mono_width", false);
        mixin Property_gs_w_d!(bool, "text_selectable", false);
        mixin Property_gs_w_d!(bool, "text_editable", false);
    }

    mixin Property_forwarding!(dstring, text, "Text");
    mixin Property_forwarding!(string, font_file, "FontFile");
    mixin Property_forwarding!(string, font_face, "FontFace");
    mixin Property_forwarding!(ushort, font_size, "FontSize");
    mixin Property_forwarding!(bool, font_italic, "FontItalic");
    mixin Property_forwarding!(bool, font_bold, "FontBold");
    mixin Property_forwarding!(GenImageFromSubimagesLayout, layout_lines, "LayoutLines");
    mixin Property_forwarding!(GenImageFromSubimagesLayout, layout_line_chars, "LayoutChars");

    mixin Property_forwarding!(bool, draw_bewel_and_background, "DrawBewelAndBackground");
    mixin Property_forwarding!(Color, bewel_background_color, "BewelBackgroundColor");
    mixin Property_forwarding!(bool, multiline, "Multiline");
    mixin Property_forwarding!(bool, virtual_wrap_by_char, "VirtualWrapByChar");
    mixin Property_forwarding!(bool, virtual_wrap_by_word, "VirtualWrapByWord");
    mixin Property_forwarding!(bool, enforce_mono_width, "EnforceMonowidth");
    mixin Property_forwarding!(bool, text_selectable, "TextSelectable");
    mixin Property_forwarding!(bool, text_editable, "TextEditable");

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
                stname("FontFile", "string"),
                stname("FontFace", "string"),
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
                stname("EnforceMonowidth", "bool"),
                stname("TextSelectable", "bool"),
                stname("TextEditable", "bool"),
                ]
            )
        {
            mixin(q{
                pragma(msg, "connectTo%1$s_onAfterChanged");
                connectTo%1$s_onAfterChanged(
                     delegate void (%2$s v1, %2$s v2)
                    {collectException(rerenderTextImage());}
                    );
                }.format(v.sname, v.tname));
        }

        connectToText_onAfterChanged(&afterTextChanged);

        /* connectToFontFile_onAfterChanged(
            delegate void(string, string)
            {collectException(rerenderTextImage())}
            );
        connectToFontFace_onAfterChanged(
            delegate void(string, string)
            {collectException(rerenderTextImage())}
            );
        connectToFontSize_onAfterChanged(
            delegate void(ushort, ushort)
            {collectException(rerenderTextImage())}
            );
        connectToFontItalic_onAfterChanged(
            delegate void(bool, bool)
            {collectException(rerenderTextImage())}
            );
        connectToFontBold_onAfterChanged(
            delegate void(bool, bool)
            {collectException(rerenderTextImage())}
            );



        connectToLayoutLines_onAfterChanged(
            delegate void(GenImageFromSubimagesLayout, GenImageFromSubimagesLayout)
            {collectException(rerenderTextImage())}
            );
        connectToLayoutChars_onAfterChanged(
            delegate void(GenImageFromSubimagesLayout, GenImageFromSubimagesLayout)
            {collectException(rerenderTextImage())}
            );
        connectToDrawBewelAndBackground_onAfterChanged(
            delegate void(bool, bool)
            {collectException(rerenderTextImage())}
            );
        connectToBewelBackgroundColor_onAfterChanged(
            delegate void(Color, Color)
            {collectException(rerenderTextImage())}
            );
        connectToMultiline_onAfterChanged(
            delegate void(bool, bool)
            {collectException(rerenderTextImage())}
            );
        connectToFontBold_onAfterChanged(
            delegate void(bool, bool)
            {collectException(rerenderTextImage())}
            );




        connectToSize_onAfterChanged(
            delegate void(Size2D, Size2D)
            {collectException(rerenderTextImage())}
            ); */
    }

    private void afterTextChanged(dstring old_val, dstring new_val) nothrow
    {
        collectException({
            auto x = getText();
            text_view.setText(x);
            auto y = text_view.getTextString();
            writefln("
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
        writeln("Label rerenderTextImage triggered");

        /* auto settings = renderTextSettings(); */
        if (text_view.font_mgr is null)
        {
            text_view.font_mgr = {
                auto f = getForm();
                if (f is null)
                {
                    throw new Exception("can't get form");
                }
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

        tvt.faceSize = getFontSize() * 64;
        tvt.faceResolution = 72;
        tvt.bold = getFontBold();
        tvt.italic = getFontItalic();
        tvt.lines_layout = getLayoutLines();
        tvt.chars_layout = getLayoutChars();

        auto size = getSize();
        text_view.width = size.width;
        text_view.height = size.height;

        text_view.reprocess();
        text_view.printInfo();

        textImage = text_view.genImage();
    }

    override void redraw()
    {
        if (textImage is null)
        {
            rerenderTextImage();
        }

        this.redraw_x(this);
    }
}
