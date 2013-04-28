//
//  CustomView.h
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 3/1/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomViewProtocol <NSObject>

- (void) customViewWillClose;
- (void) customViewDidClose;

@end

@interface CustomView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSString *_imageName;
}

@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) UIButton *close;
@property (nonatomic,retain) NSString *imageName;
@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic) int imageNo;
@property (weak) id<CustomViewProtocol> delegate;

@end
