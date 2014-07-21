//
//  UploaderStub.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/21/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "UploaderStub.h"

@implementation UploaderStub

- (void)uploadImageToCloud:(NSString *)imagePath imageName:(NSString *)destImageName withCompletionBlock:(CompletionBlock)completionBlock errorBlock:(ErrorBlock)errorBlock {
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;
}
@end
