//
//  ContentView.swift
//  ThorVG
//
//  Created by NooN on 18/2/25.
//

import SwiftUI


struct ContentView: View {
    
    private func contentView(
        for resource: String,
        fileType: String,
        contentType: TvgContentType,
        in geometry: GeometryProxy
    ) -> some View {
        // Calculate a square size (half the available width)
        let viewSize = geometry.size.width * 0.5
        var xPosition = geometry.size.width
        if contentType == .SVG {
            xPosition = geometry.size.width+viewSize/2
        }
        return VStack {
            if let filePath = Bundle.main.path(forResource: resource, ofType: fileType) {
                TvgViewRepresentable(
                    filePath: filePath,
                    contentType: contentType,
                    width: viewSize,
                    height: viewSize
                )
                .frame(width: viewSize, height: viewSize)
                .clipped()
            } else {
                Text("\(resource.capitalized) not found")
            }
            Spacer()
        }
        .frame(width: xPosition, height: geometry.size.height)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("...Lottie animation...")
                .font(.headline)
            
            GeometryReader { geometry in
                contentView(
                    for: "example",
                    fileType: "json",
                    contentType: .lottie,
                    in: geometry
                )
            }
            .edgesIgnoringSafeArea(.all)
            
            Text("...SVG image...")
                .font(.headline)
            
            GeometryReader { geometry in
                contentView(
                    for: "example",
                    fileType: "svg",
                    contentType: .SVG,
                    in: geometry
                )
            }
            .edgesIgnoringSafeArea(.all)
            
            Spacer()
        }
        .padding()
    }
}
