module dtk.platforms.sdl_desktop.FontMgrLinux;

import std.conv;
import std.stdio;
import std.path;
import std.file;
import std.algorithm;
import std.string;

import bindbc.freetype;

import dtk.interfaces.FontMgrI;
import dtk.interfaces.FaceI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.fontinfo;
import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Image;

class FontMgrLinux : FontMgrI
{
    FT_Library ft_library;

    FaceI[FaceInfo] face_cache;

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

    FaceInfo*[] getFaceInfoList()
    {
        FaceInfo*[] ret;

        auto paths = getFontPaths();
        foreach (v; paths)
        {
            auto files = getFontFileList(v);
            foreach (v2; files)
            {
                auto fi = new FaceInfo;
                fi.on_fs = true;
                fi.on_fs_filename = v2;

                ret ~= fi;
            }
        }
        return ret;
    }

    FaceI loadFace(FaceInfo* face_info)
    {
        auto x = *face_info;
        if (x !in face_cache)
        {
            face_cache[x]=new Face(this, face_info);
        }
        return face_cache[x];
    }
}

class Face : FaceI
{
    private
    {
        FontMgrLinux fnt_mgr;
        FaceInfo* face_info;

        uint charSizeW;
        uint charSizeH;
        uint charResH;
        uint charResV;
    }

    FT_Face face;

    this(FontMgrLinux fnt_mgr, FaceInfo* face_info)
    {
        this.fnt_mgr = fnt_mgr;
        this.face_info = face_info;

        char[] o_fs_fn = cast(char[]) face_info.on_fs_filename;

        auto err = FT_New_Face(fnt_mgr.ft_library, &o_fs_fn[0], 0, &face);
        if (err == FT_Err_Unknown_File_Format)
        {
            throw new Exception("Can't load file as font: ", face_info.on_fs_filename);
        }
        else if (err)
        {
            throw new Exception("Can't load file as font: unknown error");
        }

        err = FT_Select_Charmap(face, FT_ENCODING_UNICODE);
        if (err != 0)
        {
            throw new Exception("FT_Select_Charmap: can't select unicode");
        }

        populateFaceInfo(this.face_info);
    }

    private void populateFaceInfo(FaceInfo* face_info)
    {
        if (face_info.family_name != "")
            return;

        face_info.family_name = fromStringz(this.face.family_name).dup;
        face_info.style_name = fromStringz(this.face.style_name).dup;
        face_info.num_faces=this.face.num_faces;
        face_info.face_index=this.face.face_index;

        face_info.ascender = face.ascender;
        face_info.descender = face.descender;
        face_info.height = face.height;

        face_info.max_advance_width = face.max_advance_width;
        face_info.max_advance_height = face.max_advance_height;

        auto bb = BoundingBox();

        bb.min = Position2D(cast(int)face.bbox.xMin, cast(int)face.bbox.yMin);
        bb.max = Position2D(cast(int)face.bbox.xMax, cast(int)face.bbox.yMax);

        face_info.bounding_box = bb;

        return;
    }

    FaceInfo* getFaceInfo()
    {
        return face_info;
    }

    void setPixelSize(uint width, uint height)
    {
        auto err = FT_Set_Pixel_Sizes(face, width, height);
        if (err != 0)
        {
            throw new Exception("Can't set pixel size");
        }
    }

    void setCharSize(uint width, uint height) // TODO: rename to setGlyphSize ?
    {
        charSizeW = width;
        charSizeH = height;
        auto err = FT_Set_Char_Size(face, charSizeW, charSizeH, charResH, charResV);
        if (err != 0)
        {
            throw new Exception("Can't set char size");
        }
    }

    void setCharResolution(uint horizontal, uint vertical)
    {
        charResH=horizontal;
        charResV=vertical;
        auto err = FT_Set_Char_Size(face, charSizeW, charSizeH, charResH, charResV);
        if (err != 0)
        {
            throw new Exception("Can't set char size");
        }
    }

    GlyphRenderResult* renderGlyphByChar(dchar chr)
    {
        FT_UInt glyph_index;

        glyph_index = FT_Get_Char_Index(face, chr);

        if (glyph_index == 0)
        {
            throw new Exception("FT_Get_Char_Index error");
        }

        auto err = FT_Load_Glyph(face, glyph_index, FT_LOAD_TARGET_NORMAL );
        if (err != 0)
        {
            throw new Exception("FT_Load_Glyph error");
        }

        err = FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);
        if (err != 0)
        {
            throw new Exception("FT_Render_Glyph error");
        }

        /* writeln("pixel mode: ", cast(FT_Pixel_Mode)face.glyph.bitmap.pixel_mode); */

