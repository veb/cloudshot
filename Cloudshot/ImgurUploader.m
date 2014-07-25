//
//  ImgurUploader.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/25/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "ImgurUploader.h"
#import <ImgurSession.h>

@implementation ImgurUploader

- (void)uploadImageToCloud:(NSString *)imagePath imageName:(NSString *)destImageName
       withCompletionBlock:(CompletionBlock)completionBlock errorBlock:(ErrorBlock)errorBlock {

    [super uploadImageToCloud:imagePath imageName:destImageName withCompletionBlock:completionBlock errorBlock:errorBlock];
    
    [IMGImageRequest uploadImageWithFileURL:[NSURL fileURLWithPath:imagePath]
                                      title:destImageName description:@""
                          linkToAlbumWithID:nil
                                    success:^(IMGImage *image) {
                                        [self createShotWithThumbPath:self.localThumbnailPath localImageName:self.localName remotePath:[image.url absoluteString]];
                                        self.completionBlock([image.url absoluteString]);
                                    } progress:nil
                                    failure:^(NSError *error) {
                                        self.errorBlock(error);
                                    }];
}
@end
