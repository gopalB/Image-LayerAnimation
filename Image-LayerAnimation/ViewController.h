//
//  ViewController.h
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 2/6/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"

typedef enum {
    DEFAULT,
    TAPPED,
    MOVED,
} TouchType;

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *imageTableView;
    NSArray* imageList;
    CGFloat yOffset;
    int selectedSection;
    CGPoint tappedImagePosition;
    int previousIndex;
    TouchType touchType;
}

@property(nonatomic,retain) UITableView *imageTableView;
@property(nonatomic,retain) NSArray *imageList;

@property (nonatomic,retain) CALayer *imageLayer;
@property (nonatomic,retain) CALayer *bottomLayer;
@property (nonatomic,retain) CALayer *imageBackgroundLayer;

@end
