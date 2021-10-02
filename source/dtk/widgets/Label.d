module dtk.widgets.Label;

import std.stdio;
import std.typecons;

import dtk.types.Property;
import dtk.types.Size2D;
import dtk.types.Image;

import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.widgets.Widget;
import dtk.widgets.mixins;

import dtk.miscs.textrendering;

class Label : Widget, ContainerableWidgetI
{
    Image textImage;

    private
    {
        mixin Property_gs!(string, "text");
        mixin Property_gs_w_d!(ushort, "font_size",9);
        mixin Property_gs_w_d!(bool, "font_italic",false);
        mixin Property_gs_w_d!(bool, "font_bold",false);
    }

    mixin Property_forwarding!(string, text, "Text");
    mixin Property_forwarding!(ushort, font_size, "FontSize");
    mixin Property_forwarding!(bool, font_italic, "FontItalic");
    mixin Property_forwarding!(bool, font_bold, "FontBold");

    this()
    {
        connectToText_onAfterChanged(&afterTextChanged);
        connectToFontSize_onAfterChanged(&afterFontSizeChanged);
        connectToFontItalic_onAfterChanged(&afterFontItalicChanged);
        connectToFontBold_onAfterChanged(&afterFontBoldChanged);
        connectToSize_onAfterChanged(&afterSizeChanged);
    }

    private void afterTextChanged(string old_val, string new_val) nothrow
    {
        try {
            rerenderTextImage();
        } catch (Exception e)
        {

        }
    }

    private void afterFontSizeChanged(ushort, ushort) nothrow
    {
        try {
            rerenderTextImage();
        } catch (Exception e)
        {

        }
    }

    private void afterFontItalicChanged(bool, bool) nothrow
    {
        try {
            rerenderTextImage();
        } catch (Exception e)
        {

        }
    }

    private void afterFontBoldChanged(bool, bool) nothrow
    {
        try {
            rerenderTextImage();
        } catch (Exception e)
        {

        }
    }

    private void afterSizeChanged(Size2D, Size2D) nothrow
    {
        try {
            rerenderTextImage();
        } catch (Exception e)
        {

        }
    }

    void rerenderTextImage()
    {
        writeln("Label rerenderTextImage triggered");

        auto settings = renderTextSettings();
        settings.font_mgr = {
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
        settings.text = getText();
        settings.defaultFaceSize = 1500;
        settings.defaultFaceResolution=100;

        auto img = renderText(settings);
        textImage = img;
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
