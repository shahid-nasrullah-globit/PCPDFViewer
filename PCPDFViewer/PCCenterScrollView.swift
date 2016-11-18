//
//  CenterScrollView.swift
//  PageCurl
//
//  Created by Saad on 14/11/16.
//  Copyright © 2016 SAS. All rights reserved.
//

import UIKit

public class PCCenterScrollView: UIScrollView {

    override public func layoutSubviews() {
        super.layoutSubviews()
        let contentSize = self.contentSize
        let scrollViewSize = self.bounds.size
        
        if contentSize.width < scrollViewSize.width {
            contentOffset.x = -(scrollViewSize.width - contentSize.width) / 2.0
        }
        if contentSize.height < scrollViewSize.height {
            contentOffset.y = -(scrollViewSize.height - contentSize.height) / 2.0
        }

        self.contentOffset = contentOffset
    }
    
//    override var contentOffset: CGPoint
//    {
//        set{
//            let contentSize = self.contentSize
//            let scrollViewSize = self.bounds.size
//            
//            if contentSize.width < scrollViewSize.width {
//                contentOffset.x = -(scrollViewSize.width - contentSize.width) / 2.0
//            }
//            if contentSize.height < scrollViewSize.height {
//                contentOffset.y = -(scrollViewSize.height - contentSize.height) / 2.0
//            }
//            
//            super.contentOffset = contentOffset
//        }
//        get{
//            return contentOffset
//        }
//    }

}
