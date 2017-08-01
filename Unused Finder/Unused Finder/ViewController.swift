//
//  ViewController.swift
//  Unused Finder
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 24/07/17.
//  Copyright © 2017 iOS Wizards. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var findButton: NSButton!
    
    var loadUrlFile: URL!
    
//    let animationView = LOTAnimationView(name: "progress_bar")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        animationView.loopAnimation = true
//        animationView.frame = self.view.frame
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func chooseTapped(_ sender: NSButton) {
        
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                self.loadUrlFile = panel.urls[0]
            }
        }
        
    }
    
    @IBAction func findTapped(_ sender: NSButton) {
        if self.loadUrlFile != nil {
            findButton.isEnabled = false
//            view.addSubview(animationView)
//            animationView.play()
            
            Finder().find(with: self.loadUrlFile, completion: { (foundObject) in
                print(foundObject.swiftUrls.count)
                print(foundObject.ibUrls.count)
                
//                self.animationView.pause()
//                self.animationView.removeFromSuperview()
                self.findButton.isEnabled = true
            })
            
        }
    }
    


}
