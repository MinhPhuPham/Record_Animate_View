//
//  SnapCarouselViewModel.swift
//
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI
import Combine

class SnapCarouselViewModel<Data, ID>: ObservableObject where Data : RandomAccessCollection, ID : Hashable {
    
    /// external index
    @Binding private var index: Int
    
    private let _data: Data
    private let _dataId: KeyPath<Data.Element, ID>
    private let _config: SnapCarouselConfigure
    
    init(_ data: Data,
         id: KeyPath<Data.Element, ID>,
         index: Binding<Int>,
         config: SnapCarouselConfigure = .init()
    ) {
        
        guard index.wrappedValue < data.count else {
            fatalError("The index should be less than the count of data ")
        }
        
        self._data = data
        self._dataId = id
        self._config = config
        
        if data.count > 1 && _config.isWrap {
            activeIndex = index.wrappedValue + 1
        } else {
            activeIndex = index.wrappedValue
        }
        
        self._index = index
    }
    
    
    /// The index of the currently active subview.
    @Published var activeIndex: Int = 0 {
        willSet {
            if isWrap {
                if newValue > _data.count || newValue == 0 {
                    return
                }
                index = newValue - 1
            } else {
                index = newValue
            }
        }
        didSet {
            changeOffset()
        }
    }
    
    /// Offset x of the view drag.
    @Published var dragOffset: CGFloat = .zero
    
    /// size of GeometryProxy
    var viewSize: CGSize = .zero
    
    /// carousel state for toggle auto scroll
    @Published var autoScrollCarouselState: SnapCarouselAutoScrollState = .unset
    
    /// Counting of time
    /// work when `isTimerActive` is true
    /// Toggles the active subviewview and resets if the count is the same as
    /// the duration of the auto scroll. Otherwise, increment one
    private var timing: TimeInterval = 0
    
    /// Define listen to the timer
    /// Ignores listen while dragging, and listen again after the drag is over
    /// Ignores listen when App will resign active, and listen again when it become active
    private var isTimerActive = true
    
    /// Is animated when view is in offset
    private var isAnimatedOffset: Bool = true
    
    func setCarouselState(_ state: SnapCarouselAutoScrollState) {
        if autoScrollCarouselState == state { return }
        
        autoScrollCarouselState = state
    }
    
    func setTimerActive(_ active: Bool) {
        if _config.autoScroll.isActiveOneTime && active && autoScrollCarouselState == .resetOneTime { return }
        
        isTimerActive = active
    }
    
    func handleAutoScrollState() {
        switch autoScrollCarouselState {
        case .active, .unset:
            setCarouselState(.temporaryDeactive)
            setTimerActive(false)
        case .temporaryDeactive:
            setCarouselState(.active)
            setTimerActive(true)
        case .resetOneTime:
            activeIndex = 0
            setCarouselState(.active)
            setTimerActive(true)
        }
    }
}

// MARK: Super init
extension SnapCarouselViewModel where ID == Data.Element.ID, Data.Element : Identifiable {
    convenience init(
        _ data: Data,
        index: Binding<Int>,
        config: SnapCarouselConfigure
    ) {
        self.init(data, id: \.id, index: index, config: config)
    }
}

extension SnapCarouselViewModel {
    
    var data: Data {
        guard _data.count != 0 else {
            return _data
        }
        guard _data.count > 1 else {
            return _data
        }
        guard isWrap else {
            return _data
        }
        return [_data.last!] + _data + [_data.first!] as! Data
    }
    
    var dataId: KeyPath<Data.Element, ID> {
        return _dataId
    }
    
    var pageIndicatorConfig: SnapCarouselPageIndicatorConfig {
        return _config.pageIndicatorConfig
    }
    
    var anchorAnimateItem: UnitPoint {
        return _config.anchorAnimateItem
    }
    
    var spacing: CGFloat {
        return _config.spacing
    }
    
    var controlButtonOffetY: CGFloat {
        return _config.playControlOffetY
    }
    
    var offsetAnimation: Animation? {
        guard isWrap else {
            return .spring(duration: _config.animationDuration)
        }
        return isAnimatedOffset ? .spring(duration: _config.animationDuration) : .none
    }
    
    var itemWidth: CGFloat {
        return max(0, viewSize.width - defaultPadding * 2)
    }
    
    var timer: TimePublisher? {
        guard autoScroll.isActive else {
            return nil
        }
        return Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    /// Defines the scaling based on whether the item is currently active or not.
    /// - Parameter item: The incoming item
    /// - Returns: scaling
    func itemScaling(_ item: Data.Element) -> CGFloat {
        guard activeIndex < data.count else {
            return 0
        }
        let activeItem = data[activeIndex as! Data.Index]
        return activeItem[keyPath: _dataId] == item[keyPath: _dataId] ? 1 : sidesScaling
    }
}

// MARK: - private variable
extension SnapCarouselViewModel {
    
