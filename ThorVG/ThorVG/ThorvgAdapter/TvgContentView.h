//
//  TvgSvgView.h
//  ThorVG
//
//  Created by NooN on 25/2/25.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TvgContentType) {
    TvgContentTypeSVG,
    TvgContentTypeLottie,
};

@interface TvgContentView : UIImageView

/// Loads content (either SVG or Lottie JSON).
/// @param filePath Full path to the file.
/// @param type The content type (SVG or Lottie).
- (void)loadContent:(NSString *)filePath withType:(TvgContentType)type;

@end
