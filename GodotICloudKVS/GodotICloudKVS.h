#pragma once

#include "core/object/ref_counted.h"
#include "core/string/ustring.h"
#include "core/variant/typed_array.h"

@class KVSObserver;

class GodotICloudKVSListener final : public RefCounted  {
	GDCLASS(GodotICloudKVSListener, RefCounted)

	KVSObserver *observer;

protected:
	static void _bind_methods();

public:
	GodotICloudKVSListener();
	~GodotICloudKVSListener();

	void post_change(int reason, const TypedArray<String> &keys);
};

class GodotICloudKVS final : public RefCounted {
	GDCLASS(GodotICloudKVS, RefCounted)

protected:
	static void _bind_methods();

public:
	static void set_string(const String &key, const String &value);
	static void set_int(const String &key, int64_t value);
	static void set_float(const String &key, double value);
	static void set_bool(const String &key, bool value);
	static void set_data(const String &key, const PackedByteArray &value);

	static String get_string(const String &key);
	static int64_t get_int(const String &key);
	static double get_float(const String &key);
	static bool get_bool(const String &key);
	static PackedByteArray get_data(const String &key);

	static Dictionary dictionary_representation();

	static bool synchronize();
	static Ref<GodotICloudKVSListener> make_listener();
};
