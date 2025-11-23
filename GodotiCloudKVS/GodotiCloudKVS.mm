#include "GodotiCloudKVS.h"

#include "core/object/class_db.h"

@import Foundation;

static NSString *fromGodotString(const String &src) {
	return [NSString stringWithUTF8String:src.utf8().get_data()];
}

static String toGodotString(NSString *src) {
	return String::utf8(src.UTF8String);
}

/******** Observer *********/

@interface KVSObserver : NSObject
{
	GodotiCloudKVSListener *listener;
}

- (void)setListener:(GodotiCloudKVSListener*)listener;

@end

@implementation KVSObserver

- (void)storeDidChange:(NSNotification *)notification {
	NSNumber *reason = notification.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey];
	NSArray *changedKeys = notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];

	TypedArray<String> keys;
	for (NSString *key in changedKeys) {
		keys.append(toGodotString(key));
	}

	self->listener->post_change(reason.integerValue, keys);
	printf("KVSObserver: storeDidChange notification received.\n");
}

- (void)setListener:(GodotiCloudKVSListener*)listener {
	self->listener = listener;

	[[NSNotificationCenter defaultCenter] addObserver:self
										selector:@selector(storeDidChange:)
										name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
										object:[NSUbiquitousKeyValueStore defaultStore]];

	printf("initial sync: %ld\n", (long) NSUbiquitousKeyValueStoreInitialSyncChange);
	printf("server change: %ld\n", (long) NSUbiquitousKeyValueStoreServerChange);
	printf("quota violation change: %ld\n", (long) NSUbiquitousKeyValueStoreQuotaViolationChange);
	printf("account change: %ld\n", (long) NSUbiquitousKeyValueStoreAccountChange);
}

@end

/****** KVS ******/

void GodotiCloudKVS::_bind_methods() {
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("set_string", "key", "value"), &GodotiCloudKVS::set_string);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("set_int", "key", "value"), &GodotiCloudKVS::set_int);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("set_float", "key", "value"), &GodotiCloudKVS::set_float);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("set_bool", "key", "value"), &GodotiCloudKVS::set_bool);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("set_data", "key", "value"), &GodotiCloudKVS::set_data);

	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("get_string", "key"), &GodotiCloudKVS::get_string);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("get_int", "key"), &GodotiCloudKVS::get_int);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("get_float", "key"), &GodotiCloudKVS::get_float);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("get_bool", "key"), &GodotiCloudKVS::get_bool);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("get_data", "key"), &GodotiCloudKVS::get_data);

	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("dictionary_representation"), &GodotiCloudKVS::dictionary_representation);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("synchronize"), &GodotiCloudKVS::synchronize);
	ClassDB::bind_static_method("GodotiCloudKVS", D_METHOD("make_listener"), &GodotiCloudKVS::make_listener);
}

void GodotiCloudKVS::set_string(const String &key, const String &value) {
	[[NSUbiquitousKeyValueStore defaultStore] setString:fromGodotString(value) forKey:fromGodotString(key)];
}

void GodotiCloudKVS::set_int(const String &key, int64_t value) {
	[[NSUbiquitousKeyValueStore defaultStore] setLongLong:value forKey:fromGodotString(key)];
}

void GodotiCloudKVS::set_float(const String &key, double value) {
	[[NSUbiquitousKeyValueStore defaultStore] setDouble:value forKey:fromGodotString(key)];
}

void GodotiCloudKVS::set_bool(const String &key, bool value) {
	[[NSUbiquitousKeyValueStore defaultStore] setBool:value forKey:fromGodotString(key)];
}

void GodotiCloudKVS::set_data(const String &key, const PackedByteArray &value) {
	NSData *data = [NSData dataWithBytes:value.ptr() length:value.size()];
	[[NSUbiquitousKeyValueStore defaultStore] setData:data forKey:fromGodotString(key)];
}

String GodotiCloudKVS::get_string(const String &key) {
	NSString *value = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:fromGodotString(key)];
	return toGodotString(value ? value : @"");
}

int64_t GodotiCloudKVS::get_int(const String &key) {
	return [[NSUbiquitousKeyValueStore defaultStore] longLongForKey:fromGodotString(key)];
}

double GodotiCloudKVS::get_float(const String &key) {
	return [[NSUbiquitousKeyValueStore defaultStore] doubleForKey:fromGodotString(key)];
}

bool GodotiCloudKVS::get_bool(const String &key) {
	return [[NSUbiquitousKeyValueStore defaultStore] boolForKey:fromGodotString(key)];
}

PackedByteArray GodotiCloudKVS::get_data(const String &key) {
	NSData *data = [[NSUbiquitousKeyValueStore defaultStore] dataForKey:fromGodotString(key)];
	PackedByteArray result;
	result.resize(data.length);
	memcpy(result.ptrw(), data.bytes, data.length);
	return result;
}

Dictionary GodotiCloudKVS::dictionary_representation() {
	NSDictionary *dict = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];

	Dictionary result;

	for (NSString *key in dict) {
		id value = dict[key];
		String godot_key = toGodotString(key);

		if ([value isKindOfClass:[NSString class]]) {
			result[godot_key] = toGodotString((NSString*)value);
		} else if ([value isKindOfClass:[NSNumber class]]) {
			NSNumber *num = (NSNumber*)value;
			if (num == (__bridge NSNumber *)kCFBooleanTrue || num == (__bridge NSNumber *)kCFBooleanFalse) {
				result[godot_key] = num.boolValue;
			} else if (strcmp([num objCType], @encode(double)) == 0) {
				result[godot_key] = num.doubleValue;
			} else {
				result[godot_key] = num.longLongValue;
			}
		} else if ([value isKindOfClass:[NSData class]]) {
			PackedByteArray data;
			NSData *nsdata = (NSData*)value;
			data.resize(nsdata.length);
			memcpy(data.ptrw(), nsdata.bytes, nsdata.length);
			result[godot_key] = data;
		}
	}

	return result;
}

bool GodotiCloudKVS::synchronize() {
	return [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

Ref<GodotiCloudKVSListener> GodotiCloudKVS::make_listener() {
	Ref<GodotiCloudKVSListener> listener;
	listener.instantiate();
	return listener;
}

/******** LISTENER *******/

void GodotiCloudKVSListener::_bind_methods() {
	ADD_SIGNAL(MethodInfo("data_changed", PropertyInfo(Variant::INT, "reason"), PropertyInfo(Variant::ARRAY, "keys")));
}

void GodotiCloudKVSListener::post_change(int reason, const TypedArray<String> &keys) {
	call_deferred("emit_signal", "data_changed", reason, keys);
	printf("GodotiCloudKVSListener: data changed emitted.\n");
}

GodotiCloudKVSListener::GodotiCloudKVSListener() {
	observer = [[KVSObserver alloc] init];
	[observer setListener:this];
}

GodotiCloudKVSListener::~GodotiCloudKVSListener() {
	[observer release];
}
