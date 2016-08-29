//
//  ScanViewController.swift
//  Scan
//
//  Created by 林涛 on 16/8/29.
//  Copyright © 2016年 林涛. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

class ScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    var session = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var dispatchQueue = dispatch_queue_create("myQueue", nil)
    var barcode:BarCode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readQRcode()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            barcode = BarCode(Qcode: metadataObject)
        }
        dispatch_async(dispatchQueue, { () -> Void in
            if self.barcode?.barcodeType == AVMetadataObjectTypeQRCode {
                self.stopReding()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.previewLayer?.transformedMetadataObjectForMetadataObject(self.barcode?.metadataObject)
                    
                    if let codeData = self.barcode?.barcodeData   {
                        if let URL = NSURL(string: codeData) {
                            if #available(iOS 9, *) {
                                let safariViewControll = SFSafariViewController(URL: URL)
                                self.presentViewController(safariViewControll, animated: true, completion: nil)
                            } else {
                                UIApplication.sharedApplication().openURL(URL)
                            }
                        }
                        
                    }
                })
                
            }
        })
    }

}


private extension ScanViewController {
    func readQRcode() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            let input  = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch  {
            
        }
        
        let output = AVCaptureMetadataOutput()
        
        output.setMetadataObjectsDelegate(self, queue: self.dispatchQueue)
        
        
        session.addOutput(output)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code]
        
        let preview:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspect;
        preview.frame = self.view.bounds
        
        view.layer.insertSublayer(preview, atIndex: 0)
        previewLayer = preview
        session.startRunning()
    }
    
    func stopReding() {
        session.stopRunning()
        if let preview =  previewLayer {
            preview.removeFromSuperlayer()
        }
    }
    
    func openTorch()  {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if device.hasTorch {
            try! device.lockForConfiguration()
            device.torchMode = device.torchMode == .On ? .Off : .On
            device.unlockForConfiguration()
        }
    }
}