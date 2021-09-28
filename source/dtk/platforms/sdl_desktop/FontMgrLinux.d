module dtk.platforms.sdl_desktop.FontMgrLinux;

import std.stdio;
import std.path;
import std.file;
import std.algorithm;
import std.string;

import bindbc.freetype;

import dtk.interfaces.FontMgrI;
import dtk.interfaces.FontI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.FontInfo;

class FontMgrLinux : FontMgrI
{
    FT_Library ft_library;

    this()
    {
        auto err = FT_Init_FreeType(&ft_library);
        if (err)
        {
            throw new Exception("FreeType library init error");
        }
    }

    string[] getFontPaths()
    {
        string[] ret;

        auto entries = dirEntries("/usr/share/fonts", SpanMode.shallow);
        foreach (e; entries)
        {
            if (e.isDir())
            {
                ret ~= "/usr/share/fonts" ~ "/" ~ baseName(e.name());
            }
        }

        return ret;
    }

    string[] getFontFileList(string pth)
    {
        string[] ret;

        auto entries = dirEntries(pth, SpanMode.shallow);
        foreach (e; entries)
        {
            if (e.isFile())
            {
                if ((e.name()).toLower().endsWith(".ttf"))
                {
                    ret ~= pth ~ "/" ~ baseName(e.name());
                }
            }
        }

        return ret;
    }

    FontInfo*[] getFontInfoList()
    {
        FontInfo*[] ret;

        auto paths = getFontPaths();
        foreach (v; paths)
        {
            auto files = getFontFileList(v);
            foreach (v2; files)
            {
                auto fi = new FontInfo;
                fi.on_fs = true;
                fi.on_fs_filename = v2;

                ret ~= fi;
            }
        }
        return ret;
    }

    FontI loadFont(FontInfo* font_info)
    {
        return new Font(this, font_info);
    }
}

class Font : FontI
{
    private
    {
        FontMgrLinux fnt_mgr;
        FontInfo* font_info;
    }

    FT_Face face;

    this(FontMgrLinux fnt_mgr, FontInfo* font_info)
    {
        this.fnt_mgr = fnt_mgr;
        this.font_info = font_info;

        char[] o_fs_fn = cast(char[]) font_info.on_fs_filename;

        auto err = FT_New_Face(fnt_mgr.ft_library, &o_fs_fn[0], 0, &face);
        if (err == FT_Err_Unknown_File_Format)
        {
            throw new Exception("Can't load file as font: ", font_info.on_fs_filename);
        }
        else if (err)
        {
            throw new Exception("Can't load file as font: unknown error");
        }
    }

    FontInfo* getFontInfo()
    {
        return font_info;
    }

    void drawChar(char chr, DrawingSurfaceI ds)
    {
        FT_GlyphSlot slot = face.glyph; /* a small shortcut */

        /* ... initialize library ...
           ... create face object ...
           ... set character size ... */

        FT_UInt glyph_index;

        /* retrieve glyph index from character code */
        auto error = FT_Select_Charmap(face, FT_ENCODING_UNICODE);
        if (error != 0)
        {
            writeln("error: FT_Select_Charmap: no unicode");
            return;
        }

        glyph_index = FT_Get_Char_Index(face, cast(ulong) chr);
        /* glyph_index=100; */
        if (glyph_index == 0)
        {
            writeln("error: FT_Get_Char_Index: glyph_index == ", glyph_index);
            return;
        }

        /* load glyph image into the slot (erase previous one) */
        error = FT_Load_Glyph(face, glyph_index, FT_LOAD_DEFAULT);
        if (error)
        {
            writeln("error: FT_Load_Glyph: ", error);
            return; /* ignore errors */
        }

        /* convert to an anti-aliased bitmap */
        error = FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);
        if (error)
        {
            writeln("error: FT_Render_Glyph: ", error);
            return;
        }

        /* now, draw to our target surface */
        /* my_draw_bitmap(&slot.bitmap, pen_x + slot.bitmap_left, pen_y - slot.bitmap_top); */
        writeln("pixel mode: ", slot.bitmap.pixel_mode);

        /* increment pen position */
        /* pen_x += slot.advance.x >> 6;
            pen_y += slot.advance.y >> 6; /* not useful for now * / */

    }
}
