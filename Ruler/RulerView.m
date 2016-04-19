//
//  RulerView.m
//  Ruler
//
//  Created by 张洋威 on 16/4/18.
//  Copyright © 2016年 太阳花互动. All rights reserved.
//

#import "RulerView.h"

typedef NS_ENUM(NSUInteger, RulerCelllLineType) {
    RulerCelllLineLong,
    RulerCelllLineShort,
};

@interface RulerCell : UICollectionViewCell

@property (nonatomic, assign) RulerCelllLineType lineType;
@property (nonatomic, assign) NSInteger sizeNumber;
@property (nonatomic, assign) BOOL lineHidden;

@end

@implementation RulerCell
{
    UILabel *_sizeLabel;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) / 2, CGRectGetWidth(frame), CGRectGetHeight(frame) / 2)];
        _sizeLabel.font = [UIFont systemFontOfSize:10];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_sizeLabel];
    }
    return self;
}

- (void)setLineType:(RulerCelllLineType)lineType {
    _lineType = lineType;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setLineHidden:(BOOL)lineHidden {
    _lineHidden = lineHidden;
    [self setNeedsDisplay];
}

- (void)setSizeNumber:(NSInteger)sizeNumber {
    _sizeNumber = sizeNumber;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_lineType == RulerCelllLineShort || _lineHidden) {
        _sizeLabel.hidden = YES;
    } else {
        _sizeLabel.hidden = NO;
    }
    _sizeLabel.text = [NSString stringWithFormat:@"%ld", (long)_sizeNumber];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIColor *lineColor = [UIColor darkGrayColor];
    CGFloat lineWidth = 1;
    if (_lineHidden) {
        lineColor = [UIColor clearColor];
    }
    [lineColor setStroke];
    CGFloat startX = rect.size.width / 2;
    CGFloat startY = 2;
    CGFloat endX = startX;
    CGFloat endY = CGRectGetHeight(rect) / 2 * 0.7f;
    if (_lineType == RulerCelllLineLong) {
        endY = CGRectGetHeight(rect) / 2;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
}

@end

IB_DESIGNABLE
@implementation RulerView
{
    UICollectionView *_rulerCollectionView;
    NSInteger _itemCount;
    CGFloat _itemWidth;
    
    CGFloat _showMinValue;
    CGFloat _showMaxValue;
    
    NSInteger _startIndex;
    NSInteger _visibleCellCount;
}

static NSString *const cellID = @"RulerCell";

- (void)awakeFromNib {
    [self setNeedsLayout];
}

#if !TARGET_INTERFACE_BUILDER
- (instancetype)initWithFrame:(CGRect)frame minValue:(CGFloat)minValue maxValue:(CGFloat)maxValue {
    self = [self initWithFrame:frame];
    if (self) {
        self.minValue = minValue;
        self.maxValue = maxValue;
        [self itemCount];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initRulerCollectionView];

    }
    return self;
}
#endif

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _initRulerCollectionView];
}

#pragma mark - 
- (void)setMaxValue:(NSInteger)maxValue {
    _maxValue = maxValue;
    [self itemCount];
}

- (void)setMinValue:(NSInteger)minValue {
    _minValue = minValue;
    [self itemCount];
}

- (void)setInitialValue:(NSInteger)initialValue {
    _initialValue = initialValue;
    if (_initialValue >= _minValue && _initialValue <= _maxValue) {
        CGFloat eachValue = (_showMaxValue - _showMinValue + 5) / (_itemWidth * _itemCount);
        CGFloat contentOffsetX = 0;
        if (_visibleCellCount % 2) {
            contentOffsetX = (_initialValue - _minValue) / eachValue * 1.0;
        } else {
            contentOffsetX = (_initialValue - _minValue + 2.5) / eachValue * 1.0;
        }
        [_rulerCollectionView setContentOffset:CGPointMake(contentOffsetX, 0) animated:NO];
        
        if ([_delegate respondsToSelector:@selector(rulerView:currentValue:)]) {
            [_delegate rulerView:self currentValue:[self currentValue]];
        }
    }
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RulerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.row % 2 == _startIndex % 2 && indexPath.row >= _startIndex) {
        cell.lineType = RulerCelllLineLong;
    } else if (indexPath.row >= _startIndex) {
        cell.lineType = RulerCelllLineShort;
    }
    
    NSInteger sizeNumber = (indexPath.row * 5 + _showMinValue);
    if (sizeNumber > _maxValue || sizeNumber < _minValue) {
        cell.lineHidden = YES;
    } else {
        cell.lineHidden = NO;
    }
    cell.sizeNumber = sizeNumber;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(rulerView:currentValue:)]) {
        [_delegate rulerView:self currentValue:[self currentValue]];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [self calibrateSizeNumber];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

    [self calibrateSizeNumber];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self calibrateSizeNumber];
}

