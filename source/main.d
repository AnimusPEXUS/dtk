module dtk.main;

PlatformI instantiatePlatform()
{
    version (PLATFORM_SDL_DESKTOP)
    {
        import dtk.platforms.sdl_desktop.SDLDesktopPlatform;

        auto ret = new SDLDesktopPlatform();
        return ret;
    }
    else version (PLATFORM_MOZILLA_WEB_EXTENSION)
    {
        import dtk.platforms.mozilla_web_extension.MozillaWebExtensionPlatform;

        auto ret = new MozillaWebExtensionPlatform();
        return ret;
    }
    else version (PLATFORM_MOZILLA_WEB_APPLICATION)
    {
        import dtk.platforms.mozilla_web_application.MozillaWebApplicationPlatform;

        auto ret = new MozillaWebApplicationPlatform();
        return ret;
    }
    else
    {
        throw Exception("platform not supported");
    }
}
