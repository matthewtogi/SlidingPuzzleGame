

import UIKit

class PuzzleCollectionViewController: UICollectionViewController {
    
    var puzzle = [ Puzzle(title: "Jennie", solvedImages: ["1a","1b","1c","2a","2b", "2c","3a","3b","3c"])]
    
    var index: Int = 0
    var gameTimer: Timer?
    var hintImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem?.isEnabled = false
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if index < puzzle.count {
            return puzzle[index].unsolvedImages.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        cell.puzzleImage.image = UIImage(named: puzzle[index].unsolvedImages[indexPath.item])
        return cell
    }
    
}

extension PuzzleCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 40, left: 15, bottom: 40, right: 15)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        var customCollectionWidth: CGFloat!
        customCollectionWidth = collectionViewWidth/3 - 10

        return CGSize(width: customCollectionWidth, height: customCollectionWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PuzzleCollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.puzzle[index].unsolvedImages[indexPath.item]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = dragItem
        return [dragItem]
    }
}

extension PuzzleCollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        if puzzle[index].unsolvedImages == puzzle[index].solvedImages {
            Alert.showSolvedPuzzleAlert(on: self)
            collectionView.dragInteractionEnabled = false
            if index == puzzle.count - 1 {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath:IndexPath, collectionView: UICollectionView) {
        
        if let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                puzzle[index].unsolvedImages.swapAt(sourceIndexPath.item, destinationIndexPath.item)
                collectionView.reloadItems(at: [sourceIndexPath,destinationIndexPath])
                
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
}
