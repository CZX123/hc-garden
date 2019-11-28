#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@import Firebase;
@import GoogleMaps;
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FIRApp configure];
  [GMSServices provideAPIKey:@"AIzaSyD-mmzS2c9AcbKfT5Y4UhHypE5GiG7Bgqw"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
