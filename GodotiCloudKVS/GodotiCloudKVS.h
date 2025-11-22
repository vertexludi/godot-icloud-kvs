#pragma once

#include "core/object/ref_counted.h"

class GodotiCloudKVS : public RefCounted {
	GDCLASS(GodotiCloudKVS, RefCounted)

	static void _bind_methods();

public:
	void hello_world();
};
