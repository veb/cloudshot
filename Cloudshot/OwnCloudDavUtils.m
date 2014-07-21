//
//  OwnCloudDavUtils.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/20/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "OwnCloudDavUtils.h"
#import <DAVKit/DAVKit.h>
#import <FXKeychain.h>

@interface OwnCloudDavUtils () <DAVRequestDelegate>
@property (nonatomic, copy) void (^makeDirectoryCompleteBlock)(NSError *error);
@end

@implementation OwnCloudDavUtils
-(void)createRemoteuploadPath:(NSString *)remotePath {
    
    NSDictionary *owncloudCred = [FXKeychain defaultKeychain][@"owncloud_cred"];
    
    NSString *baseURL = owncloudCred[@"baseurl"];
    NSString *username = owncloudCred[@"username"];
    NSString *password = owncloudCred[@"password"];
    
    DAVCredentials  *credentials = [[DAVCredentials alloc] initWithUsername:username
                                                                   password:password];
    
    NSURL *davURL = [NSURL URLWithString:[baseURL stringByAppendingString:@"/remote.php/webdav/"]];
    DAVSession *_davSession = [[DAVSession alloc] initWithRootURL:davURL credentials:credentials];
    _davSession.allowUntrustedCertificate = YES;

    DAVMakeCollectionRequest *makeRequest = [[DAVMakeCollectionRequest alloc] initWithPath:remotePath];
    makeRequest.delegate = self;
}

- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error {
    self.makeDirectoryCompleteBlock(error);
}


- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
    self.makeDirectoryCompleteBlock(nil);
}
@end
