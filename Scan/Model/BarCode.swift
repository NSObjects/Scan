//
//  BarCode.swift
//  Scan
//
//  Created by 林涛 on 16/8/29.
//  Copyright © 2016年 林涛. All rights reserved.
//

import UIKit
import AVFoundation

class BarCode: NSObject {
    var barcodeType:NSString?
    var barcodeData:String?
    var cornersPath:UIBezierPath?
    var boundingBoxPath:UIBezierPath?
    var metadataObject:AVMetadataMachineReadableCodeObject?
    
    init(Qcode code:AVMetadataMachineReadableCodeObject) {
        self.barcodeType = code.type
        self.barcodeData = code.stringValue
        self.metadataObject = code
    }
}
