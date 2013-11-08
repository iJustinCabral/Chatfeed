//
//  BlackholeView.m
//  BlackholeView
//
//  Created by Larry Ryan on 10/26/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "BlackholeView.h"

@interface BlackholeView ()

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation BlackholeView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
        self.particleColor = [UIColor chatFeedGreen];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
        self.particleColor = [UIColor chatFeedGreen];
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame andParticleColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
	
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
        self.particleColor = color;
	}
	
	return self;
}

+ (Class)layerClass
{
    // configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self configureEmitterLayer];
}

- (void)configureEmitterLayer
{
    if (!self.emitterLayer)
    {
        self.emitterLayer = (CAEmitterLayer *)self.layer;
    }
    
	self.emitterLayer.name = @"emitterLayer";
	self.emitterLayer.emitterPosition = CGPointMake(156, 568);
	self.emitterLayer.emitterZPosition = 0;
    
	self.emitterLayer.emitterSize = CGSizeMake(320.00, 1.00);
	self.emitterLayer.emitterDepth = 0.00;
    
	self.emitterLayer.emitterShape = kCAEmitterLayerLine;
    
	self.emitterLayer.emitterMode = kCAEmitterLayerSurface;
    
	self.emitterLayer.renderMode = kCAEmitterLayerAdditive;
    
	self.emitterLayer.seed = 4067248050;
    
    [self updateEmitterCells];
}

- (void)updateEmitterCells
{
    self.emitterLayer.emitterCells = @[[self emitterCellWithColor:self.particleColor]];
}

- (CAEmitterCell *)emitterCellWithColor:(UIColor *)color
{
    // Create the emitter Cell
	CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
	
	emitterCell.name = @"blackhole";
	emitterCell.enabled = YES;
    
	emitterCell.contents = (id)[[UIImage imageNamed:@"spark.png"] CGImage];
	emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
    
	emitterCell.magnificationFilter = kCAFilterLinear;
	emitterCell.minificationFilter = kCAFilterLinear;
	emitterCell.minificationFilterBias = 0.00;
    
	emitterCell.scale = 0.12;
	emitterCell.scaleRange = 0.00;
	emitterCell.scaleSpeed = 0.00;
    
	emitterCell.color = color.CGColor;
	emitterCell.redRange = 0.00;
	emitterCell.greenRange = 0.00;
	emitterCell.blueRange = 0.00;
	emitterCell.alphaRange = 0.50;
    
	emitterCell.redSpeed = 0;
	emitterCell.greenSpeed = 0;
	emitterCell.blueSpeed = 0;
	emitterCell.alphaSpeed = -2.60;
    
	emitterCell.lifetime = 7.90;
	emitterCell.lifetimeRange = 2.60;
	emitterCell.birthRate = 1000;
	emitterCell.velocity = 1000.00;
	emitterCell.velocityRange = 920.00;
	emitterCell.xAcceleration = 0.00;
	emitterCell.yAcceleration = 0.00;
	emitterCell.zAcceleration = 0.00;
    
	// these values are in radians, in the UI they are in degrees
	emitterCell.spin = 0.000;
	emitterCell.spinRange = 0.000;
	emitterCell.emissionLatitude = 1.690;
	emitterCell.emissionLongitude = 3.140;
	emitterCell.emissionRange = 0.000;
    
    return emitterCell;
}

#pragma mark - Properties

- (void)setParticleColor:(UIColor *)particleColor
{
    _particleColor = particleColor;
    
    [self.emitterLayer setValue:particleColor
                     forKeyPath:@"emitterCells.blackhole.color"];
    
//    [self updateEmitterCells];
}

@end