#pragma mark -
- (void)_initRulerCollectionView {
    if (!_rulerCollectionView) {
        CGFloat padding = 4;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat tempItemWidth = (CGRectGetHeight(self.frame)  - padding * 2) / 2.0;
        CGFloat restItemWidth = ((CGRectGetWidth(self.frame) - padding * 2) - tempItemWidth * (int)((CGRectGetWidth(self.frame) - padding * 2) / tempItemWidth)) / (int)((CGRectGetWidth(self.frame) - padding * 2) / tempItemWidth);
        _itemWidth = tempItemWidth + restItemWidth;
        layout.itemSize = CGSizeMake(_itemWidth, tempItemWidth * 2);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _rulerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectInset(self.bounds, padding, padding) collectionViewLayout:layout];
        _rulerCollectionView.showsHorizontalScrollIndicator = NO;
        _rulerCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_rulerCollectionView registerClass:[RulerCell class] forCellWithReuseIdentifier:cellID];
        _rulerCollectionView.delegate = self;
        _rulerCollectionView.dataSource = self;
        [self addSubview:_rulerCollectionView];
        
        CGFloat lineWidth = 5;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - lineWidth) / 2.0, 0, lineWidth, CGRectGetHeight(self.frame))];
        lineView.backgroundColor = [UIColor greenColor];
        lineView.alpha = 0.7;
        [self addSubview:lineView];
        
        _rulerCollectionView.layer.masksToBounds = YES;
        _rulerCollectionView.layer.cornerRadius = CGRectGetHeight(_rulerCollectionView.frame) / 2.0;
        _rulerCollectionView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _rulerCollectionView.layer.borderWidth = 0.5;

#if !TARGET_INTERFACE_BUILDER
        [self itemCount];
        self.initialValue = self.initialValue;
#endif
    }
    
}

- (NSInteger)currentValue {
    
    CGFloat eachValue = (_showMaxValue - _showMinValue + 5) / (_itemWidth * _itemCount);
    NSInteger currentValue = 0;
    if (_visibleCellCount % 2) {
        currentValue = (NSInteger)roundf(_rulerCollectionView.contentOffset.x * eachValue + _minValue);
    } else {
        currentValue = (NSInteger)roundf(_rulerCollectionView.contentOffset.x * eachValue + _minValue - 2.5);
    }
    if (currentValue > _maxValue) {
        return _maxValue;
    }
    if (currentValue < _minValue) {
        return _minValue;
    }
    return currentValue;
}

- (void)itemCount {
    if (_maxValue >= _minValue) {
        
        _visibleCellCount = ceilf(CGRectGetWidth(_rulerCollectionView.frame) / _itemWidth);
        _startIndex = (int)(_visibleCellCount / 2.0);
        _showMinValue = _minValue - (int)(_visibleCellCount / 2.0) * 5;
        _showMaxValue = _maxValue + (int)(_visibleCellCount / 2.0) * 5;
        if (_visibleCellCount % 2 == 0) {
            [_rulerCollectionView setContentOffset:CGPointMake(_itemWidth / 2.0, 0) animated:YES];
        }
        
        _itemCount = (_showMaxValue - _showMinValue) / 5 + 1;
        [_rulerCollectionView reloadData];
    }
    
}

- (void)calibrateSizeNumber {

    if (_visibleCellCount % 2) {
        return;
    }
    if (_rulerCollectionView.contentOffset.x < _itemWidth / 2.0) {
        [_rulerCollectionView setContentOffset:CGPointMake(_itemWidth / 2.0, 0) animated:YES];
    }

    if (_rulerCollectionView.contentSize.width - _rulerCollectionView.contentOffset.x - _rulerCollectionView.frame.size.width < _itemWidth / 2.0) {
        [_rulerCollectionView setContentOffset:CGPointMake(_rulerCollectionView.contentSize.width - _rulerCollectionView.frame.size.width - _itemWidth / 2.0, 0) animated:YES];
    }
}

@end
