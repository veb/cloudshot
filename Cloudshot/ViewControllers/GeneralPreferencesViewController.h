//
//  GeneralPreferencesViewController.h
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GeneralPreferencesViewController : NSViewController
@property(nonatomic, weak) IBOutlet NSTextField *txtServerURL;

@property(nonatomic, weak) IBOutlet NSTextField *txtUsername;
@property(nonatomic, weak) IBOutlet NSTextField *txtPassword;
@property(nonatomic, weak) IBOutlet NSTextField *txtRemotePath;

-(IBAction)saveCredentials:(id)sender;
@end
