//
//  GeneralPreferencesViewController.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "GeneralPreferencesViewController.h"
#import <FXKeychain.h>
@interface GeneralPreferencesViewController ()

@end

@implementation GeneralPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)init
{
    return [super initWithNibName:@"GeneralPreferencesViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameUserAccounts];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Account", @"Toolbar item name for the General preference pane");
}

- (void)saveCredentials:(id)sender {
    [FXKeychain defaultKeychain][@"baseurl_owncloud"] = self.txtServerURL.stringValue;
    [FXKeychain defaultKeychain][@"username_owncloud"] = self.txtUsername.stringValue;
    [FXKeychain defaultKeychain][@"password_owncloud"] = self.txtPassword.stringValue;
    [FXKeychain defaultKeychain][@"remotepath_owncloud"] = self.txtRemotePath.stringValue;
}

- (void)awakeFromNib {
    self.txtServerURL.stringValue = [FXKeychain defaultKeychain][@"baseurl_owncloud"]?:@"";
    self.txtUsername.stringValue = [FXKeychain defaultKeychain][@"username_owncloud"]?:@"";
    self.txtPassword.stringValue = [FXKeychain defaultKeychain][@"password_owncloud"]?:@"";
    self.txtRemotePath.stringValue = [FXKeychain defaultKeychain][@"remotepath_owncloud"]?:@"";
}

@end
