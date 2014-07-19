//
//  OwnCloudUploader.h
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/19/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OwnCloudUploader : NSObject
- (void)uploadImageToOwnCloud:(NSString *)imagePath imageName:(NSString *)destImageName;
@end
