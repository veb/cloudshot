//
//  OwnCloudUploader.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "OwnCloudUploader.h"
#import <DAVKit/DAVKit.h>
#import <AFNetworking.h>
#import <RaptureXML/RXMLElement.h>
#import <Base64/MF_Base64Additions.h>
#import <FXKeychain.h>

@interface OwnCloudUploader () <DAVRequestDelegate>
@property (nonatomic, strong)DAVSession *davSession;
@end


@implementation OwnCloudUploader

- (void)uploadImageToOwnCloud:(NSString *)imagePath imageName:(NSString *)destImageName{
    NSString *username = [FXKeychain defaultKeychain][@"username_owncloud"]?:@"";
    NSString *password = [FXKeychain defaultKeychain][@"password_owncloud"]?:@"";
    NSString *baseURL = [FXKeychain defaultKeychain][@"baseurl_owncloud"]?:@"";
    
    
    DAVCredentials  *credentials = [[DAVCredentials alloc] initWithUsername:username
                                                                   password:password];
    
    NSURL *davURL = [NSURL URLWithString:[baseURL stringByAppendingString:@"/remote.php/webdav"]];
    _davSession = [[DAVSession alloc] initWithRootURL:davURL credentials:credentials];
    _davSession.allowUntrustedCertificate = YES;
    
    NSData *fileContent = [NSData dataWithContentsOfFile:imagePath];
    
    DAVPutRequest *putRequest = [[DAVPutRequest alloc] initWithPath:destImageName];
    putRequest.data = fileContent;
    putRequest.delegate = self;
    [_davSession enqueueRequest:putRequest];
}


- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

// The resulting object varies depending on the request type
- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSString *username = [FXKeychain defaultKeychain][@"username_owncloud"]?:@"";
    NSString *password = [FXKeychain defaultKeychain][@"password_owncloud"]?:@"";
    NSString *baseURL = [FXKeychain defaultKeychain][@"baseurl_owncloud"]?:@"";

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    NSDictionary *params = @{
                             @"path" : [@"/" stringByAppendingString:aRequest.path],
                             @"shareType" : [NSNumber numberWithInt:3]
                             };
    
    NSString *urlString = [baseURL stringByAppendingString:@"/ocs/v1.php/apps/files_sharing/api/v1/shares"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawXML = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:responseObject];
        [rootXML iterate:@"data.url" usingBlock:^(RXMLElement *element) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            NSDictionary *params = @{@"format": @"json",
                                     @"action": @"shorturl",
                                     @"url":element.text};
            [manager GET:@"http://veb.co.nz/url/api.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (responseObject) {
                    NSString *tinyURL = responseObject[@"shorturl"];
                    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
                    [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
                    [pasteBoard setString:tinyURL forType:NSStringPboardType];
                    
                    NSUserNotification *successNotification = [[NSUserNotification alloc] init];
                    successNotification.title = @"Cloudshot";
                    successNotification.informativeText = @"The link has been copied to your clipboard";
                    successNotification.soundName = NSUserNotificationDefaultSoundName;
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:successNotification];
                    
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}


- (void)requestDidBegin:(DAVRequest *)aRequest{
    
}

@end
