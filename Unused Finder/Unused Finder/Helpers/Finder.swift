//
//  Finder.swift
//  Unused Finder
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/17.
//  Copyright © 2017 iOS Wizards. All rights reserved.
//

import Foundation

struct Found {
    var swiftUrls: [URL]! = []
    var ibUrls: [URL]! = []
}

class Finder: NSObject {
    
    private var swiftUrls: [URL]! = []
    private var ibUrls: [URL]! = []
    
    private var names: [String] = []
    private var nonUsed: [String] = []
    
    func find(with url: URL, completion:@escaping (Found) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.swiftUrls = []
            self.ibUrls = []
            self.names = []
            self.nonUsed = []
            
            self.findAllFiles(with: url)
            
            // print swift code files
            print("count - \(self.swiftUrls)")
            print("count - \(self.swiftUrls.count)")
            
            for url in self.swiftUrls {
                do {
                    let text = try String(contentsOf: url, encoding: String.Encoding.utf8)
                    if let text = text.slice(from: "struct ", to: "{") {
                        self.addName(from: text)
                    } else if let text = text.slice(from: "class ", to: "{") {
                        self.addName(from: text)
                    }
//                    print(text)
                } catch let errOpening as NSError {
                    print("Error! ", errOpening)
                }
            }
            
            // print interface builder files
            print("count - \(self.ibUrls)")
            print("count - \(self.ibUrls.count)")
            
            
            for url in self.ibUrls {
                self.findNonUsed(withFile: url)
            }
            
            for url in self.swiftUrls {
                self.findNonUsed(withFile: url)
            }
            
            print(self.nonUsed)
            
            // back to main thread and stop the animation
            DispatchQueue.main.async {
                completion(Found(swiftUrls: self.swiftUrls, ibUrls: self.ibUrls))
            }
        }
        
    }
    
}


// MARK: - File manager

extension Finder {
    
    private func contentsOf(folder: URL) -> [URL] {
        
        let fileManager = FileManager.default
        
        do {
//            let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
            
            let directoryContents = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            
            //            let urls = contents.map {
            //                return folder.appendingPathComponent($0)
            //            }
            return directoryContents
        } catch {
            return []
        }
    }
    
    
    private func findAllFiles(with url: URL) {
        
        var paths = self.contentsOf(folder: url).enumerated().reversed()
        
        for obj in paths {
            if obj.element.pathExtension == "" || obj.element.pathExtension == "lproj" {
                // call again, because it found a folder
                self.findAllFiles(with: obj.element)
            } else if obj.element.absoluteString.localizedCaseInsensitiveContains("pods") || obj.element.absoluteString.localizedCaseInsensitiveContains("test") {
                paths.remove(at: obj.offset)
            } else {
                if obj.element.pathExtension == "swift" {
                    swiftUrls.append(obj.element)
                } else if obj.element.pathExtension == "xib" || obj.element.pathExtension == "storyboard" || obj.element.pathExtension == "plist" {
                    // search for resource files
                    ibUrls.append(obj.element)
                }
                paths.remove(at: obj.offset)
            }
            
        }
        
    }
}

// MARK:- Helpers

extension Finder {
    private func textIsValid(_ text: String) -> Bool {
        if !text.contains("(") && !text.contains("@") && !text.contains(" var ") && !text.contains("//") {
            return true
        }
        return false
    }
    
    private func addName(from text: String) {
        if textIsValid(text) {
            if let filtered = text.slice(from: " ", to: ":") {
                print(filtered.replacingOccurrences(of: " ", with: ""))
                self.names.append(filtered.replacingOccurrences(of: " ", with: ""))
            } else if text.components(separatedBy: ":").count > 0 {
                print(text.components(separatedBy: ":")[0].replacingOccurrences(of: " ", with: ""))
                self.names.append(text.components(separatedBy: ":")[0].replacingOccurrences(of: " ", with: ""))
            } else {
                print(text.replacingOccurrences(of: " ", with: ""))
                self.names.append(text.replacingOccurrences(of: " ", with: ""))
            }
        }
    }
    
    private func findNonUsed(withFile url: URL) {
        do {
            let text = try String(contentsOf: url, encoding: String.Encoding.utf8)
            for name in self.names.enumerated().reversed() {
                if !url.absoluteString.contains(name.element) {
                    if !text.contains(name.element) {
                        if !self.nonUsed.contains(name.element) {
                            self.nonUsed.append(name.element)
                        }
                    } else {
                        if let index = self.nonUsed.index(of: name.element) {
                            self.nonUsed.remove(at: index)
                        }
                        self.names.remove(at: name.offset)
                    }
                }
            }
        } catch let errorOpen as NSError {
            
        }
    }
}
