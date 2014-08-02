//
//  AppDelegate.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "AppDelegate.h"
#import "GeneralPreferencesViewController.h"
#import "AdvancedPreferencesViewController.h"

#import <MASPreferencesWindowController.h>
#import "OwnCloudUploader.h"
#import "ImgurUploader.h"

#import "ShotOrganizer/Shot.h"

#import <ImgurSession.h>

@interface AppDelegate ()
@property (nonatomic, strong)NSMetadataQuery *query;
@property (nonatomic, strong)UploaderStub *ownCloudUploader;



@end

@implementation AppDelegate

- (void)awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"cloud"]];
    [self.statusItem setHighlightMode:YES];
    
    self.statusMenu = [[NSMenu alloc] init];
    _statusItem.menu = self.statusMenu;
    
    [self rebuildStatusMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [IMGSession anonymousSessionWithClientID:@"3daff0692988496" withDelegate:self];
    
    self.query = [NSMetadataQuery new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidStartGatheringNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidUpdateNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidFinishGatheringNotification object:_query];
    
    [self.query setDelegate:self];
    [self.query setPredicate:[NSPredicate predicateWithFormat:@"kMDItemIsScreenCapture = 1"]];
    [self.query startQuery];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
//    self.ownCloudUploader = [OwnCloudUploader new];
    [self openPreferences:nil];

}

- (void)imgurSessionRateLimitExceeded {
    
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
        NSViewController *advancedViewController = [[AdvancedPreferencesViewController alloc] init];
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
        
        
        [self.statusItem setImage:[NSImage imageNamed:@"clouduploading"]];
        [self.ownCloudUploader uploadImageToCloud:[item valueForKey:NSMetadataItemPathKey] imageName:[item valueForKey:NSMetadataItemFSNameKey] withCompletionBlock:^(NSString *shortenedURL) {
            [self rebuildStatusMenu];
            [self displayLink:shortenedURL];
            [self.statusItem setImage:[NSImage imageNamed:@"cloudsuccess"]];
        } errorBlock:^(NSError *error) {
            [self.statusItem setImage:[NSImage imageNamed:@"clouderror"]];
            [self displayError:error];
            [self rebuildStatusMenu];
        }];

    }
}

- (void)displayError:(NSError *)error {
    NSUserNotification *successNotification = [[NSUserNotification alloc] init];
    successNotification.title = @"Cloudshot ERROR";
    successNotification.informativeText = @"Something happened! Error pasted to clipboard";
    successNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:successNotification];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
    [pasteBoard setString:error.description forType:NSStringPboardType];
}

- (void)displayLink:(NSString *)tinyURL {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
    [pasteBoard setString:tinyURL forType:NSStringPboardType];
    
    NSUserNotification *successNotification = [[NSUserNotification alloc] init];
    successNotification.title = @"Cloudshot";
    successNotification.informativeText = @"The link has been copied to your clipboard";
    successNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:successNotification];

}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

-(IBAction)showSettings:(id)sender {
    
}

- (void)shotClick:(id) sender {
    Shot *shot = [sender representedObject];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
    [pasteBoard setString:shot.url forType:NSStringPboardType];
    
    NSUserNotification *successNotification = [[NSUserNotification alloc] init];
    successNotification.title = @"Cloudshot";
    successNotification.informativeText = @"The link has been copied to your clipboard";
    successNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:successNotification];
}

- (void)rebuildStatusMenu {
    [self.statusMenu removeAllItems];
    [self.statusMenu addItemWithTitle:@"Preferences" action:@selector(openPreferences:) keyEquivalent:@""];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    
    for (Shot *shot in [Shot fetchAll]) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:shot.name action:@selector(shotClick:) keyEquivalent:@""];
        item.representedObject = shot;
        [item setImage:[[NSImage alloc] initWithContentsOfFile:shot.imgPath]];
        [self.statusMenu addItem:item];
    }
    
    
    [self.statusMenu addItemWithTitle:@"Quit Switcher" action:@selector(terminate:) keyEquivalent:@""];
}

@end
