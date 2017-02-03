//
//  TiledImageScrollView.swift
//  APROPLAN
//
//  Created by Maxime POUWELS on 13/09/16.
//  Copyright © 2016 Siclo. All rights reserved.
//

import UIKit

public protocol TiledImageScrollViewDelegate: class {
    func tiledImageScrollViewDidScrollOrZoom(_ tiledImageScrollView: TiledImageScrollView)
}

public class TiledImageScrollView: UIScrollView {
    
    private static let zoomStep: CGFloat = 2
    
    fileprivate var contentView: TiledImageContentView?
    fileprivate var currentBounds = CGSize.zero
    public private(set) var doubleTap: UITapGestureRecognizer!
    public private(set) var twoFingersTap: UITapGestureRecognizer!
    
    fileprivate weak var dataSource: TiledImageViewDataSource?
    public weak var tiledImageScrollViewDelegate: TiledImageScrollViewDelegate?
    
    public var visibleRect: CGRect {
        return convert(bounds, to: contentView)
    }
    public var maxContentOffset: CGPoint {
        guard let imageSize = dataSource?.imageSize else { return CGPoint.zero }
        return CGPoint(x: imageSize.width * self.maximumZoomScale, y: imageSize.height * self.maximumZoomScale)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        removeObserver(self, forKeyPath: "contentSize")
        removeObserver(self, forKeyPath: "bounds")
    }
    
    private func setup() {
        delegate = self
        
        doubleTap = UITapGestureRecognizer(target: self, action:#selector(TiledImageScrollView.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        twoFingersTap = UITapGestureRecognizer(target: self, action: #selector(TiledImageScrollView.handleTwoFingersTap(_:)))
        twoFingersTap.numberOfTouchesRequired = 2
        addGestureRecognizer(twoFingersTap)
        
        addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    }
    
    public func set(dataSource: TiledImageViewDataSource) {
        self.dataSource = dataSource
        contentView?.removeFromSuperview()
        
        let tiledImageView = TiledImageView()
        tiledImageView.set(dataSource: dataSource)
        contentView = TiledImageContentView(tiledImageView: tiledImageView, dataSource: dataSource)
        addSubview(contentView!)
        
        currentBounds = bounds.size
        contentSize = dataSource.imageSize
        setMaxMinZoomScalesForCurrentBounds()
        setZoomScale(minimumZoomScale, animated: false)
    }
    
    fileprivate func setMaxMinZoomScalesForCurrentBounds() {
        guard let dataSource = dataSource else {
            return
        }
        setNeedsLayout()
        layoutIfNeeded()
        let boundsSize = bounds.size
        
        let imageSize = dataSource.imageSize
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        var minScale = min(xScale, yScale)
        let maxScale = max(CGFloat(dataSource.zoomLevels), 3) * 0.6
        
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        
        if minimumZoomScale > zoomScale {
            setZoomScale(minimumZoomScale, animated: false)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" || keyPath == "bounds" {
            contentSizeOrBoundsDidChange()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func contentSizeOrBoundsDidChange() {
        if currentBounds != bounds.size {
            currentBounds = bounds.size
            setMaxMinZoomScalesForCurrentBounds()
        }
        let topX = max(-(contentSize.width - bounds.width)/2, 0)
        let topY = max(-(contentSize.height - bounds.height)/2, 0)
        contentView?.frame.origin = CGPoint(x: topX, y: topY)
    }
    
    func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if zoomScale >= maximumZoomScale {
            setZoomScale(minimumZoomScale, animated: false)
        } else {
            let tapCenter = gestureRecognizer.location(in: contentView)
            let newScale = min(zoomScale * TiledImageScrollView.zoomStep, maximumZoomScale)
            let maxZoomRect = rect(around: tapCenter, atZoomScale: newScale)
            zoom(to: maxZoomRect, animated: false)
        }
    }
    
    fileprivate func rect(around point: CGPoint, atZoomScale zoomScale: CGFloat) -> CGRect {
        let boundsSize = bounds.size
        let scaledBoundsSize = CGSize(width: boundsSize.width / zoomScale, height: boundsSize.height / zoomScale)
        let point = CGRect(x: point.x - scaledBoundsSize.width / 2, y: point.y - scaledBoundsSize.height / 2, width: scaledBoundsSize.width, height: scaledBoundsSize.height)
        return point
    }
    
    func handleTwoFingersTap(_ sender: AnyObject) {
        let newZoomScale: CGFloat
            
        if zoomScale == minimumZoomScale {
            newZoomScale = maximumZoomScale
        } else {
            let nextZoomScale = zoomScale/TiledImageScrollView.zoomStep
            newZoomScale = nextZoomScale < minimumZoomScale  ? minimumZoomScale : nextZoomScale
        }
        setZoomScale(newZoomScale, animated: false)
    }
    
    func updateContentOffset(withContentScale scale: CGPoint) {
        contentOffset = CGPoint(x: maxContentOffset.x * scale.x, y: maxContentOffset.y * scale.y)
    }
}

extension TiledImageScrollView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        tiledImageScrollViewDelegate?.tiledImageScrollViewDidScrollOrZoom(self)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tiledImageScrollViewDelegate?.tiledImageScrollViewDidScrollOrZoom(self)
    }
    
}