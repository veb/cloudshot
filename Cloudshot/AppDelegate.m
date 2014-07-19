//
//  AppDelegate.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "AppDelegate.h"
#import "GeneralPreferencesViewController.h"
#import <MASPreferencesWindowController.h>
#import "OwnCloudUploader.h"

@interface AppDelegate ()
@property (nonatomic, strong)NSMetadataQuery *query;
@property (nonatomic, strong)OwnCloudUploader *ownCloudUploader;

@end

@implementation AppDelegate

- (void)awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"Cloudshot"];
    [self.statusItem setHighlightMode:YES];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Preferences" action:@selector(openPreferences:) keyEquivalent:@""];
    _statusItem.menu = menu;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.query = [NSMetadataQuery new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidStartGatheringNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidUpdateNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidFinishGatheringNotification object:_query];
    
    [self.query setDelegate:self];
    [self.query setPredicate:[NSPredicate predicateWithFormat:@"kMDItemIsScreenCapture = 1"]];
    [self.query startQuery];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    self.ownCloudUploader = [OwnCloudUploader new];

}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.query stopQuery];
    [self.query setDelegate:nil];
    self.query = nil;
    [self setQueryResults:nil];
}


- (NSWindowController *)preferencesWindowController {
    if (_preferencesWindowController == nil) {
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] init];
        NSArray *controllers = @[generalViewController];
        NSString *title = @"Preferences";
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    
    return _preferencesWindowController;
}

- (void)openPreferences:(id)sender {

    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:nil];
}

NSString *const kFocusedAdvancedControlIndex = @"FocusedAdvancedControlIndex";

- (NSInteger)focusedAdvancedControlIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kFocusedAdvancedControlIndex];
}

- (void)setFocusedAdvancedControlIndex:(NSInteger)focusedAdvancedControlIndex
{
    [[NSUserDefaults standardUserDefaults] setInteger:focusedAdvancedControlIndex forKey:kFocusedAdvancedControlIndex];
}


- (void)queryUpdated:(NSNotification *)notification {
    [self setQueryResults:[self.query results]];
    
    if ([notification.name isEqualToString:NSMetadataQueryDidUpdateNotification]) {
        NSMetadataItem *item =  [notification.userInfo[(NSString*)kMDQueryUpdateAddedItems] lastObject];
        if (!self.ownCloudUploader) {
            self.ownCloudUploader = [OwnCloudUploader new];
        }
        [self.ownCloudUploader uploadImageToOwnCloud:[item valueForAttribute:NSMetadataItemPathKey] imageName:[item valueForKey:NSMetadataItemFSNameKey]];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

-(IBAction)showSettings:(id)sender {
    
}




@end
