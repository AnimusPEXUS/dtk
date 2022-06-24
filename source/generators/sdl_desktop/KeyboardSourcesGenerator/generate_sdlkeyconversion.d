#!/usr/bin/env rdmd

import std.typecons;
import std.stdio;
import std.file;
import std.csv;
import std.format;

import generate_templates;

int main()
{
    string cwd = getcwd();

    string keyinfo_csv;

    auto fout = File(cwd ~ "/sdlkeyconversion.d", "wb");
    scope (success)
        fout.close();

    {
        auto f = File(cwd ~ "/KeyInfo.csv");
        /* scope(exit) f.close(); */
        ubyte[] b;
        b.length = f.size;
        keyinfo_csv = cast(string) f.rawRead(b).idup;
    }

    fout.rawWrite("module dtk.platforms.sdl_desktop.sdlkeyconversion;\n\n");

    fout.rawWrite(HEADER_TEXT);

    fout.rawWrite("
import std.typecons;
import std.format;

import bindbc.sdl;

import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;


");

    fout.rawWrite("\n");

    // ------------------ Key Codes ------------------

    {
        fout.rawWrite(
                "Tuple!(EnumKeyboardKeyCode, Exception) convertSDLKeycodeToEnumKeyboardKeyCode(SDL_Keycode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite(
                "            return tuple(cast(EnumKeyboardKeyCode)0, new Exception(\"could not decode supplied keycode: \" ~ format(\"%s\", code)));\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop: foreach (row; reader)
        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_BUTTONS])
            {
            default:
                break;
            case "":
                continue main_loop;
            case ".":
                break main_loop;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite("        case SDL_Keycode." ~ row[TableColumns.COLUMN_SDL_KEYCODE] ~ ":\n");
            fout.rawWrite("            return tuple(EnumKeyboardKeyCode."
                    ~ row[TableColumns.COLUMN_BUTTONS] ~ ", cast(Exception)null);\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    {
        fout.rawWrite(
                "Tuple!(SDL_Keycode, Exception) convertEnumKeyboardKeyCodeToSDLKeycode(EnumKeyboardKeyCode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite(
                "            return tuple(cast(SDL_Keycode)0, new Exception(\"could not decode supplied keycode: \" ~ format(\"%s\", code)));\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop2: foreach (row; reader)
        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_BUTTONS])
            {
            default:
                break;
            case "":
                continue main_loop2;
            case ".":
                break main_loop2;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite(
                    "        case EnumKeyboardKeyCode." ~ row[TableColumns.COLUMN_BUTTONS] ~ ":\n");
            fout.rawWrite("            return tuple(SDL_Keycode."
                    ~ row[TableColumns.COLUMN_SDL_KEYCODE] ~ ", cast(Exception) null);\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    // ------------------ Mod Codes ------------------ Single

    {
        fout.rawWrite(
                "Tuple!(EnumKeyboardModCode, Exception) convertSingleSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite(
                "            return tuple(cast(EnumKeyboardModCode)0, new Exception(\"could not decode supplied keycode: \"~ format(\"%s\", code)) );\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop3: foreach (row; reader)
        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_BUTTONS])
            {
            default:
                break;
            case "":
                continue main_loop3;
            case ".":
                break main_loop3;
            }

            if (row[TableColumns.COLUMN_SDL_KEYMOD] == "")
            {
                continue;
            }

            fout.rawWrite("        case SDL_Keymod." ~ row[TableColumns.COLUMN_SDL_KEYMOD] ~ ":\n");
            fout.rawWrite("            return tuple(EnumKeyboardModCode."
                    ~ row[TableColumns.COLUMN_BUTTONS] ~ ", cast(Exception)null);\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    {
        fout.rawWrite(
                "Tuple!(SDL_Keymod, Exception) convertSingleEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite(
                "            return tuple(cast(SDL_Keymod)0, new Exception(\"could not decode supplied keycode: \"~ format(\"%s\", code)) );\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop4: foreach (row; reader)
        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_SDL_KEYMOD])
            {
            default:
                break;
            case "":
                continue main_loop4;
            case ".":
                break main_loop4;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite(
                    "        case EnumKeyboardModCode." ~ row[TableColumns.COLUMN_BUTTONS] ~ ":\n");
            fout.rawWrite(
                    "            return tuple(SDL_Keymod."
                    ~ row[TableColumns.COLUMN_SDL_KEYMOD] ~ ",cast(Exception)null);\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    // ------------------ Mod Codes ------------------ Combination

    {
        fout.rawWrite("Tuple!(EnumKeyboardModCode, Exception) convertCombinationSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)\n{\n");

        fout.rawWrite("    EnumKeyboardModCode ret;\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop5: foreach (row; reader)

        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_BUTTONS])
            {
            default:
                break;
            case "":
                continue main_loop5;
            case ".":
                break main_loop5;
            }

            if (row[TableColumns.COLUMN_SDL_KEYMOD] == "")
            {
                continue;
            }

            fout.rawWrite(format("if ((code & SDL_Keymod.%s) != 0)\n",
                    row[TableColumns.COLUMN_SDL_KEYMOD]));
            fout.rawWrite("{\n");
            fout.rawWrite(format("    ret |= EnumKeyboardModCode.%s;\n",
                    row[TableColumns.COLUMN_BUTTONS]));
            fout.rawWrite("}\n");

        }

        fout.rawWrite("   return tuple(ret, cast(Exception) null);\n");

        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    {
        fout.rawWrite("Tuple!(SDL_Keymod, Exception) convertCombinationEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)\n{\n");

        fout.rawWrite("    SDL_Keymod ret;\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop6: foreach (row; reader)
        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_SDL_KEYMOD])
            {
            default:
                break;
            case "":
                continue main_loop6;
            case ".":
                break main_loop6;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite(format("if ((code & EnumKeyboardModCode.%s) != 0)\n",
                    row[TableColumns.COLUMN_BUTTONS]));
            fout.rawWrite("{\n");
            fout.rawWrite(format("    ret |= SDL_Keymod.%s;\n",
                    row[TableColumns.COLUMN_SDL_KEYMOD]));
            fout.rawWrite("}\n");
        }

        fout.rawWrite("   return tuple(ret, cast(Exception)null);\n");

        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    scope (failure)
    {
        return 1;
    }

    return 0;
}