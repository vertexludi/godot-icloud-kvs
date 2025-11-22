#include "GodotiCloudKVS.h"

#include "core/object/class_db.h"

@import Foundation;

void GodotiCloudKVS::_bind_methods() {
	ClassDB::bind_method(D_METHOD("hello_world"), &GodotiCloudKVS::hello_world);
}

void GodotiCloudKVS::hello_world() {
	print_line("Hello world!");
}
