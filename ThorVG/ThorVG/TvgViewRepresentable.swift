//
//  TvgViewRepresentable.swift
//  ThorVG
//
//  Created by NooN on 25/2/25.
//

import SwiftUI
import UIKit


struct TvgViewRepresentable: UIViewRepresentable {
    let filePath: String
    let contentType: TvgContentType
    let width: CGFloat
    let height: CGFloat
    
    /// Computed frame from the provided dimensions.
    private var viewFrame: CGRect {
        CGRect(origin: .zero, size: CGSize(width: width, height: height))
    }
    
    func makeUIView(context: Context) -> TvgContentView {
        // Create TvgContentView with the desired frame.
        let view = TvgContentView(frame: viewFrame)
        view.contentMode = .scaleAspectFit
        
        // Load content (either SVG or Lottie) immediately.
        view.loadContent(filePath, with: contentType)
        return view
    }
    
    func updateUIView(_ uiView: TvgContentView, context: Context) {
        // Update the frame in case the parent view's dimensions change.
        uiView.frame = viewFrame
        
        // Reload the content.
        uiView.loadContent(filePath, with: contentType)
    }
}
