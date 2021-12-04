module dtk.platforms.sdl_desktop.FontMgrLinux;

import std.conv;
import std.stdio;
import std.path;
import std.file;
import std.algorithm;
import std.string;
import std.typecons;

import bindbc.freetype;
import fontconfig.fontconfig;

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

    FaceI[] face_cache;
    
    FcConfig* ftconfig;


    this()
    {
        auto err = FT_Init_FreeType(&ft_library);
        if (err)
        {
            throw new Exception("FreeType library init error");
        }
                   
        ftconfig = FcInitLoadConfigAndFonts();
        if (ftconfig is null)
        	throw new Exception("couldn't load fontconfig");

    }

    ~this()
    {
        /* FT_Done_Library(ft_library); */
        /* ft_library = null; */
        FcConfigDestroy(ftconfig);
    	ftconfig = null; // segfaults without this
    	FcFini();
    }


    FaceInfo*[] getFaceInfoList()
    {
        FaceInfo*[] ret;


        return ret;
    }

    FaceI loadFace(FaceInfo* face_info)
    {
        foreach (v; face_cache)
        {
            auto i = v.getFaceInfo();
            if (
            	i.on_fs == face_info.on_fs && 
	            i.on_fs_filename == face_info.on_fs_filename && 
	            i.face_index == face_info.face_index
	            ) {
            return v;
            }
        }
        auto ret = new Face(this, face_info);
        face_cache ~= ret;
        return ret;
    }
    
    FaceI loadFace(string filename, ulong index)
    {
        auto x = new FaceInfo;
        x.on_fs = true;
        x.on_fs_filename = filename;
        x.face_index = index;
        return loadFace(x);
    }
    
    FaceI loadFace(string faceFamily, string faceStyle)
    {
    	auto res = findFaceFileAndIndex(faceFamily, faceStyle);
    	if (res[0] is false)
    		return null;
    	return loadFace(res[1], res[2]);
    }
    
    Tuple!(bool, string, ulong) findFaceFileAndIndex(string faceFamily, string faceStyle)
    {
    	import fontconfig.fontconfig;
    	
    	auto failureResult = tuple(false, "", 0UL);

		FcPattern* pat =  FcPatternCreate();
		scope (exit) FcPatternDestroy(pat);
		
		FcPatternAddString(pat, FC_FAMILY.toStringz, faceFamily.toStringz);
		FcPatternAddString(pat, FC_STYLE.toStringz, faceStyle.toStringz);
		
		FcConfigSubstitute(ftconfig, pat, FcMatchKind.FcMatchPattern);
		FcDefaultSubstitute(pat);
		
		FcResult res;
		FcPattern* font = FcFontMatch(ftconfig, pat, &res);
		if (font is null)
		{
			return failureResult;
		}
		
		scope(exit) FcPatternDestroy(font);
		
		FcChar8* file = null;
		string file_d;
		if (FcPatternGetString(font, FC_FILE.toStringz, 0, &file) == FcResult.FcResultMatch)
		{
			file_d = to!string(fromStringz(file));
		}
		
		int index_d;
		FcPatternGetInteger(font, FC_INDEX.toStringz, 0, &index_d);
	
		return tuple(true, file_d, cast(ulong)index_d);		
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

        auto err = FT_New_Face(fnt_mgr.ft_library, &o_fs_fn[0], face_info.face_index, &face);
        if (err != 0)
        {
            throw new Exception("Can't load file (%s) as font: error code: %s".format(o_fs_fn, err));
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
        face_info.family_name = fromStringz(face.family_name).dup;
        face_info.style_name = fromStringz(face.style_name).dup;
        face_info.num_faces = face.num_faces;
        face_info.face_index = face.face_index;

        face_info.ascender = face.ascender;
        face_info.descender = face.descender;
        face_info.height = face.height;

        face_info.max_advance_width = face.max_advance_width;
        face_info.max_advance_height = face.max_advance_height;

        face_info.bounding_box = BoundingBox();

        face_info.bounding_box.min = Position2D(cast(int) face.bbox.xMin, cast(int) face.bbox.yMin);
        face_info.bounding_box.max = Position2D(cast(int) face.bbox.xMax, cast(int) face.bbox.yMax);

        face_info.size = FaceSizeMetrics();

        face_info.size.x_PPEM = face.size.metrics.x_ppem;
        face_info.size.y_PPEM = face.size.metrics.y_ppem;

        face_info.size.x_scale = cast(int) face.size.metrics.x_scale;
        face_info.size.y_scale = cast(int) face.size.metrics.y_scale;

        face_info.size.ascender = cast(int) face.size.metrics.ascender;
        face_info.size.descender = cast(int) face.size.metrics.descender;
        face_info.size.height = cast(int) face.size.metrics.height;

        face_info.size.max_advance = cast(int) face.size.metrics.max_advance;

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
        populateFaceInfo(this.face_info);
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
        populateFaceInfo(this.face_info);
    }

    void setCharResolution(uint horizontal, uint vertical)
    {
        charResH = horizontal;
        charResV = vertical;
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

        auto err = FT_Load_Glyph(face, glyph_index, FT_LOAD_TARGET_NORMAL);
        if (err != 0)
        {
            throw new Exception("FT_Load_Glyph error");
        }

        err = FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);
        if (err != 0)
        {
            throw new Exception("FT_Render_Glyph error");
        }

        auto b = face.glyph.bitmap;

        if (b.pixel_mode != FT_PIXEL_MODE_GRAY)
        {
            throw new Exception("pixel mode isn't FT_PIXEL_MODE_GRAY");
        }

        auto ret_i = new Image(b.width, b.rows);
        /* auto ret_i = new Image(b.width, face_info.height / 64); */

        for (int y = 0; y != b.rows; y++)
        {
            for (int x = 0; x != b.width; x++)
            {
                ubyte c;
                c = b.buffer[y * b.width + x];

                real intens = 0;
                if (c != 0)
                {
                    intens = cast(real) 1 / (cast(real) 255 / c);
                }
                auto dot = ImageDot();
                dot.intensivity = intens;
                dot.enabled = true;
                ret_i.setDot(x, y, dot);
            }
        }

        auto ret = new GlyphRenderResult();

        ret.bitmap = ret_i;
        ret.bitmap_left = face.glyph.bitmap_left;
        ret.bitmap_top = face.glyph.bitmap_top;

        ret.glyph_info = generateGlyphInfo();

        // debug {
        // writeln("                     b_left: ", ret.bitmap_left);
        // writeln("                      b_top: ", ret.bitmap_top);
        // writeln("                    b_width: ", ret.bitmap.width);
        // writeln("                   b_height: ", ret.bitmap.height);
// 
        // writeln("         metrics.size.width: ", ret.glyph_info.metrics.size.width);
        // writeln("        metrics.size.height: ", ret.glyph_info.metrics.size.height);
        // writeln("      metrics.horiBearing.x: ", ret.glyph_info.metrics.horiBearing.x);
        // writeln("      metrics.horiBearing.y: ", ret.glyph_info.metrics.horiBearing.y);
        // writeln("      metrics.vertBearing.x: ", ret.glyph_info.metrics.vertBearing.x);
        // writeln("      metrics.vertBearing.y: ", ret.glyph_info.metrics.vertBearing.y);
        // writeln("      metrics.advance.width: ", ret.glyph_info.metrics.advance.width);
        // writeln("     metrics.advance.height: ", ret.glyph_info.metrics.advance.height);
// 
        // writeln("  linear_horizontal_advance: ", ret.glyph_info.linear_horizontal_advance);
        // writeln("    linear_vertical_advance: ", ret.glyph_info.linear_vertical_advance);
        // writeln("                  advance.x: ", ret.glyph_info.advance.x);
        // writeln("                  advance.y: ", ret.glyph_info.advance.y);
        // writeln("                  lsb_delta: ", ret.glyph_info.lsb_delta);
        // writeln("                  rsb_delta: ", ret.glyph_info.rsb_delta);
// 
        // writeln("              face ascender: ", ret.glyph_info.face_info.ascender);
        // writeln("             face descender: ", ret.glyph_info.face_info.descender);
        // writeln("                     height: ", ret.glyph_info.face_info.height);
        // writeln("          max_advance_width: ", ret.glyph_info.face_info.max_advance_width);
        // writeln("         max_advance_height: ", ret.glyph_info.face_info.max_advance_height);
// 
        // writeln("         bounding_box min x: ", ret.glyph_info.face_info.bounding_box.min.x);
        // writeln("         bounding_box min y: ", ret.glyph_info.face_info.bounding_box.min.y);
        // writeln("         bounding_box max x: ", ret.glyph_info.face_info.bounding_box.max.x);
        // writeln("         bounding_box max y: ", ret.glyph_info.face_info.bounding_box.max.y);
// 
        // writeln("                size.x_PPEM: ", ret.glyph_info.face_info.size.x_PPEM);
        // writeln("                size.y_PPEM: ", ret.glyph_info.face_info.size.y_PPEM);
// 
        // writeln("               size.x_scale: ", ret.glyph_info.face_info.size.x_scale);
        // writeln("               size.y_scale: ", ret.glyph_info.face_info.size.y_scale);
// 
        // writeln("              size.ascender: ", ret.glyph_info.face_info.size.ascender);
        // writeln("             size.descender: ", ret.glyph_info.face_info.size.descender);
        // writeln("                size.height: ", ret.glyph_info.face_info.size.height);
// 
        // writeln("           size.max_advance: ", ret.glyph_info.face_info.size.max_advance);
        // }

        return ret;
    }

    private GlyphInfo* generateGlyphInfo()
    {
        auto slot = face.glyph;

        auto ret = new GlyphInfo();
        ret.face_info = this.face_info;
        ret.glyph_index = slot.glyph_index;

        ret.metrics = GlyphMetrics();

        ret.metrics.size = Size2D(cast(int) slot.metrics.width, cast(int) slot.metrics.height);

        ret.metrics.horiBearing = Position2D(cast(int) slot.metrics.horiBearingX,
                cast(int) slot.metrics.horiBearingY);
        ret.metrics.vertBearing = Position2D(cast(int) slot.metrics.vertBearingX,
                cast(int) slot.metrics.vertBearingY);

        ret.metrics.advance = Size2D(cast(int) slot.metrics.horiAdvance,
                cast(int) slot.metrics.vertAdvance);

        ret.linear_horizontal_advance = slot.linearHoriAdvance;
        ret.linear_vertical_advance = slot.linearVertAdvance;

        ret.advance = Position2D(cast(int) slot.advance.x, cast(int) slot.advance.y);

        ret.lsb_delta = cast(int) slot.lsb_delta;
        ret.rsb_delta = cast(int) slot.rsb_delta;

        return ret;
    }
    

}
