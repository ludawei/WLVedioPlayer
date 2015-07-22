//
//  UIView+Extra.h
//  Spendify
//
//  Created by 曹 君平 on 1/15/13.
//  Copyright (c) 2013 Tsao Chunping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extra)

@property CGFloat x;
@property CGFloat y;
@property CGFloat width;
@property CGFloat height;

- (UIImage *)viewShot;
- (UIImage *)viewShot_2x;

@end
