//
//  RulerView.h
//  Ruler
//
//  Created by 张洋威 on 16/4/18.
//  Copyright © 2016年 太阳花互动. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RulerViewDelegate;

IB_DESIGNABLE
@interface RulerView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) IBInspectable NSInteger minValue;
@property (nonatomic, assign) IBInspectable NSInteger maxValue;
@property (nonatomic, assign) IBInspectable NSInteger initialValue;

@property (nonatomic, assign, readonly) NSInteger currentValue;

@property (nonatomic, weak) id<RulerViewDelegate>delegate;

@end


@protocol RulerViewDelegate <NSObject>

@optional
- (void)rulerView:(RulerView *)rulerView currentValue:(NSInteger)currentValue;

@end