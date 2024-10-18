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
            
            BubblySymbolView()
        }
    }
}

struct BottleView: View {
    let colors: [Color] = [.red, .green, .orange]
    let ballRadius: CGFloat = 10 // Initial ball radius
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let scaleFactor = size.width / 150.0 // Assuming original bottleWidth is 150 for scaling
            let bottleWidth = size.width * 0.8 // Assuming 80% of the container width for the bottle
            let bottleHeight = size.height * 0.9 // Assuming 90% of the container height for the bottle
            let scaledRadius = ballRadius * 1 // Scale the radius of the balls based on size
            
            ZStack {
                // Bottle Shape
                GeometryReader { imageProxy in
                    let imageSize = imageProxy.size // This gives you the size of the image
                    Image("bottle")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .onAppear {
                            print("Image size: \(imageSize)")
                        }
                        .background(Color.blue)
                }
                .frame(width: size.width, height: size.height, alignment: .center)
                
                // Balls inside the bottle
                let positions = placeBalls(in: CGSize(width: bottleWidth, height: bottleHeight), radius: scaledRadius)
                ForEach(positions.indices, id: \.self) { index in
                    Circle()
                        .fill(colors.randomElement()!)
                        .frame(width: scaledRadius * 2, height: scaledRadius * 2)
                        .position(positions[index])
                }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
//            .background(Color.red)
        }
        .frame(height: UIScreen.main.bounds.height * 0.6)
    }
    
    // Algorithm to place the balls with scaling
    func placeBalls(in size: CGSize, radius: CGFloat) -> [CGPoint] {
        var positions: [CGPoint] = []
        
        let bottleLeft = radius + 10
        let bottleRight = size.width - radius - 10
        let bottleBottom = size.height - radius - 10
        
        var currentY = bottleBottom
        
        while currentY > radius {
            var currentX = bottleLeft
            
            // Place balls in a row with slight overlap
            while currentX < bottleRight {
                let candidatePosition = CGPoint(x: currentX, y: currentY)
                positions.append(candidatePosition)
                
                currentX += radius * 1.8 // Adjust horizontal overlap (less than 2x the radius)
            }
            
            // Move up for the next row of balls with slight vertical overlap
            currentY -= radius * 1.8 // Adjust vertical overlap (less than 2x the radius)
        }
        
        return positions
    }
}


struct BottleDotsView_Previews: PreviewProvider {
    static var previews: some View {
//        GeometryReader { proxy in
//            let proxySize = proxy.size
//            MKSymbolShape(systemName: "bottle")
//                .stroke(style: StrokeStyle())
//                .aspectRatio(CGSize(width: proxySize.width / 2, height: proxySize.height), contentMode: .fit)
//        }
        BubblySymbolView()
    }
}

struct BubblySymbolView: View {
    let colors: [Color] = [.yellow, .red, .green]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let path = generatePath(in: geometry.size, imageName: "bottle") {
                    Path(path).stroke(Color.black, lineWidth: 2)
                    
                    // Draw bubbles inside path
                    ForEach(0..<200, id: \.self) { _ in
                        let bubble = createRandomBubble(inside: path.boundingBox, in: geometry.size)
                        if path.contains(bubble.position) {
                            Circle()
                                .fill(bubble.color)
                                .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                                .position(bubble.position)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: ScreenHelper.height * 0.8)
    }
    
    func generatePath(in size: CGSize, imageName: String) -> CGPath? {
        // get the symbol
        print("Run hereee")
        guard let imgA = UIImage(named: imageName, in: nil, compatibleWith: nil)?
            .withTintColor(.black, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load image: \(imageName)!")
        }
        
        print("Run to here")
        
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
        print("cgPath Run to hereeee")
        guard let cgPath = detectVisionContours(from: resultImage) else { return nil }
        print("cgPath", cgPath)
        return cgPath
    }
    
    func detectVisionContours(from sourceImage: UIImage?) -> CGPath? {
        guard let sourceImage = sourceImage,
              let cgImage = sourceImage.cgImage else { return nil }
        
        let inputImage = CIImage(cgImage: cgImage)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 1.0
        contourRequest.maximumImageDimension = 512
        
        let requestHandler = VNImageRequestHandler(ciImage: inputImage, options: [:])
        try? requestHandler.perform([contourRequest])
        if let contoursObservation = contourRequest.results?.first {
            return contoursObservation.normalizedPath
        }
        
        return nil
    }
    
    func createRandomBubble(inside rect: CGRect, in size: CGSize) -> (position: CGPoint, radius: CGFloat, color: Color) {
        print("rect", rect)
        let radius = CGFloat.random(in: 5...15)
        let x = CGFloat.random(in: rect.minX...rect.maxX)
        let y = CGFloat.random(in: rect.minY...rect.maxY)
        let position = CGPoint(x: x, y: y)
        let color = colors.randomElement() ?? .yellow
        return (position, radius, color)
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
