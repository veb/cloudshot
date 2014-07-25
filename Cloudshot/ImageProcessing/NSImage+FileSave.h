//
//  NSImage+FileSave.h
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/24/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (FileSave)
- (void)saveAsJpegWithName:(NSString*)fileName;
@end
