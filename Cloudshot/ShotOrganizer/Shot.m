//
//  Shot.m
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/24/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import "Shot.h"

@implementation Shot

- (void)persist {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *path = [appSupportDir path];
    path = [path stringByAppendingPathComponent:@"Cloudshot"];
    NSString *directory = path;
    NSString *plistPath = [path stringByAppendingPathComponent:@"recents.plist"];
    

    NSMutableArray * shotArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    if (shotArray == nil) {
        shotArray = [NSMutableArray array];
    }
    [shotArray addObject:@{
                           @"name":self.name,
                           @"url":self.url,
                           @"imgPath":self.imgPath
                           }];
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:shotArray
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        [[NSFileManager defaultManager] createFileAtPath:plistPath contents:plistData attributes:nil];
    }
}

+ (NSArray *)fetchAll {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *path = [appSupportDir path];
    path = [path stringByAppendingPathComponent:@"Cloudshot"];
    NSString *directory = path;
    NSString *plistPath = [path stringByAppendingPathComponent:@"recents.plist"];
    
    
    NSArray * shotArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *shots = [NSMutableArray array];
    for (NSDictionary *dict in shotArray) {
        Shot *shot = [Shot new];
        shot.name = dict[@"name"];
        shot.url = dict[@"url"];
        shot.imgPath = dict[@"imgPath"];
        
        [shots addObject:shot];
    }
    return shots;
}

@end
