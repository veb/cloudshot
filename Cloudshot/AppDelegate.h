//
//  AppDelegate.h
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ImgurSession.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMetadataQueryDelegate, IMGSessionDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSArray *queryResults;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;

@property (nonatomic, strong) NSWindowController *preferencesWindowController;

@property (nonatomic) NSInteger focusedAdvancedControlIndex;
- (IBAction)openPreferences:(id)sender;



@end
