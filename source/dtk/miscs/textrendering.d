module dtk.miscs.textrendering;

import std.range.primitives;
import std.stdio;
import std.utf;

import dtk.interfaces.FontMgrI;

import dtk.types.Image;

enum RenderTextType
{
    plain,

    /* xhtml, // TODO: todo
    markup,
    bb, */
}

enum OnRenderOverflow
{
    stop,
    resizeImage,
}

enum RenderTextJustification
{
    start, // is 'left' for cyrilic, latin etc. if 'right' for hebrew, japanese etc
    middle,
    end,
}

struct renderTextSettings
{
    FontMgrI font_mgr;

    string text;
    RenderTextType type;
    string defaultFontFamily;
    ushort defaultFontSize;
    ushort defaultFontResolution;
    bool defaultBold;
    bool defaultItalic;
    bool defaultUnderline;

    bool hasMaxWidth;
    uint maxWidth;
    bool hasMaxHeight;
    uint maxHeight;

    bool wordWrap;

    uint initialImageWidth;
    uint initialImageHeight;
}

Image renderText(renderTextSettings settings)
{
    Image ret;

    auto font = settings.font_mgr.loadFont("/usr/share/fonts/go/Go-Regular.ttf");

    font.setPixelSize(1,1);
    {
        auto x = settings.defaultFontSize * 10;
        font.setCharSize(x,x);
    }
    {
        auto x = settings.defaultFontResolution * 10;
        font.setCharResolution(x,x);
    }

    while (!settings.text.empty())
    {
        auto c = decodeFront(settings.text);

        writeln("rendering char: ", c);

        try
        {
        if (ret is null)
        {
            ret = font.drawChar(c);
        }
        else
        {
            Image new_img = font.drawChar(c);

            uint old_w = ret.width;
            uint old_h = ret.height;

            uint new_w = ret.width + new_img.width;
            uint new_h = (ret.height > new_img.height ? ret.height : new_img.height);
            ret.resize(new_w, new_h);
            /* ret.printImage(); */
            ret.putImage(old_w, 0, new_img);
            /* ret.printImage(); */
        }
        } catch (Exception e)
        {
            writeln("error:", e);
        }
    }

    return ret;
}
