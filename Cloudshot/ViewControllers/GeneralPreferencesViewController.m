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
    return @"Account";
}

- (void)saveCredentials:(id)sender {
    [FXKeychain defaultKeychain][@"owncloud_cred"] = @{@"baseurl"   :self.txtServerURL.stringValue,
                                                       @"username"  :self.txtUsername.stringValue,
                                                       @"password"  :self.txtPassword.stringValue,
                                                       @"remotepath":self.txtRemotePath.stringValue};
    
}

- (void)awakeFromNib {
    NSDictionary *owncloudCred = [FXKeychain defaultKeychain][@"owncloud_cred"];
    
    self.txtServerURL.stringValue = owncloudCred[@"baseurl"];
    self.txtUsername.stringValue = owncloudCred[@"username"];
    self.txtPassword.stringValue = owncloudCred[@"password"];
    self.txtRemotePath.stringValue = owncloudCred[@"remotepath"];
}


@end
