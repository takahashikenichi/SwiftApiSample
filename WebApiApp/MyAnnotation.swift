//
//  MyAnnotation.swift
//  WebApiApp
//
//  Created by タカハシケンイチ on 2015/09/09.
//  Copyright (c) 2015年 Kenichi Takahashi. All rights reserved.
//

import Foundation

class MyAnnotation: NSObject, YMKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var annotationTitle: String!
    var annotationSubtitle: String!
    var annotationIndex: Int
    
    init(locationCoordinate: CLLocationCoordinate2D, title: String!, subtitle: String!, index: Int) {
        coordinate = locationCoordinate
        annotationTitle = title
        annotationSubtitle = subtitle
        annotationIndex = index
    }

    func title() -> String! {
        return annotationTitle
    }
    
    func subtitle() -> String! {
        return annotationSubtitle
    }
}