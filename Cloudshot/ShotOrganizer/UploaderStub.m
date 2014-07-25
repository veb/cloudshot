//
//  UploaderStub.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/21/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "UploaderStub.h"
#import "NSImage+ProportionalScaling.h"
#import "NSImage+FileSave.h"
#import "Shot.h"

@implementation UploaderStub

- (void)uploadImageToCloud:(NSString *)imagePath imageName:(NSString *)destImageName withCompletionBlock:(CompletionBlock)completionBlock errorBlock:(ErrorBlock)errorBlock {
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;
    self.localName = destImageName;
    
    NSImage *image = [[[NSImage alloc] initWithContentsOfFile:imagePath] imageByScalingProportionallyToSize:NSSizeFromCGSize(CGSizeMake(40, 30))];

    
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *path = [appSupportDir path];
    path = [path stringByAppendingPathComponent:@"Cloudshot"];
    NSString *directory = path;
    NSString *destPath = [path stringByAppendingPathComponent:destImageName];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    [image saveAsJpegWithName:destPath];
    self.localThumbnailPath = destPath;
}

- (void)createShotWithThumbPath:(NSString *)thumbPath localImageName:(NSString *)imageName remotePath:(NSString *)remotePath {
    Shot *newShot = [Shot new];
    newShot.name = imageName;
    newShot.url = remotePath;
    newShot.imgPath = thumbPath;
    
    [newShot persist];
    
}
@end
