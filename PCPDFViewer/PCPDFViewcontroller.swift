//
//  ViewController.swift
//  PageCurl
//
//  Created by Saad on 14/11/16.
//  Copyright © 2016 SAS. All rights reserved.
//

import UIKit

public class PCPDFViewcontroller: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    fileprivate var controllers = [UIViewController]()
    fileprivate var document : CGPDFDocument!
    fileprivate var currentPage : Int = 0
    fileprivate var totalPages : Int = 0
    
    public var pdfTitle : String!
    public var pdfPath : String!
    
    var btnPrev: UIBarButtonItem!
    var btnNext: UIBarButtonItem!
    var btnCount: UIBarButtonItem!
    
    fileprivate var reuseableViewsCount : Int = 3
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if pdfTitle != nil {
            self.title = pdfTitle
        }
        
        self.view.backgroundColor = UIColor.white
        
        guard (pdfPath) != nil else {
            return
        }
        
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        let url = NSURL(fileURLWithPath: pdfPath)
        document = CGPDFDocument(url as CFURL)
        
        totalPages = document.numberOfPages
        currentPage = 0
        
        self.delegate = self
        self.dataSource = self
        
        self.createPages()
        self.createNavigationButtons()
        
        self.removeSingleTabToFlipGesture()
        self.enableNextPrevButtons()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPages(){
        reuseableViewsCount = min(document.numberOfPages, reuseableViewsCount)
        
        let bundle = Bundle.init(for: type(of: self))
        let storyBoard = UIStoryboard(name: "PageCurl", bundle: bundle)
        
        for pageNo in 0..<reuseableViewsCount {
            let controller = storyBoard.instantiateInitialViewController() as! PCPDFPageViewController
            controller.pdfDocument = document
            controller.pageNo = pageNo
            controller.delegate = self
            controller.loadViewIfNeeded()
            controllers.append(controller)
        }
        self.setViewControllers([(controllers[0])], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    
    // MARK: Overridden Methods
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentPage <= 0 {
            return nil
        }
        
        if let index = controllers.index(of: viewController) {
            let prevIndex = self.getPreviousIndex(index: index)
            return controllers[prevIndex]
        }
        
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentPage >= (totalPages - 1) {
            return nil
        }
        
        if let index = controllers.index(of: viewController) {
            let nextIndex = self.getNextIndex(index: index)
            return controllers[nextIndex]
        }
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            
            let currentViewController = self.viewControllers?.first as! PCPDFPageViewController!
            let previousViewController = previousViewControllers.first as! PCPDFPageViewController!
            
            self.pageChanged(currentViewController: currentViewController!, previousViewController: previousViewController!)
            self.enableNextPrevButtons()
        }
    }
    
}

// Drawing PDF Methods
extension PCPDFViewcontroller {
    func pageChanged(currentViewController : PCPDFPageViewController, previousViewController : PCPDFPageViewController){
        self.updateCurrentPage(currentViewController: currentViewController, previousViewController: previousViewController)
        
        // Reload all pages
        if reuseableViewsCount >= 3 {
            let currentIndex = controllers.index(of: currentViewController)
            // Reload Next Page
            if currentPage+1 < totalPages {
                self.reloadViewAtIndex(index: self.getNextIndex(index: currentIndex!), withPageDataAtIndex: currentPage+1)
            }
            // Reload Previous Page
            if currentPage-1 >= 0 {
                self.reloadViewAtIndex(index: self.getPreviousIndex(index: currentIndex!), withPageDataAtIndex: currentPage-1)
            }
        }
    }
    
    func updateCurrentPage(currentViewController : PCPDFPageViewController, previousViewController : PCPDFPageViewController){
        
        let currentIndex = controllers.index(of: currentViewController)
        let previousIndex = controllers.index(of: previousViewController)
        
        if currentIndex != nil && currentIndex != nil {
            if self.getNextIndex(index: currentIndex!) == previousIndex {
                // Moved backword
                currentPage = currentPage - 1
            }
            else{
                // Moved Forword
                currentPage = currentPage + 1
            }
        }
    }
    
