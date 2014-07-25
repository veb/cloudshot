//
//  Shot.h
//  Cloudshot
//
//  Created by Ray Arvin Rimorin on 7/24/14.
//  Copyright (c) 2014 avwave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shot : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *imgPath;


- (void)persist;

+ (NSArray *)fetchAll;
@end