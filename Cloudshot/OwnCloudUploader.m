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

- (void)uploadImageToCloud:(NSString *)imagePath imageName:(NSString *)destImageName withCompletionBlock:(CompletionBlock)completionBlock errorBlock:(ErrorBlock)errorBlock {
    
    [super uploadImageToCloud:imagePath imageName:destImageName withCompletionBlock:completionBlock errorBlock:errorBlock];
    
    NSDictionary *owncloudCred = [FXKeychain defaultKeychain][@"owncloud_cred"];
    
    NSString *baseURL = owncloudCred[@"baseurl"];
    NSString *username = owncloudCred[@"username"];
    NSString *password = owncloudCred[@"password"];
    NSString *remotePath = owncloudCred[@"remotepath"];

    
    DAVCredentials  *credentials = [[DAVCredentials alloc] initWithUsername:username
                                                                   password:password];
    
    NSURL *davURL = [NSURL URLWithString:[baseURL stringByAppendingString:@"/remote.php/webdav/"]];
    _davSession = [[DAVSession alloc] initWithRootURL:davURL credentials:credentials];
    _davSession.allowUntrustedCertificate = YES;
    
    NSData *fileContent = [NSData dataWithContentsOfFile:imagePath];
    
    DAVPutRequest *putRequest = [[DAVPutRequest alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", remotePath, destImageName]];
    putRequest.data = fileContent;
    putRequest.delegate = self;

    [_davSession enqueueRequest:putRequest];
    
}


- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error
{
    [self pasteoutError:error];

}

// The resulting object varies depending on the request type
- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSDictionary *owncloudCred = [FXKeychain defaultKeychain][@"owncloud_cred"];
    
    NSString *baseURL = owncloudCred[@"baseurl"];
    NSString *username = owncloudCred[@"username"];
    NSString *password = owncloudCred[@"password"];
    NSString *remotePath = owncloudCred[@"remotepath"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    NSDictionary *params = @{
                             @"path" : [NSString stringWithFormat:@"%@", aRequest.path],
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
                    [self createShotWithThumbPath:self.localThumbnailPath localImageName:self.localName remotePath:tinyURL];
                    self.completionBlock(tinyURL);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self pasteoutError:error];
            }];
            
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self pasteoutError:error];
    }];
}


- (void)pasteoutError:(NSError *)error {
    self.errorBlock(error);
    
}

- (void)requestDidBegin:(DAVRequest *)aRequest{
    
}

@end
