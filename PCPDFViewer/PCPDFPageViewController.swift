//
//  TempViewController.swift
//  PageCurl
//
//  Created by Saad on 14/11/16.
//  Copyright © 2016 SAS. All rights reserved.
//

import UIKit

public protocol TempViewControllerDelegate : NSObjectProtocol {
    func singleTapped(sender : UIViewController)
}

public class PCPDFPageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var pdfDocument : CGPDFDocument!
    var pageNo : Int! = 0
    weak var delegate : TempViewControllerDelegate!

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.reloadPage()
        self.addTapGestures()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
    }
    
    func reloadPage() {
        let image = drawPDFfromURL(page: pageNo+1)
        if let img = image {
            self.imageView.image = img
            
            self.scrollView.zoomScale = 1
            var frame = imageView.frame
            frame.size = (image?.size)!
            imageView.frame = frame
            self.scrollView.contentSize = (image?.size)!
            self.updateZoom()
        }
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func updateZoom(){
        let scale = min(self.scrollView.bounds.size.width / (self.imageView.image?.size.width)!, self.scrollView.bounds.size.height / (self.imageView.image?.size.height)!)
        
        print("Calculated scale \(scale)")
        if scale < self.scrollView.minimumZoomScale {
            self.scrollView.minimumZoomScale = scale
        }
        self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
        
        print("Actual scale \(self.scrollView.zoomScale)")
        //print("Minimun Zoom Level \(self.scrollView.minimumZoomScale)")
    }
    
    func drawPDFfromURL(page: Int) -> UIImage? {
        guard let page = pdfDocument.page(at: page) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            
            ctx.cgContext.drawPDFPage(page);
        }
        return img
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PCPDFPageViewController {
    func addTapGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PCPDFPageViewController.singleTaped(gesture:)));
        self.view.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(PCPDFPageViewController.doubleTaped(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        tapGesture.require(toFail: doubleTapGesture)
        
    }
    
    func doubleTaped(gesture : UITapGestureRecognizer){
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
        else{
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func singleTaped(gesture: UITapGestureRecognizer){
        
        if let _ = delegate {
            delegate.singleTapped(sender: self)
        }
    }
}

extension PCPDFPageViewController : UIScrollViewDelegate
{
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
