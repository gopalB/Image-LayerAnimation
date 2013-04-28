//
//  Util.h
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 4/15/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (BOOL) imageExists:(NSString *)imageName;
+ (void) saveImage:(UIImage *)img imageName:(NSString *)imageName;
+ (UIImage *)getImage:(NSString *)imageName;
+ (UIImage*)screenshot;

@end
