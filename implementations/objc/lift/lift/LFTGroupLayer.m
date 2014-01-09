//
//  LFTGroupLayer.m
//  lift
//
//  Created by August Mueller on 1/7/14.
//  Copyright (c) 2014 Flying Meat Inc. All rights reserved.
//

#import "LFTGroupLayer.h"
#import "LFTBitmapLayer.h"

@interface LFTGroupLayer ()

@property (strong) NSMutableArray *layers;

@end

@implementation LFTGroupLayer

- (id)init {
	self = [super init];
	if (self != nil) {
		_layers = [NSMutableArray array];
	}
	return self;
}


- (void)readFromDatabase:(FMDatabase*)db {

    FMResultSet *rs = nil;
    
    if (_isBase) {
        rs = [db executeQuery:@"select id, sequence, uti, name from layers where parent_id is null order by sequence asc"];
    }
    else {
        [super readFromDatabase:db];
        
        rs = [db executeQuery:@"select id, sequence, uti, name from layers where parent_id = ? order by sequence asc", [self layerId]];
    }
    
    
    while ([rs next]) {
        
        NSString *uuid = [rs stringForColumn:@"id"];
        NSString *uti  = [rs stringForColumn:@"uti"];
        NSString *name = [rs stringForColumn:@"name"];
        
        #pragma message "FIXME: validate that the values here are good"
        
        if (!name) {
            name = @"";
        }
        
        debug(@"name: '%@'", name);
        
        LFTLayer *layer = nil;
        
        
#pragma message "FIXME: ask a delegate for a layer subclass?  And then if we still don't have one, then make our own."
        
        if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
            layer = [[LFTBitmapLayer alloc] init];
        }
        else {
            layer = [[LFTLayer alloc] init];
        }
        
        [layer setLayerId:uuid];
        [layer setLayerUTI:uti];
        [layer setLayerName:name];
        
        [layer readFromDatabase:db];
        
        [layer setParentLayerId:_isBase ? nil : [self layerId]];
        
        [_layers addObject:layer];
    }
    
    
    // need to load up the masks for the layers now.
    
    for (LFTLayer *layer in [self layers]) {
        
        /*
        NSString *parentId = [NSString stringWithFormat:@"mask-%@", [layer layerId]];
        rs = [db executeQuery:@"select id from layers where parent_id = ? order by sequence asc", parentId];
        
        if ([rs next]) {
            
            NSString *uuid = [rs stringForColumn:@"id"];
            …
        }
        
        [rs close];
        */
    }
    
}

@end