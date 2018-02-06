//
//  FilesViewController.swift
//  ToolKitUI
//
//  Created by KIEU, HAI on 1/29/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit
import ToolKit

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
    
    var currentPathUrl : URL!
    var selectedFileInfo : FileInfo!
    lazy var fileInfos : [FileInfo] = {
        return FileManager.default.getContents(currentPathUrl)
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if currentPathUrl == nil { currentPathUrl = FileManager.default.rootPathUrl }
        
        title = currentPathUrl.lastPathComponent
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
    @IBAction func handleAddingAction(_ sender: Any) {

        let actionVC = UIAlertController.init(title: "Please choose an action", message: nil, preferredStyle: .actionSheet)
        
        actionVC.addAction(UIAlertAction.init(title: "Add File", style: .default, handler: { (action) in
            self.presentInput(title: "Enter file name", actionText: "Add", cancelText: "Cancel", completion: { [weak self] (confirm, input) in
                guard confirm, let input = input else { return }
                self?.addFile(input)
            })
        }))
        actionVC.addAction(UIAlertAction.init(title: "Add Folder", style: .default, handler: { (action) in
            self.presentInput(title: "Enter folder name", actionText: "Add", cancelText: "Cancel", completion: { [weak self] (confirm, input) in
                guard confirm, let input = input else { return }
                self?.addFolder(input)
            })
        }))
        
        actionVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            //Might do something
        }))
        present(actionVC, animated: true, completion: nil)
    }
    
    func addFile(_ fileName: String) {
        guard FileManager.default.createFile(atPath: currentPathUrl.appendingPathComponent(fileName).absoluteString, contents: nil, attributes: nil) else {
            return
        }
        //TODO: Create file success
        reloadData()
    }
    
    func addFolder(_ dirName: String) {
        do {
            try FileManager.default.createDirectory(at: currentPathUrl.appendingPathComponent(dirName), withIntermediateDirectories: true, attributes: nil)
            //TODO: Create dir success
        } catch let error {
            //TODO: handle issue
        }
        
        reloadData()
    }
    
    func reloadData() {
        fileInfos = FileManager.default.getContents(currentPathUrl)
        collectionView.reloadData()
    }
}

extension FilesViewController : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard indexPath.item >= 0, indexPath.item < fileInfos.count else { return }
        
        selectedFileInfo = fileInfos[indexPath.item]
        
        if selectedFileInfo.isFolder == true, let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilesViewController") as? FilesViewController {
            vc.currentPathUrl = selectedFileInfo.url
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
}

extension FilesViewController : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileInfos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.item >= 0, indexPath.item < fileInfos.count else { return UICollectionViewCell() }
        
        let fileInfo = fileInfos[indexPath.item]
        
        let cell : FileCell!
        if fileInfo.isFolder {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as! FileCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as! FileCell
        }
        cell.nameLabel.text = fileInfo.name
        
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
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.sizeToFit()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
    }
}

open class FileInfo {
    var url : URL
    lazy var name : String = { return url.lastPathComponent }()
    lazy var isFolder : Bool = { return url.hasDirectoryPath }()
//    var isDir : Bool
    var isExisting : Bool { return FileManager.default.checkExisting(self)}
    
    
    init(_ url: URL) {
        self.url = url
    }
    
    
}

extension FileManager {
    
    var rootPathUrl : URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return URL(fileURLWithPath: documentsPath!, isDirectory: true)
    }
    
    func checkExisting(_ pathUrl: URL) -> Bool {
        var isDir : ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: pathUrl.relativePath, isDirectory: &isDir)
        if isExist && isDir.boolValue == true {
            print("dm >>> Found dir \(pathUrl.relativePath)")
            return true
        } else {
            print("dm >>> Not found dir \(pathUrl.relativePath)")
            return false
        }
    }
    
    func checkExisting(_ file: FileInfo) -> Bool {
        return checkExisting(file.url)
    }
    
    private func createDirIfNeeded(_ pathUrl: URL) {
        guard checkExisting(pathUrl) == false else { return }
        do {
            try FileManager.default.createDirectory(atPath: pathUrl.relativePath, withIntermediateDirectories: true, attributes: [:])
            print("dm >>> Creare dir \(pathUrl.relativePath)")
        } catch {
            print("dm >>> Error when create dir \(pathUrl.relativePath)")
        }
    }
    
    func rename(_ pathUrl: URL, newName: String, completion: ((Bool)->Void)? = nil) {
        guard pathUrl.isFileURL else { print("url not valid with \(pathUrl)"); return }
        
        let newDirPath = URL(fileURLWithPath: pathUrl.relativePath).deletingLastPathComponent().appendingPathComponent(newName, isDirectory: true)
        
        writingQueue.addOperation {
            do {
                try FileManager.default.moveItem(at: pathUrl, to: newDirPath)
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
    
    func getRootContents() -> [FileInfo] {
        return getContents(rootPathUrl)
    }
    
    ///dirOnly = true mean get dir URls, otherwise get file Urls
    func getContents(_ pathUrl: URL, dirOnly: Bool = false) -> [FileInfo] {
        
        do {
            let properties : [URLResourceKey]? = dirOnly ? [.isDirectoryKey, .totalFileSizeKey] : [.fileSizeKey]
            let urls = try FileManager.default.contentsOfDirectory(at: pathUrl, includingPropertiesForKeys: properties, options: [.skipsHiddenFiles])
            
            var files = [FileInfo]()
            for url in urls {
                files.append(FileInfo.init(url))
            }
            return files
            
        } catch {
            print("dm >>> Error when count files / dirs")
        }
        return []
    }
    
    
    func getAttrs(_ pathUrl: URL) -> [FileAttributeKey:Any] {
        do {
            return try FileManager.default.attributesOfItem(atPath: pathUrl.relativePath)
        } catch {
            print("fm >>> cannot get attributes at path \(pathUrl.relativePath)")
        }
        return [:]
    }
}