    func reloadViewAtIndex(index : Int,withPageDataAtIndex pageNo : Int){
        let viewController = controllers[index] as! PCPDFPageViewController
        viewController.pageNo = pageNo
        viewController.reloadPage()
    }
    
    func getNextIndex(index : Int) -> Int{
        var newIndex = index+1
        if newIndex == reuseableViewsCount {
            newIndex = 0
        }
        return newIndex
    }
    
    func getPreviousIndex(index : Int) -> Int {
        var newIndex = index-1
        if newIndex < 0 {
            newIndex = reuseableViewsCount-1
        }
        return newIndex
    }
}


// Gesture Methods
extension PCPDFViewcontroller{
    func removeSingleTabToFlipGesture(){
        // Find tap gestures
        var tapRecognizers = [UIGestureRecognizer]()
        for gesture : UIGestureRecognizer in self.gestureRecognizers {
            if gesture.isKind(of: UITapGestureRecognizer.self) {
                tapRecognizers.append(gesture)
            }
        }
        // Remove all tap gestures
        for gesture : UIGestureRecognizer in tapRecognizers {
            self.view .removeGestureRecognizer(gesture)
        }
    }
}


// Toolbar Navigation Methods
extension PCPDFViewcontroller {
    
    func createNavigationButtons(){
        
        let flexSpaceLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let flexSpaceRight = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        btnNext = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(PCPDFViewcontroller.goNext(_:)));
        btnPrev = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(PCPDFViewcontroller.goPrevious(_:)));
        
        btnCount = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: nil);
        btnCount.tintColor = UIColor.black
        
        self.toolbarItems = [flexSpaceLeft, btnPrev, btnCount, btnNext, flexSpaceRight]
        
    }
    
    @IBAction func goNext(_ sender: AnyObject) {
        let previousController = viewControllers?.first as! PCPDFPageViewController!
        if let index = controllers.index(of: previousController!) {
            let nextIndex = self.getNextIndex(index: index)
            let currentController = controllers[nextIndex] as! PCPDFPageViewController
            currentController.reloadPage()
            self.dissableAllButtons()
            setViewControllers([currentController], direction: .forward, animated: true, completion: { (finished : Bool) in
                if finished {
                    self.enableNextPrevButtons()
                }
            })
            pageChanged(currentViewController: currentController, previousViewController: previousController!)
        }
    }
    @IBAction func goPrevious(_ sender: AnyObject) {
        let previousController = viewControllers?.first as! PCPDFPageViewController!
        if let index = controllers.index(of: previousController!) {
            let prevIndex = self.getPreviousIndex(index: index)
            let currentController = controllers[prevIndex] as! PCPDFPageViewController
            currentController.reloadPage()
            self.dissableAllButtons()
            setViewControllers([currentController], direction: .reverse, animated: true, completion: { (finished : Bool) in
                if finished {
                    self.enableNextPrevButtons()
                }
            })
            pageChanged(currentViewController: currentController, previousViewController: previousController!)
        }
    }
    
    func dissableAllButtons(){
        btnPrev.isEnabled = false
        btnNext.isEnabled = false
    }
    
    func enableNextPrevButtons(){
        btnPrev.isEnabled = true
        btnNext.isEnabled = true
        if currentPage == 0 {
            btnPrev.isEnabled = false
        }
        else if currentPage == totalPages - 1 {
            btnNext.isEnabled = false
        }
        self.btnCount.title = "\(currentPage+1) of \(totalPages)"
    }
}

extension PCPDFViewcontroller : TempViewControllerDelegate {
    public func singleTapped(sender: UIViewController) {
        if let navigation = self.navigationController {
            navigation.setNavigationBarHidden(!navigation.navigationBar.isHidden, animated: true)
            navigation.setToolbarHidden(!navigation.toolbar.isHidden, animated: true)
        }
    }
}

