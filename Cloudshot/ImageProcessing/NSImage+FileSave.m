//
//  NSImage+FileSave.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/24/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "NSImage+FileSave.h"

@implementation NSImage (FileSave)
- (void)saveAsJpegWithName:(NSString*)fileName {
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:imageData attributes:nil];
}
@end
