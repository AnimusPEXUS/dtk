module dtk.miscs.textrendering;

import std.range.primitives;
import std.stdio;
import std.utf;

import dtk.interfaces.FontMgrI;

import dtk.types.Image;
import dtk.types.Color;
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

enum WrapType
{
    none,
    byChar,
    byWord,
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

    bool defaultFGColorEnabled;
    Color defaultFGColor;
    bool defaultBGColorEnabled;
    Color defaultBGColor;

    bool hasMaxWidth;
    uint maxWidth_px;
    bool hasMaxHeight;
    uint maxHeight_px;

    WrapType wrap_type;

    int linespace_px = -1; // -1 means auto
    int line_height_px=-1;
}

Image renderText(renderTextSettings settings)
{
    if (settings.line_height_px == -1)
    {
        settings.line_height_px = settings.defaultFaceSize / 64;
        settings.line_height_px += 10; // TODO: this is incorrect and needs fixing
    }

    if (settings.linespace_px == -1)
    {
        settings.linespace_px = settings.line_height_px / 3 * 2;
    }

    Image ret = new Image(0,0);

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

    uint current_line = 0;
    uint line_count = 1;

    while (!settings.text.empty())
    {
        auto c = decodeFront(settings.text);

        writeln("rendering char: ", c);

        GlyphRenderResult* grr;

        try
        {
            auto old_w = ret.width;
            grr = face.renderGlyphByChar(c);
            // TODO: probably this resize isn't correct
            ret.resize(ret.width+grr.bitmap.width, settings.line_height_px * line_count);
            ret.putImage(old_w, settings.linespace_px-grr.bitmap_top, grr.bitmap);
        }
        catch(Exception e)
        {
            writeln("error: ", e);
        }
    }

    for (uint y = 0 ; y != ret.height; y++)
    {
        for (uint x = 0 ; x != ret.width; x++)
        {
            auto dot = ret.getDotRef(x,y);
            if (!dot.enabled)
            {
                dot.enabled=true;
                dot.intensivity = 1;
            }
        }
    }

    return ret;
}
