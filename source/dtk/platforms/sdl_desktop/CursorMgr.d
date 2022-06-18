module dtk.platforms.sdl_desktop.CursorMgr;

import std.stdio;
import std.format;

import bindbc.sdl;

import dtk.interfaces.MouseCursorMgrI;

import dtk.types.EnumMouseCursor;

class CursorMgr : MouseCursorMgrI
{
    void setCursorByType(EnumMouseCursor type)
    {
        SDL_SystemCursor sdl_csr_id = SDL_SYSTEM_CURSOR_ARROW;
        with (EnumMouseCursor)
        {
            switch (type)
            {
                default:
                    // TODO: indicate error to program
                    debug writeln("cursor not supported: %s".format(type));
                    return;
                case crDefault:
                    sdl_csr_id = SDL_SYSTEM_CURSOR_ARROW;
                    break;
                /* case crText:
                    break; */
                case crWait:
                    sdl_csr_id = SDL_SYSTEM_CURSOR_WAIT;
                    break;

                case crWResize:
                case crEResize:
                    sdl_csr_id = SDL_SYSTEM_CURSOR_SIZEWE;
                    break;

                case crNWResize:
                case crSEResize:
                    sdl_csr_id = SDL_SYSTEM_CURSOR_SIZENWSE;
                    break;

                case crNEResize:
                case crSWResize:
                    sdl_csr_id = SDL_SYSTEM_CURSOR_SIZENESW;
                    break;

                case crNResize:
                case crSResize:
                    sdl_csr_id = SDL_SYSTEM_CURSOR_SIZENS;
                    break;
            }
        }
        SDL_Cursor *csr = SDL_CreateSystemCursor(sdl_csr_id);
        SDL_SetCursor(csr);
    }
}
