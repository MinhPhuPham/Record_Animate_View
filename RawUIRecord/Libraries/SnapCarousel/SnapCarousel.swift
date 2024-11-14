//
//  SnapCarousel.swift
//
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

public struct SnapCarousel<Data, ID, Content>: View where Data: RandomAccessCollection, ID: Hashable, Content: View {
    
    @StateObject private var viewModel: SnapCarouselViewModel<Data, ID>
    private let content: (Data.Element) -> Content
    
    public var body: some View {
        ZStack(alignment: viewModel.pageIndicatorConfig.placement) {
            GeometryReader { proxy -> AnyView in
                viewModel.viewSize = proxy.size
                return AnyView(generateContent(proxy: proxy))
            }.clipped()
            
            SnapCarouselPageIndicatorView(
                selectedIndex: $viewModel.activeIndex,
                pageCount: viewModel.data.count,
                config: viewModel.pageIndicatorConfig
            )
        }
    }
    
    @ViewBuilder
    private func generateContent(proxy: GeometryProxy) -> some View {
        HStack(spacing: viewModel.spacing) {
            ForEach(viewModel.data, id: viewModel.dataId) {
                content($0)
                    .frame(width: viewModel.itemWidth)
                    .scaleEffect(x: 1, y: viewModel.itemScaling($0), anchor: viewModel.anchorAnimateItem)
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
        .offset(x: viewModel.offset)
        .gesture(viewModel.tapGesture)
        .animation(viewModel.offsetAnimation, value: viewModel.offset)
        .onReceiveTimerListener(timer: viewModel.timer, perform: viewModel.receiveTimer)
        .onReceiveAppLifeCycle(perform: viewModel.setTimerActive)
        .overlay(
            SnapCarouselToggleAutoScroll(
                autoScrollState: Binding<SnapCarouselAutoScrollState>(get: { viewModel.autoScrollCarouselState }, set: {_ in}),
                controllOffsetY: viewModel.controlButtonOffetY,
                onClickIcon: viewModel.handleAutoScrollState
            )
        )
    }
}

// MARK: - Initializers
extension SnapCarousel {
    
    /// Initializers
    /// - Parameters:
    ///   - data: Data
    ///   - id: ID
    ///   - index: active subview, default 0
    ///   - config: config for snap view
    ///   - content: Content
    init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        index: Binding<Int> = .constant(0),
        config: SnapCarouselConfigure = .init(),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self._viewModel = StateObject(wrappedValue: SnapCarouselViewModel(
            data, id: id, index: index, config: config
        ))
        self.content = content
    }
}

extension SnapCarousel where ID == Data.Element.ID, Data.Element: Identifiable {
    
    /// Initializers
    /// - Parameters:
    ///   - data: Data
    ///   - index: active subview, default 0
    ///   - config: config for snap view
    ///   - content: Content
    init(
        _ data: Data,
        index: Binding<Int> = .constant(0),
        config: SnapCarouselConfigure = .init(),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self._viewModel = StateObject(wrappedValue: SnapCarouselViewModel(
            data, index: index, config: config
        ))
        self.content = content
    }
}