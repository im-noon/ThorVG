//
//  TvgContentView.m
//  ThorVG
//
//  Created by NooN on 25/2/25.
//

#import "TvgContentView.h"
#include <thorvg.h>
#include <math.h>
#include <cstring>


@interface TvgContentView () {
    TvgContentType _contentType;
    tvg::Animation* _animation; // For Lottie animations.
    tvg::Picture* _picture; // For static SVG content.
    CADisplayLink* _displayLink;
    CFTimeInterval _startTime;
}

@end

@implementation TvgContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize ThorVG once.
        if (tvg::Initializer::init(0) != tvg::Result::Success) {
            NSLog(@"Failed to initialize ThorVG");
        }
        _animation = nullptr;
        _picture = nullptr;
        _displayLink = nil;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    _animation = nullptr;
    _picture = nullptr;
}

/// Rendering the current content into an image.
- (void)renderContent {
    int width = (int)self.bounds.size.width;
    int height = (int)self.bounds.size.height;
    if (width == 0 || height == 0) return;
    
    int bytesPerRow = width * sizeof(uint32_t);
    uint32_t* buffer = (uint32_t*)malloc(width * height * sizeof(uint32_t));
    if (!buffer) {
        NSLog(@"Failed to allocate rendering buffer");
        return;
    }
    memset(buffer, 0, width * height * sizeof(uint32_t));
    
    // Create a ThorVG canvas.
    auto canvas = tvg::SwCanvas::gen();
    // The stride is specified as the number of pixels per row.
    canvas->target(buffer, width, width, height, tvg::ColorSpace::ARGB8888);
    
    // Push the appropriate picture to the canvas.
    if (_contentType == TvgContentTypeLottie && _animation) {
        canvas->push(_animation->picture());
    }
    else if (_contentType == TvgContentTypeSVG && _picture) {
        canvas->push(_picture);
    }
    
    canvas->draw();
    canvas->sync();
    
    // Create a Core Graphics image from the rendered buffer.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextRef context = CGBitmapContextCreate(buffer,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    if (!context) {
        NSLog(@"Failed to create bitmap context");
        free(buffer);
        CGColorSpaceRelease(colorSpace);
        return;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Update the UIImageView's image on the main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    });
    
    free(buffer);
}

/// Loads the content (SVG or Lottie)
- (void)loadContent:(NSString *)filePath withType:(TvgContentType)type {
    _contentType = type;
    
    // Invalidate any existing display link (used for Lottie).
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    if (type == TvgContentTypeLottie) {
        // Create and load the Lottie animation.
        _animation = tvg::Animation::gen();
        auto picture = _animation->picture();
        const char *path = [filePath UTF8String];
        if (picture->load(path) != tvg::Result::Success) {
            NSLog(@"Failed to load Lottie JSON: %@", filePath);
            _animation = nullptr;
            return;
        }
        
        // Compute scaling to fit the view’s bounds.
        CGFloat viewWidth = self.bounds.size.width;
        CGFloat viewHeight = self.bounds.size.height;
        float picW, picH;
        picture->size(&picW, &picH);
        
        float scale = 1.0f, shiftX = 0.0f, shiftY = 0.0f;
        if (picW > picH) {
            scale = viewWidth / picW;
            shiftY = (viewHeight - picH * scale) * 0.5f;
        }
        else {
            scale = viewHeight / picH;
            shiftX = (viewWidth - picW * scale) * 0.5f;
        }
        picture->scale(scale);
        picture->translate(shiftX, shiftY);
        
        _startTime = CACurrentMediaTime();
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
    }
    else if (type == TvgContentTypeSVG) {
        // Create and load the SVG picture.
        _picture = tvg::Picture::gen();
        const char *path = [filePath UTF8String];
        if (_picture->load(path) != tvg::Result::Success) {
            NSLog(@"Failed to load SVG: %@", filePath);
            _picture = nullptr;
            return;
        }
        // Render the SVG immediately.
        [self renderContent];
    }
}

/// For display link to update the Lottie animation.
- (void)updateAnimation:(CADisplayLink *)displayLink {
    if (_contentType != TvgContentTypeLottie || !_animation) return;
    
    CFTimeInterval elapsed = CACurrentMediaTime() - _startTime;
    uint32_t duration = _animation->duration();
    uint32_t totalFrame = _animation->totalFrame();
    
    // Calculate progress as a fraction (assumes duration is in seconds).
    float prog = fmod(elapsed, duration) / duration;
    _animation->frame(totalFrame * prog);
    
    [self renderContent];
}

@end
