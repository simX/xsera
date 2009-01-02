#ifndef __apollo_utilities_resourcemanager_h
#define __apollo_utilities_resourcemanager_h

#include <SDL/SDL.h>
#include <string>

namespace ResourceManager
{

// utility function for reading from a RWops in full
void* ReadFull ( size_t* length, SDL_RWops* ops, int autoclose );

bool FileExists ( const std::string& name );
SDL_RWops* OpenFile ( const std::string& name ); // separate paths with /, they will be converted automatically
SDL_RWops* WriteFile ( const std::string& name );
void WriteFile ( const std::string& name, const void* data, size_t len );

void Init ( const std::string& appname );

}

#endif