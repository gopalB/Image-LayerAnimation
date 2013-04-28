//
//  CustomTableViewCell.m
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 2/6/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "Constants.h"
#import "Util.h"


@interface CustomTableViewCell()
@end


@implementation CustomTableViewCell

@synthesize imageView;
@synthesize imageName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[UIImageView alloc] init];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    bool exists = [Util imageExists:self.imageName];
    UIImage *image;
    if (exists) {
        //low version of image exists in documents directory
        //load image from disk
        image = [Util getImage:self.imageName];
    }
    else {
        //reduce image size to speicific size
        image = [UIImage imageNamed:self.imageName];
        CGSize destinationSize = CGSizeMake(IMAGE_WIDTH,IMAGE_HEIGHT);
        UIGraphicsBeginImageContext(destinationSize);
        [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //save image in background thread
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [Util saveImage:image imageName:self.imageName];
        });
    }
    imageView.frame = self.bounds;
    imageView.image = image;
}
@end
