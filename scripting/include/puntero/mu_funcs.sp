enum MapType {
	ultiduo, 
	koth, 
	mix
}

void GetConfig(char[] name, char[] buf, int size)
{
	switch (GetMapType(name))
	{
		case ultiduo:
			strcopy(buf, size, "etf2l_ultiduo.cfg");
		case koth:
			strcopy(buf, size, "Mix_koth.cfg");
		case mix:
			strcopy(buf, size, "Mix.cfg");
	}
}

MapType GetMapType(char[] map) {
	if (StrContains(map, "ultiduo_", false) != -1)
		return ultiduo;
	if (StrContains(map, "koth_", false) != -1)
		return koth;
	return mix;
}  