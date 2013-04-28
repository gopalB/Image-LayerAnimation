//
//  ViewController.m
//  Facebook-ImageViewAnimation
//
//  Created by Gopal on 2/6/13.
//  Copyright (c) 2013 Gopal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "Constants.h"
#import "Util.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define IMAGE_ORIGIN_X 10
#define IMAGE_ORIGIN_Y 180
#define IMAGE_END_Y IMAGE_ORIGIN_Y + IMAGE_HEIGHT


@interface ViewController ()
@end

@implementation ViewController

@synthesize imageTableView;
@synthesize imageList;

@synthesize bottomLayer = _bottomLayer;
@synthesize imageLayer = _imageLayer;
@synthesize imageBackgroundLayer = _imageBackgroundLayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    self.imageTableView.delegate = self;
    self.imageTableView.dataSource = self;
    
    //load image names in array
    NSMutableArray *array = [NSMutableArray array];
    for (int i=1; i<=20; i++) {
        [array addObject:[NSString stringWithFormat:@"image_%d.jpg",i]];
    }
    self.imageList = array;
    
    self.bottomLayer = [CALayer layer];
    self.bottomLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.bottomLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.bottomLayer.hidden = YES;
    
    self.imageBackgroundLayer = [CALayer layer];
    self.imageBackgroundLayer.opacity = 1.0;
    self.imageBackgroundLayer.frame = self.view.frame;
    
    self.imageLayer = [CALayer layer];
    self.imageLayer.frame = CGRectMake(IMAGE_ORIGIN_X,IMAGE_ORIGIN_Y,IMAGE_WIDTH,IMAGE_HEIGHT);
    [self.imageBackgroundLayer addSublayer:self.imageLayer];
    self.imageBackgroundLayer.hidden = YES;
    
    selectedSection = -1;
    touchType = DEFAULT;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //add layers
    [[[UIApplication sharedApplication]keyWindow].layer addSublayer:self.bottomLayer];
    [[[UIApplication sharedApplication]keyWindow].layer addSublayer:self.imageBackgroundLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.imageList.count;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    NSString *imageName = [self.imageList objectAtIndex:indexPath.section];
    if (indexPath.section != selectedSection) {
        cell.imageName = imageName;
    } else {
        cell.imageName = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //this is to avoid user tapping on a cell multiple times
    
    if (touchType != DEFAULT) {
        return;
    }
    //disabel tableview scrolling
    tableView.scrollEnabled = NO;
    touchType = TAPPED;
    //save selected image position
    selectedSection = indexPath.section;
    //remove selected image from the tableView
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    //take screenshot
    UIImage *screenShot = [Util screenshot];
    //load image from disk
    UIImage *image = [Util getImage:[NSString stringWithFormat:@"image_%d.jpg",selectedSection+1]];

    /*
     Get current location of TableViewCell imageLayer will start its animation from this location
     and save location to animate image layer back to original position
     */
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    cellRect = CGRectMake(IMAGE_ORIGIN_X, cellRect.origin.y - tableView.contentOffset.y + self.navigationController.navigationBar.frame.size.height
                    + [[UIApplication sharedApplication] statusBarFrame].size.height, IMAGE_WIDTH, IMAGE_HEIGHT);
    self.imageLayer.frame = cellRect;
    tappedImagePosition = self.imageLayer.position;
    
    
    //set image to imageLayer
    //and set screenshot to bottom layer
    self.imageLayer.contents = (id)image.CGImage;
    self.bottomLayer.contents = (id)screenShot.CGImage;
    
    self.bottomLayer.hidden = NO;
    self.imageBackgroundLayer.hidden = NO;

    //bottom layer opacity animation
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            self.bottomLayer.opacity = 0.0f;
        }];
        CABasicAnimation *animationOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationOpacity.fromValue = [NSNumber numberWithFloat:1.0f];
        animationOpacity.toValue = [NSNumber numberWithFloat:0.0f];
        animationOpacity.duration = 1.0;
        animationOpacity.removedOnCompletion = NO;
        animationOpacity.fillMode = kCAFillModeBoth;
        animationOpacity.additive = NO;
        [self.bottomLayer addAnimation:animationOpacity forKey:@"opacityIN"];
    } [CATransaction commit];
   
    //image layer animation
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            //hide tableView, navigationBar and status bar
            tableView.hidden = YES;
            self.navigationController.navigationBar.hidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }];
        CABasicAnimation *animationPosition = [CABasicAnimation animationWithKeyPath:@"position"];
        animationPosition.duration = 0.5;
        animationPosition.fromValue = [self.imageLayer valueForKey:@"position"];
        animationPosition.toValue = [NSValue valueWithCGPoint:CGPointMake(self.imageLayer.position.x, IMAGE_ORIGIN_Y + (IMAGE_HEIGHT/2))];
        self.imageLayer.position = CGPointMake(self.imageLayer.position.x, IMAGE_ORIGIN_Y  + (IMAGE_HEIGHT/2));
        [self.imageLayer addAnimation:animationPosition forKey:@"position"];
    } [CATransaction commit];
    
    //customCell.imageName = [NSString stringWithFormat:@"image_%d.jpg",selectedSection+1];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //animate cell when user scrolls down and no animation user scrolls up
    if (tableView.isDecelerating && indexPath.section > previousIndex) {
        [UIView transitionWithView:cell
                          duration:1.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction
                        animations:^{}
                        completion:NULL];
    }
    previousIndex = indexPath.section;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    yOffset = self.imageLayer.frame.origin.y - [touch locationInView:self.view].y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint startPoint = [touch locationInView:self.view];
    
    //start animating image layer and disable implicit animations
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.imageLayer.frame = CGRectMake(IMAGE_ORIGIN_X, startPoint.y+yOffset, IMAGE_WIDTH, IMAGE_HEIGHT);
    [CATransaction commit];
    
    //calculate bottom layer opacity value as per user touch movement
    NSNumber *opacityValue;
    if (startPoint.y + yOffset < IMAGE_ORIGIN_Y) {
        //moving up
        opacityValue = [NSNumber numberWithFloat:1.0-(self.imageLayer.frame.origin.y / IMAGE_ORIGIN_Y)];
    } else {
        //moving down
        opacityValue = [NSNumber numberWithFloat:((self.imageLayer.frame.origin.y + IMAGE_HEIGHT) / (IMAGE_END_Y)) - 1.0];
    }
    
    //animate bottom layer opacity as per touch move using explicit animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.beginTime = CACurrentMediaTime();
    animation.duration = 0.001;
    animation.toValue = opacityValue;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.additive = NO;
    [self.bottomLayer addAnimation:animation forKey:@"opacityIN"];
    //set the final value
    self.bottomLayer.opacity = opacityValue.floatValue;
    
    touchType = MOVED;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (touchType != MOVED) {
        return;
    }
    
    // Prepare the animation from the current position to the new position
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            //reset selected section and touchType
            selectedSection = -1;
            touchType = DEFAULT;
            //enable tableview scrolling
            self.imageTableView.scrollEnabled = YES;
            self.imageTableView.hidden = NO;
            self.bottomLayer.hidden = YES;
            self.imageBackgroundLayer.hidden = YES;
            self.navigationController.navigationBar.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [imageTableView reloadData];
        }];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.4;
        animation.fromValue = [self.imageLayer valueForKey:@"position"];
        animation.toValue = [NSValue valueWithCGPoint:tappedImagePosition];
        animation.fillMode = kCAFillModeBoth;
        self.imageLayer.position = tappedImagePosition;
        [self.imageLayer addAnimation:animation forKey:@"position"];
    } [CATransaction commit];
}
@end
