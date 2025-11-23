# Godot iCloud key-value store plugin for iOS

This is a plugin that let's you use the [`NSUbiquitousKeyValueStore`](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore) from Godot. It allows you to store simple values on the user's iCloud storage to synchronize the values across multiple devices.

Note that storage for this is limited, as stated in the Apple documentation:

> - Your app can have no more than 1024 keys in the iCloud key-value store.
> - The total amount of available storage space for all values is 1 megabyte.
> - The maximum size for a single value is 1 megabyte. Therefore, if you associate 1 megabyte of data with a single key, you can’t write other keys to the store.
> - The maximum length for each key string is 128 characters using the UTF-16 encoding. Key strings don’t count against the 1 megabyte quota for values.

## Installation

1. Download the ZIP file of the latest release from the [releases page](https://github.com/vertexludi/godot-icloud-kvs/releases) according to your Godot version.
1. Extract the ZIP file somewhere in your PC.
1. Copy the `ios` folder and the `addons` folder from the extracted zip to your project.
1. Enable the `Godot I Cloud Kvs` plugin in the export preset for iOS (the name is a bit odd because Godot controls the capitalization).
1. Add the following the the `Entitlements/Additional` field of the export preset:
```xml
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
```

> [!TIP]
> The string added in the additional entitlements is a unique identifier for your data. If you have multiple apps that need to share data, this string needs to be the same in all of them.

## Usage

The `ICloudKVS` wrapper class is included in the addons folder so you can use it directly. It contains some static functions to handle setting and retrieving values, so you don't need to create any instance.

You can call the `ICloudKVS.synchronize()` function at startup, but usually it's not necessary, as the synchronization happens automatically (when the app starts and when it resumes from the background). In any case, do not count on this being updated instantaneously. The system is what decides when this is done, even if you do call the function.

### Setting values

There are five functions to set values:

- `set_string(key: String, value: String) -> void`
- `set_int(key: String, value: int) -> void`
- `set_float(key: String, value: float) -> void`
- `set_bool(key: String, value: bool) -> void`
- `set_data(key: String, value: PackedByteArray) -> void`

The `key` parameter is where the value is going to be stored (which is used to retrieve it), and the `value` parameter is the value itself.

If you need to store arbitrary values, you can use the [`var_to_bytes()`](https://docs.godotengine.org/en/4.5/classes/class_%40globalscope.html#class-globalscope-method-var-to-bytes) or [`var_to_bytes_with_objects()`](https://docs.godotengine.org/en/4.5/classes/class_%40globalscope.html#class-globalscope-method-var-to-bytes-with-objects) functions to create a `PackedByteArray` and use the `set_data()` function with this value.

### Getting values

Similarly to setting, there are five counterpart functions for getting values:

- `get_string(key: String) -> String`
- `get_int(key: String) -> int`
- `get_float(key: String) -> float`
- `get_bool(key: String) -> bool`
- `get_data(key: String) -> PackedByteArray`

Again, the `key` parameter is where the value is stored.

To restore data that was set using `var_to_bytes()`, you can use [`bytes_to_var()`](https://docs.godotengine.org/en/4.5/classes/class_%40globalscope.html#class-globalscope-method-bytes-to-var) (or [`bytes_to_var_with_objects`](https://docs.godotengine.org/en/4.5/classes/class_%40globalscope.html#class-globalscope-method-bytes-to-var-with-objects)).

You can also get all of the values as a `Dictionary` using the `dictionary_representation()` function.

### Changed notification

The system emits a notification when the values are changed externally (e.g. in another device). This plugin has a signal for this, but since signals in Godot requires an object, you need to do something like this:

```gdscript
var listener := ICloudKVS.make_listener();
listener.data_changed.connect(func(reason: ICloudKVS.Listener.Reason, keys: Array[String]) -> void:
    prints("Changed because:", reason)
    prints("Changed keys:", keys)
)
```

Keep a reference to the `listener` value, otherwise it's going to be freed and the signal won't be emitted.

See the [Apple documentation](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore/didchangeexternallynotification?language=objc) for more information about this notification.

## Development

Make sure to clone with submodules to get the Godot source. Or run `git submodule update --init` after cloning. Run `./scripts/generate_headers.sh` to start compiling Godot, long enough to create the generated headers.

The Demo project can be used to test the implementation. To make a build, run `./scripts/make_release.sh`. The project uses symbolic links, so there's no need to copy anything afterwards.
