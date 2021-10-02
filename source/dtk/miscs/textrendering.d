module dtk.miscs.textrendering;

import std.range.primitives;
import std.stdio;
import std.utf;

import dtk.interfaces.FontMgrI;

import dtk.types.Image;
import dtk.types.fontinfo;


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
    string defaultFaceFamily;
    ushort defaultFaceSize;
    ushort defaultFaceResolution;
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

    auto face = settings.font_mgr.loadFace("/usr/share/fonts/go/Go-Regular.ttf");

    /* font.setPixelSize(1,1); */
    {
        auto x = settings.defaultFaceSize;
        face.setCharSize(x,x);
    }
    {
        auto x = settings.defaultFaceResolution;
        face.setCharResolution(x,x);
    }

    while (!settings.text.empty())
    {
        auto c = decodeFront(settings.text);

        writeln("rendering char: ", c);

        GlyphRenderResult* grr;

        try
        {
        if (ret is null)
        {
            grr = face.renderGlyphByChar(c);
        }
        else
        {
            grr = face.renderGlyphByChar(c);

            uint old_w = ret.width;
            uint old_h = ret.height;

            uint new_w = ret.width + grr.bitmap.width;
            uint new_h = (ret.height > grr.bitmap.height ? ret.height : grr.bitmap.height);
            ret.resize(new_w, new_h);
            /* ret.printImage(); */
            ret.putImage(old_w, 0, grr.bitmap);
            /* ret.printImage(); */
        }
        } catch (Exception e)
        {
            writeln("error:", e);
        }
    }

    return ret;
}
