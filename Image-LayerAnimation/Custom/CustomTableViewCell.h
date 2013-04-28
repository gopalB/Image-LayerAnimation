//
//  CustomTableViewCell.h
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 2/6/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CustomTableViewCell : UITableViewCell
{
    UIImageView *imageView;
    NSString *imageName;
}
@property (nonatomic,retain) NSString *imageName;
@property(nonatomic,retain) UIImageView *imageView;

@end
