//
//  UIView+Extra.m
//  Spendify
//
//  Created by 曹 君平 on 1/15/13.
//  Copyright (c) 2013 Tsao Chunping. All rights reserved.
//

#import "UIView+Extra.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Extra)

- (UIImage *)viewShot
{
    CGFloat restoredAlpha = self.alpha;
    
    self.alpha = 1.0;
    UIImage *image;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            @synchronized(self)
            {
                [self drawViewHierarchyInRect:self.bounds
                           afterScreenUpdates:YES];
            }
        }
        else
        {
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    self.alpha = restoredAlpha;
    
    return image;
}

- (UIImage *)viewShot_2x
{
    CGFloat restoredAlpha = self.alpha;
    
    CGFloat radio = [UIScreen mainScreen].scale;
    
    self.alpha = 1;
    UIImage *image;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, radio);
        
        if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [self drawViewHierarchyInRect:self.bounds
                       afterScreenUpdates:YES];
        }
        else
        {
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    self.alpha = restoredAlpha;
    
    return image;
}

-(CGFloat) x {
    return self.frame.origin.x;
}

-(void) setX:(CGFloat) newX {
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

-(CGFloat) y {
    return self.frame.origin.y;
}

-(void) setY:(CGFloat) newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

-(CGFloat) width {
    return self.frame.size.width;
}

-(void) setWidth:(CGFloat) newWidth {
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

-(CGFloat) height {
    return self.frame.size.height;
}

-(void) setHeight:(CGFloat) newHeight {
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

@end
