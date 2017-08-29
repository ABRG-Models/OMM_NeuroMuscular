#ifdef _WIN32
#	ifdef saccsim_EXPORTS
#		define saccsim_API __declspec(dllexport)
#	else
#		define saccsim_API  __declspec(dllimport)
#	endif
#else
#	define saccsim_API
#endif // WIN32
