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

        // TODO: complete face_info population

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

        writeln(" b_left: ", face.glyph.bitmap_left);
        writeln("  b_top: ", face.glyph.bitmap_top);
        writeln("  pitch: ", b.pitch);
        writeln("   rows: ", b.rows);
        writeln("  width: ", b.width);
        writeln("  pitch: ", b.pitch);

        auto ret_i = new Image(b.width, b.rows);

        for (int y = 0; y != b.rows; y++)
        {
            for (int x = 0; x != b.width; x++)
            {
                ubyte c;
                c = b.buffer[y*b.width+x];
                auto color = Color(cast(ubyte[])[c,c,c]);
                ret_i.setDot(x,y, ImageDot(color));
            }
        }

        ret_i.printImage();

        auto ret = new GlyphRenderResult();

        ret.bitmap = ret_i;
        ret.bitmap_top = face.glyph.bitmap_top;
        ret.bitmap_left = face.glyph.bitmap_left;

        ret.glyph_info = generateGlyphInfo();

        return ret;
    }

    private GlyphInfo* generateGlyphInfo()
    {
        auto ret = new GlyphInfo();
        return ret;
    }
}
