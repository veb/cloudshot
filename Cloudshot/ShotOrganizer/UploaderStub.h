//
//  UploaderStub.h
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/21/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploaderStub : NSObject

typedef void (^CompletionBlock)(NSString *shortenedURL);
typedef void (^ErrorBlock)(NSError *error);

@property (nonatomic, strong) CompletionBlock completionBlock;
@property (nonatomic, strong) ErrorBlock errorBlock;

@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *localThumbnailPath;

- (void)uploadImageToCloud:(NSString *)imagePath imageName:(NSString *)destImageName withCompletionBlock:(CompletionBlock)completionBlock errorBlock:(ErrorBlock)errorBlock;

- (void)createShotWithThumbPath:(NSString *)thumbPath localImageName:(NSString *)imageName remotePath:(NSString *)remotePath;

@end
