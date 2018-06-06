//
//  MNetAddSize.h
//  Pods
//
//  Created by akshay.d on 20/02/17.
//
//

#import <Foundation/Foundation.h>

@class MNetAdSize;

/// Helper function to create MNetAdSize instance
extern MNetAdSize *_Nullable MNetCreateAdSize(NSInteger width, NSInteger height);

@interface MNetAdSize : NSObject

/// Adsize height
@property (atomic, nonnull) NSNumber *h;

/// Adsize width
@property (atomic, nonnull) NSNumber *w;

@end
