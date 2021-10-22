module dtk.widgets.Label;

import std.stdio;
import std.typecons;
import std.conv;

import dtk.types.Property;
import dtk.types.Size2D;
import dtk.types.Image;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

/* import dtk.miscs.textrendering; */
import dtk.miscs.TextProcessor;

class Label : Widget, ContainerableWidgetI
{
    Image textImage;

    TextView text_view;

    private
    {
        mixin Property_gs!(dstring, "text");
        mixin Property_gs_w_d!(ushort, "font_size", 9);
        mixin Property_gs_w_d!(bool, "font_italic", false);
        mixin Property_gs_w_d!(bool, "font_bold", false);
    }

    mixin Property_forwarding!(dstring, text, "Text");
    mixin Property_forwarding!(ushort, font_size, "FontSize");
    mixin Property_forwarding!(bool, font_italic, "FontItalic");
    mixin Property_forwarding!(bool, font_bold, "FontBold");

    this()
    {
        text_view = new TextView();

        connectToText_onAfterChanged(&afterTextChanged);
        connectToFontSize_onAfterChanged(&afterFontSizeChanged);
        connectToFontItalic_onAfterChanged(&afterFontItalicChanged);
        connectToFontBold_onAfterChanged(&afterFontBoldChanged);
        connectToSize_onAfterChanged(&afterSizeChanged);
    }

    private void afterTextChanged(dstring old_val, dstring new_val) nothrow
    {
        try
        {
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
        }
        catch (Exception e)
        {

        }
    }

    private void afterFontSizeChanged(ushort, ushort) nothrow
    {
        try
        {
            writeln("afterFontSizeChanged is called");
            text_view.getText().faceSize = getFontSize() * 64;
            rerenderTextImage();
        }
        catch (Exception e)
        {

        }
    }

    private void afterFontItalicChanged(bool, bool) nothrow
    {
        try
        {
            writeln("afterFontItalicChanged is called");
            text_view.getText().italic = getFontItalic();
            rerenderTextImage();
        }
        catch (Exception e)
        {

        }
    }

    private void afterFontBoldChanged(bool, bool) nothrow
    {
        try
        {
            writeln("afterFontBoldChanged is called");
            text_view.getText().bold = getFontBold();
            rerenderTextImage();
        }
        catch (Exception e)
        {

        }
    }

    private void afterSizeChanged(Size2D, Size2D) nothrow
    {
        try
        {
            writeln("afterSizeChanged is called");
            rerenderTextImage();
        }
        catch (Exception e)
        {

        }
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
        /* textProcessor.defaultFaceSize = getFontSize()*64; */
        text_view.getText().faceResolution = 72;

        text_view.reprocess();

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