    private var isWrap: Bool {
        return _data.count > 1 ? _config.isWrap : false
    }
    
    private var autoScroll: SnapCarouselAutoScroll {
        guard _data.count > 1 else { return .inactive }

        return _config.autoScroll.interval > 0 ? _config.autoScroll : .defaultActive
    }
    
    private var defaultPadding: CGFloat {
        return (_config.headspace + spacing)
    }
    
    private var itemActualWidth: CGFloat {
        itemWidth + spacing
    }
    
    private var sidesScaling: CGFloat {
        return max(min(_config.sidesScaling, 1), 0)
    }
    
    private func setAnimatedOffset(_ isAnimate: Bool) {
        if isAnimatedOffset == isAnimate { return }
        
        self.isAnimatedOffset = isAnimate
    }
}

// MARK: - Offset Method
extension SnapCarouselViewModel {
    /// current offset value
    var offset: CGFloat {
        let activeOffset = CGFloat(activeIndex) * itemActualWidth
        return defaultPadding - activeOffset + dragOffset
    }
    
    /// change offset when acitveItem changes
    private func changeOffset() {
        self.setAnimatedOffset(true)
        
        guard isWrap else {
            return
        }
        
        let minimumOffset = defaultPadding
        let maxinumOffset = defaultPadding - CGFloat(data.count - 1) * itemActualWidth
        
        if offset == minimumOffset {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
                self?.activeIndex = max(0, (self?.data.count ?? 0) - 2)
                self?.setAnimatedOffset(false)
            }
        } else if offset == maxinumOffset {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
                self?.activeIndex = 1
                self?.setAnimatedOffset(false)
            }
        }
    }
}

// MARK: - Drag Gesture
extension SnapCarouselViewModel {
    var tapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded { [weak self] _ in
                if self?._config.autoScroll != .inactive {
                    self?.handleAutoScrollState()
                }
            }.exclusively(before: dragGesture)
    }
    
    /// drag gesture of view
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged(dragChanged)
            .onEnded(dragEnded)
    }
    
    private func dragChanged(_ value: DragGesture.Value) {
        guard _config.canMove else { return }
        
        self.setAnimatedOffset(true)
        
        /// Defines the maximum value of the drag
        /// Avoid dragging more than the values of multiple subviews at the end of the drag,
        /// and still only one subview is toggled
        var offset: CGFloat = itemActualWidth
        
        if value.translation.width > 0 {
            offset = min(offset, value.translation.width)
        } else {
            offset = max(-offset, value.translation.width)
        }
        
        /// check if have reset icon => remove it
        if _config.autoScroll.isActiveOneTime && autoScrollCarouselState == .resetOneTime {
            setCarouselState(.unset)
        }
        
        /// set drag offset
        dragOffset = offset
        
        /// stop active timer
        setTimerActive(false)
    }
    
    private func dragEnded(_ value: DragGesture.Value) {
        guard _config.canMove else { return }
        /// reset drag offset
        dragOffset = .zero
        
        /// reset timing and restart active timer
        resetTiming()
        setTimerActive(true)
        
        /// Defines the drag threshold
        /// At the end of the drag, if the drag value exceeds the drag threshold,
        /// the active view will be toggled
        /// default is one third of subview
        let dragThreshold: CGFloat = itemWidth / 4
        
        var activeIndex = self.activeIndex
        if value.translation.width > dragThreshold {
            activeIndex -= 1
        }
        if value.translation.width < -dragThreshold {
            activeIndex += 1
        }
        self.activeIndex = max(0, min(activeIndex, data.count - 1))
    }
}

// MARK: - Receive Timer
extension SnapCarouselViewModel {
    
    /// timer change
    func receiveTimer(_ value: Timer.TimerPublisher.Output) {
        /// Ignores listen when `isTimerActive` is false.
        guard isTimerActive else {
            return
        }
        /// increments of one and compare to the scrolling duration
        /// return when timing less than duration
        activeTiming()
        timing += 1
        
        if timing < autoScroll.interval {
            return
        }
        
        if activeIndex == data.count - 1 {
            // Case isShowOneTime
            if _config.autoScroll.isActiveOneTime {
                resetTiming()
                setTimerActive(false)
                setCarouselState(.resetOneTime)
                
                return
            }
            
            /// `isWrap` is false.
            /// Revert to the first view after scrolling to the last view
            activeIndex = 0
        } else {
            /// `isWrap` is true.
            /// Incremental, calculation of offset by `offsetChanged(_: proxy:)`
            activeIndex += 1
        }
        resetTiming()
    }
    
    
    /// reset counting of time
    private func resetTiming() {
        timing = 0
    }
    
    /// time increments of one
    private func activeTiming() {
        timing += 1
    }
}
