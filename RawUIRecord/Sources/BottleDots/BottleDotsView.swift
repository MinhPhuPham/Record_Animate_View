//
//  BottleDotsView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI
import Vision

struct BottleDotsView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea(.all)
            
            BubblySymbolCanvasView()
        }
    }
}

struct BottleDotsView_Previews: PreviewProvider {
    static var previews: some View {
//        BubblyBottleView()
        BubblySymbolCanvasView()
//            .background(Color.blue)
    }
}

struct BubblyBottleView: View {
    var body: some View {
        GeometryReader { proxy in
            let proxySize = proxy.size
            MKSymbolShape(systemName: "bottle")
                .stroke(style: StrokeStyle())
                .aspectRatio(CGSize(width: proxySize.width / 2, height: proxySize.height), contentMode: .fit)
//                .background(Color.red)
                .frame(width: ScreenHelper.width, height: ScreenHelper.height * 0.6, alignment: .center)
        }
        .frame(width: ScreenHelper.width, height: ScreenHelper.height * 0.8, alignment: .center)
    }
}


struct BubblySymbolCanvasView: View {
    let colors: [Color] = [.yellow, .red, .green]
    let bubbleCountPerRow: Int = 7  // Number of bubbles in one row
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard let path = generatePath(in: size, imageName: "bottle") else { return }
                
                // Draw the path stroke for visualization
                context.stroke(Path(path), with: .color(.black), lineWidth: 2)

                // Create and draw bubbles
                let bubbles = createGridBubbles(inside: path, numBubbles: bubbleCountPerRow)
                for bubble in bubbles {
                    let bubblePath = Path(ellipseIn: CGRect(x: bubble.position.x - bubble.radius,
                                                             y: bubble.position.y - bubble.radius,
                                                             width: bubble.radius * 2,
                                                             height: bubble.radius * 2))
                    context.fill(bubblePath, with: .color(bubble.color))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.gray)
        .frame(width: ScreenHelper.width * 0.6, height: ScreenHelper.height * 0.8)
    }
    
    func generatePath(in size: CGSize, imageName: String) -> CGPath? {
        guard let imgA = UIImage(named: imageName, in: nil, compatibleWith: nil)?
                .withTintColor(.black, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load image: \(imageName)!")
        }
        
        // Strip the bounding box empty space
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        
        // Render it on a white background
        let resultImage = UIGraphicsImageRenderer(size: imgB.size).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: imgB.size))
            imgB.draw(at: .zero)
        }
        
        guard let cgPath = detectVisionContours(from: resultImage) else { return nil }
        let insetAmount: CGFloat = 0
        let scW: CGFloat = (size.width - CGFloat(insetAmount)) / cgPath.boundingBox.width
        let scH: CGFloat = (size.height - CGFloat(insetAmount)) / cgPath.boundingBox.height
        
        // we need to invert the Y-coordinate space
        var transform = CGAffineTransform.identity
            .scaledBy(x: scW, y: -scH)
            .translatedBy(x: 0.0, y: -cgPath.boundingBox.height)
        
        return cgPath.copy(using: &transform)
    }
    
    func detectVisionContours(from sourceImage: UIImage) -> CGPath? {
        guard let cgImage = sourceImage.cgImage else {
            print("Could not get cgImage from UIImage")
            return nil
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 1.0
        contourRequest.maximumImageDimension = 512

        let requestHandler = VNImageRequestHandler(ciImage: inputImage, options: [:])
        do {
            try requestHandler.perform([contourRequest])
            if let contoursObservation = contourRequest.results?.first {
                return contoursObservation.normalizedPath
            }
        } catch {
            print("Vision error: \(error.localizedDescription)")
        }
        
        return nil
    }

    func createGridBubbles(inside path: CGPath, numBubbles: Int) -> [(position: CGPoint, radius: CGFloat, color: Color)] {
        let pathRect = path.boundingBox
        var bubbles: [(CGPoint, CGFloat, Color)] = []

        let bubbleDiameter = min(pathRect.width, pathRect.height) / CGFloat(numBubbles)
        let bubbleRadius = bubbleDiameter / 2

        for yIndex in 0..<numBubbles {
            for xIndex in 0..<numBubbles {
                let position = CGPoint(x: pathRect.minX + CGFloat(xIndex) * bubbleDiameter + bubbleRadius,
                                       y: pathRect.minY + CGFloat(yIndex) * bubbleDiameter + bubbleRadius)

                if path.contains(position) {
                    let color = colors.randomElement() ?? .yellow
                    bubbles.append((position, bubbleRadius, color))
                }
            }
        }
        return bubbles
    }
}


struct MKSymbolShape: InsettableShape {
    var insetAmount = 0.0
    let systemName: String
    
    var trimmedImage: UIImage {
        // get the symbol
        guard let imgA = UIImage(named: systemName, in: nil, compatibleWith: nil)?
            .withTintColor(.black, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load image: \(systemName)!")
        }
        
        // we want to "strip" the bounding box empty space
        // get a cgRef from imgA
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        // create imgB from the cgRef
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        
        // now render it on a white background
        let resultImage = UIGraphicsImageRenderer(size: imgB.size).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: imgB.size))
            imgB.draw(at: .zero)
        }
        
        return resultImage
    }
    
    func path(in rect: CGRect) -> Path {
        let inputImage = self.trimmedImage
        guard let cgPath = detectVisionContours(from: inputImage) else { return Path() }
        
        let scW: CGFloat = (rect.width - CGFloat(insetAmount)) / cgPath.boundingBox.width
        let scH: CGFloat = (rect.height - CGFloat(insetAmount)) / cgPath.boundingBox.height
        
        var transform = CGAffineTransform.identity
            .scaledBy(x: scW, y: -scH)
            .translatedBy(x: 0.0, y: -cgPath.boundingBox.height)
        
        guard let imagePath = cgPath.copy(using: &transform) else { return Path() }
        var path = Path(imagePath)
        
        // Draw the "bubbles" with allowed overlaps and random colors
        let boundingBox = imagePath.boundingBox.insetBy(dx: 5, dy: 5) // Inset 5px for margin
        print("boundingBox", boundingBox)
        return path
    }

    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
    
    func detectVisionContours(from sourceImage: UIImage) -> CGPath? {
        let inputImage = CIImage.init(cgImage: sourceImage.cgImage!)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 1.0
        contourRequest.maximumImageDimension = 512
        
        let requestHandler = VNImageRequestHandler(ciImage: inputImage, options: [:])
        try! requestHandler.perform([contourRequest])
        if let contoursObservation = contourRequest.results?.first {
            return contoursObservation.normalizedPath
        }
        
        return nil
    }
}
