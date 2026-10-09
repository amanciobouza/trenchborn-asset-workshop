import ctypes as C,ctypes.util,sys
lib=C.CDLL(ctypes.util.find_library('lua5.4'));lib.luaL_newstate.restype=C.c_void_p
lib.luaL_openlibs.argtypes=[C.c_void_p];lib.luaL_loadfilex.argtypes=[C.c_void_p,C.c_char_p,C.c_char_p];lib.lua_pcallk.argtypes=[C.c_void_p,C.c_int,C.c_int,C.c_int,C.c_longlong,C.c_void_p];lib.lua_tolstring.argtypes=[C.c_void_p,C.c_int,C.c_void_p];lib.lua_tolstring.restype=C.c_char_p
l=lib.luaL_newstate();lib.luaL_openlibs(l);rc=lib.luaL_loadfilex(l,sys.argv[1].encode(),None)
if not rc:rc=lib.lua_pcallk(l,0,-1,0,0,None)
if rc:print(lib.lua_tolstring(l,-1,None).decode())
sys.exit(bool(rc))
