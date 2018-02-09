//
//  MNetURL+Internal.h
//  Pods
//
//  Created by nithin.g on 26/07/17.
//
//


#ifndef MNetURL_Internal_h
#define MNetURL_Internal_h

#import "MNetURL.h"

@interface MNetURL()
@property (nonnull) NSString *urlProtocol;
@property (nonatomic) BOOL isDebug;

+ (BOOL)checkIfHttpAllowed;
@end

#endif /* MNetURL_Internal_h */
