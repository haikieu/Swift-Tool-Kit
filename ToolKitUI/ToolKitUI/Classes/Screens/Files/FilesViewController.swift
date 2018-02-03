//
//  FilesViewController.swift
//  ToolKitUI
//
//  Created by KIEU, HAI on 1/29/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

class ExtendQueue : OperationQueue {
    override func addOperation(_ block: @escaping () -> Void) {
        print("queue >>> Current tasks in \(self.name ?? "Queue") is \(self.operationCount)")
        print("queue >>> \(self.name ?? "Queue") Gonna execute new task")
        super.addOperation(block)
    }
}

private let readingQueue : ExtendQueue = {
    let queue = ExtendQueue()
    queue.name = "ReadingQueue"
    return queue
}()
private let writingQueue : ExtendQueue = {
    let queue = ExtendQueue()
    queue.name = "WritingQueue"
    queue.maxConcurrentOperationCount = 1
    return queue
}()

private weak var mainQueue : OperationQueue! = OperationQueue.main


open class FilesViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var isDraggale = false {
        didSet {
            enableDragging()
        }
    }
    
    func enableDragging() {
        if longPressGesture != nil {
            return
        }
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}

extension FilesViewController : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilesViewController") else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FilesViewController : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath)
            return cell
        }
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath)
            return cell
        
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isDraggale
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }
    
}

open class FileCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var isDir : Bool!
}

open class FileInfo {
    var url : URL!
    lazy var name : String = { return url.lastPathComponent }()
    
}

extension FileManager {
    
    var rootDirPath : URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return URL(fileURLWithPath: documentsPath!, isDirectory: true)
    }
    
    func checkExisting(_ dirPath: URL) -> Bool {
        var isDir : ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: dirPath.relativePath, isDirectory: &isDir)
        if isExist && isDir.boolValue == true {
            print("dm >>> Found dir \(dirPath.relativePath)")
            return true
        } else {
            print("dm >>> Not found dir \(dirPath.relativePath)")
            return false
        }
    }
    
    func createDirIfNeeded(_ dirPath: URL) {
        guard checkExisting(dirPath) == false else { return }
        do {
            try FileManager.default.createDirectory(atPath: dirPath.relativePath, withIntermediateDirectories: true, attributes: [:])
            print("dm >>> Creare dir \(dirPath.relativePath)")
        } catch {
            print("dm >>> Error when create dir \(dirPath.relativePath)")
        }
    }
    
    func rename(_ dirPath: URL, newName: String, completion: ((Bool)->Void)? = nil) {
        guard dirPath.isFileURL else { print("url not valid with \(dirPath)"); return }
        
        let newDirPath = URL(fileURLWithPath: dirPath.relativePath).deletingLastPathComponent().appendingPathComponent(newName, isDirectory: true)
        
        writingQueue.addOperation {
            do {
                try FileManager.default.moveItem(at: dirPath, to: newDirPath)
                //                try FileManager.default.removeItem(at: dirPath)
            } catch {
                print("dm >>> rename is failed")
                completion?(false)
                return
            }
            print("dm >>> rename success to \(newDirPath.relativePath)")
            completion?(true)
        }
    }
    ///dirOnly = true mean get dir URls, otherwise get file Urls
    func getURLContents(_ dirPath: URL, dirOnly: Bool = true) -> [URL] {
        
        do {
            let properties : [URLResourceKey]? = dirOnly ? [.isDirectoryKey, .totalFileSizeKey] : [.fileSizeKey]
            let urls = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: properties, options: .skipsHiddenFiles)
            return urls
        } catch {
            print("dm >>> Error when count files / dirs")
        }
        return []
    }
}
