//
//  snkyAppDelegate.m
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANAppDelegate.h"
#import "AuthViewController.h"
#import "MFSideMenuManager.h"
#import "ANSideMenuController.h"
#import "ANAPICall.h"
#import <QuartzCore/QuartzCore.h>

@implementation ANAppDelegate


static ANAppDelegate *sharedInstance = nil;

+ (ANAppDelegate *)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    sharedInstance = self;
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"c2a440bf3e4d6e2cb3a8267e89c71dc0_MTIwMjEwMjAxMi0wOC0xMCAyMTo0NjoyMC41MTQwODc"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _sideMenuController = [[ANSideMenuController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[_sideMenuController.navigationArray objectAtIndex:0]];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    // make sure to display the navigation controller before calling this
    [MFSideMenuManager configureWithNavigationController:navigationController
                                      sideMenuController:_sideMenuController];

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        NSLog(@"bacon");
    }
    
    // if we don't have an access token or it's not a valid token, display auth.
    // probably should move back to calling Safari. <-- disagree, this looks fine. -- jedi
    if (![[ANAPICall sharedAppAPI] hasAccessToken] || ![[ANAPICall sharedAppAPI] isAccessTokenValid])
    {
        AuthViewController *authView = [[AuthViewController alloc] init];
        [self.window.rootViewController presentModalViewController:authView animated:YES];
    }
    
    [self _setupGlobalStyling];
    
    return YES;
}

// Use this method to set up any styles that are used app wide
- (void)_setupGlobalStyling
{
    // Set up navigation bar bg
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarBg"] forBarMetrics:UIBarMetricsDefault];
    
    // Set up navigation title
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"Ubuntu-Medium" size:20.0f]}];
    
    // Set UIBarButton item bg
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"barbuttonBg"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    // Set up navigation bar rounded corners
    ((UINavigationController *)self.window.rootViewController).navigationBar.layer.mask = [self _navigationBarShapeLayer];
}

// https://[your registered redirect URI]/#access_token=[user access token]
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Display text
    
    /*NSString *fragment = [url fragment];
    NSArray *components = [fragment componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *component in components) {
        [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    
    NSLog(@"%@",parameters);
    
    NSString *token = [parameters objectForKey:@"access_token"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"access_token"];
    [defaults synchronize];
    NSLog(@"access_token saved to defaults");
    */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSArray *controllers = self.sideMenuController.navigationArray;
    [controllers makeObjectsPerformSelector:@selector(refresh)];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (CAShapeLayer *)_navigationBarShapeLayer
{
    CGFloat minx = 0.0f, midx = CGRectGetWidth(self.window.frame)/2.0f, maxx = CGRectGetWidth(self.window.frame);
    CGFloat miny = 0.0f, maxy = 60.0f;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minx, maxy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, 2.0f);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, 2.0f);
    CGPathAddLineToPoint(path, NULL, maxx, maxy);
    
    // Close the path
    CGPathCloseSubpath(path);
    
    // Fill & stroke the path
    CAShapeLayer *newShapeLayer = [[CAShapeLayer alloc] init];
    newShapeLayer.path = path;
    newShapeLayer.fillColor = [[UIColor greenColor] colorWithAlphaComponent:1.f].CGColor;
    CFRelease(path);
    
    return newShapeLayer;
}

@end
