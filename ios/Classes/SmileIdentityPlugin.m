#import "SmileIdentityPlugin.h"
#import "smile_identity_plugin-Swift.h"

@implementation SmileIdentityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SmileIdentity registerWithRegistrar:registrar];
}
@end
