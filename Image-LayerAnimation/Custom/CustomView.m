//
//  CustomView.m
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 3/1/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import "CustomView.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5
#define IMAGE_WIDTH 300
#define IMAGE_HEIGHT 300

@implementation CustomView
@synthesize scrollView = _scrollView;
@synthesize imageName = _imageName;
@synthesize imageView = _imageView;
@synthesize close = _close;
@synthesize imageNo;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, self.frame.size.width, IMAGE_HEIGHT)];
        _scrollView.scrollEnabled = YES;
        _scrollView.userInteractionEnabled = true;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _scrollView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.canCancelContentTouches = NO;
        _scrollView.bounces = YES;
        [self addSubview:_scrollView];
        
        _close = [[UIButton alloc]initWithFrame:CGRectMake(250, 20, 50, 50)];
        _close.titleLabel.text = @"Close";
        [_close addTarget:self action:@selector(closeCustomView) forControlEvents:UIControlEventTouchUpInside];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) closeCustomView{
    [self.delegate customViewWillClose];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    for (int i=0; i<21; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image_%d.jpg",i+1]];
        CGSize destinationSize = CGSizeMake(self.frame.size.width, IMAGE_HEIGHT);
        
        UIGraphicsBeginImageContext(destinationSize);
        [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGFloat xOrigin = i * self.frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                              CGRectMake(xOrigin, 0,
                                         self.frame.size.width,
                                         IMAGE_HEIGHT)];        
        imageView.userInteractionEnabled = YES;
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.scrollView addSubview:imageView];
    }

    self.scrollView.contentSize = CGSizeMake(self.frame.size.width *
                                             21,
                                             IMAGE_HEIGHT);
    
    float minimumScale = [self.scrollView frame].size.width  / self.frame.size.width;
    [self.scrollView setMinimumZoomScale:minimumScale];
    [self.scrollView setZoomScale:minimumScale];
    
    //scroll to specified imageNo
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.origin.x = scrollViewFrame.size.width * imageNo;
    scrollViewFrame.origin.y = 0;
    [self.scrollView scrollRectToVisible:scrollViewFrame animated:NO];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"<<touchesBegan");
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"<<touchesEnded");
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"<<touchesMoved");
    [super touchesMoved:touches withEvent:event];
}

-(void)dealloc
{
    self.imageView = nil;
    _imageView = nil;
    _scrollView = nil;
    _imageName = nil;
}

@end