        auto b = face.glyph.bitmap;

        if (b.pixel_mode != FT_PIXEL_MODE_GRAY)
        {
            throw new Exception("pixel mode isn't FT_PIXEL_MODE_GRAY");
        }

        auto ret_i = new Image(b.width, b.rows);

        for (int y = 0; y != b.rows; y++)
        {
            for (int x = 0; x != b.width; x++)
            {
                ubyte c;
                c = b.buffer[y*b.width+x];

                real intens = 0;
                if (c != 0)
                {
                    intens = cast(real) 1 / (cast(real)255 / c);
                    /* writeln("renderGlyphByChar ", x, " ", y, " intens ", intens); */
                }
                auto dot = ImageDot();
                dot.intensivity = intens;
                dot.enabled=true;
                ret_i.setDot(x,y, dot);
            }
        }

        ret_i.printImage();

        auto ret = new GlyphRenderResult();

        ret.bitmap = ret_i;
        ret.bitmap_top = face.glyph.bitmap_top;
        ret.bitmap_left = face.glyph.bitmap_left;

        ret.glyph_info = generateGlyphInfo();

        writeln("                     b_left: ", ret.bitmap_left);
        writeln("                      b_top: ", ret.bitmap_top);
        writeln("                    b_width: ", ret.bitmap.width);
        writeln("                   b_height: ", ret.bitmap.height);
        writeln("              metrics.width: ", ret.glyph_info.metrics.size.width);
        writeln("             metrics.height: ", ret.glyph_info.metrics.size.height);
        writeln("              horiBearing.x: ", ret.glyph_info.metrics.horiBearing.x);
        writeln("              horiBearing.y: ", ret.glyph_info.metrics.horiBearing.y);
        writeln("              vertBearing.x: ", ret.glyph_info.metrics.vertBearing.x);
        writeln("              vertBearing.y: ", ret.glyph_info.metrics.vertBearing.y);

        writeln("              advance.width: ", ret.glyph_info.metrics.advance.width);
        writeln("             advance.height: ", ret.glyph_info.metrics.advance.height);
        writeln("  linear_horizontal_advance: ", ret.glyph_info.linear_horizontal_advance);
        writeln("    linear_vertical_advance: ", ret.glyph_info.linear_vertical_advance);
        writeln("                  advance.x: ", ret.glyph_info.advance.x);
        writeln("                  advance.y: ", ret.glyph_info.advance.y);
        writeln("                  lsb_delta: ", ret.glyph_info.lsb_delta);
        writeln("                  rsb_delta: ", ret.glyph_info.rsb_delta);

        writeln("              face ascender: ", ret.glyph_info.face_info.ascender);
        writeln("             face descender: ", ret.glyph_info.face_info.descender);
        writeln("                     height: ", ret.glyph_info.face_info.height);
        writeln("          max_advance_width: ", ret.glyph_info.face_info.max_advance_width);
        writeln("         max_advance_height: ", ret.glyph_info.face_info.max_advance_height);

        writeln("                   bb min x: ", ret.glyph_info.face_info.bounding_box.min.x);
        writeln("                   bb min y: ", ret.glyph_info.face_info.bounding_box.min.y);
        writeln("                   bb max x: ", ret.glyph_info.face_info.bounding_box.max.x);
        writeln("                   bb max y: ", ret.glyph_info.face_info.bounding_box.max.y);


        return ret;
    }

    private GlyphInfo* generateGlyphInfo()
    {
        auto slot = face.glyph;

        auto ret = new GlyphInfo();
        ret.face_info=this.face_info;
        ret.glyph_index = slot.glyph_index;

        ret.metrics = GlyphMetrics();

        ret.metrics.size = Size2D(
            cast(int)slot.metrics.width,
            cast(int)slot.metrics.height
            );

        ret.metrics.horiBearing = Position2D(
            cast(int)slot.metrics.horiBearingX,
            cast(int)slot.metrics.horiBearingY
            );
        ret.metrics.vertBearing = Position2D(
            cast(int)slot.metrics.vertBearingX,
            cast(int)slot.metrics.vertBearingY
            );

        ret.metrics.advance = Size2D(
            cast(int)slot.metrics.horiAdvance,
            cast(int)slot.metrics.vertAdvance
            );

        ret.linear_horizontal_advance = slot.linearHoriAdvance;
        ret.linear_vertical_advance = slot.linearVertAdvance;

        ret.advance = Position2D(
            cast(int)slot.advance.x,
            cast(int)slot.advance.y
            );

        ret.lsb_delta = cast(int)slot.lsb_delta;
        ret.rsb_delta =  cast(int)slot.rsb_delta;

        return ret;
    }
}
