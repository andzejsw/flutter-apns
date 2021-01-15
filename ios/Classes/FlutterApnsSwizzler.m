#import "FlutterApnsSwizzler.h"
#import <objc/runtime.h>
#import <Flutter/Flutter.h>

static int swizzleCounter;

@interface FlutterApnsSwizzler ()
@end

@implementation FlutterApnsSwizzler

+ (BOOL)didSwizzle {
    return swizzleCounter > 0;
}

+ (void)apns_registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    swizzleCounter++;
}

+ (void)load {

}

@end
