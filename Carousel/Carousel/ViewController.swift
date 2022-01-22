//
//  ViewController.swift
//  Carousel
//
//  Created by 박상우 on 2022/01/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var previousCellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureCollectionViewLayout()
    }
    
    private func configureCollectionView() {
        self.collectionView.register(UINib(nibName: CollectionViewCell.identifier, bundle: nil),
                                     forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
    }
    
    private func configureCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellSize = view.bounds.width - 220
        let insetX = (view.bounds.width - cellSize) / 2.0
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: CollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.identifier, for: indexPath
        ) as? CollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
}

extension ViewController: UIScrollViewDelegate {
    // CollectionView cell scroll
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left,
                         y: scrollView.contentInset.top)

        targetContentOffset.pointee = offset
    }
    
    // scroll For cell Zooming
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludeSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = collectionView.contentOffset.x
        let index = (offsetX + collectionView.contentInset.left) / cellWidthIncludeSpacing
        let roundedIndex = round(index)
        let indexPath = IndexPath(item: Int(roundedIndex), section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) {
            zoomFocusCell(cell: cell, isFocus: true)
        }
        if Int(roundedIndex) != previousCellIndex {
            let preIndexPath = IndexPath(item: previousCellIndex, section: 0)
            if let preCell = collectionView.cellForItem(at: preIndexPath) {
                zoomFocusCell(cell: preCell, isFocus: false)
            }
            previousCellIndex = indexPath.item
        }
    }
}

extension ViewController {
    // Cell Zoom In, Out
    private func zoomFocusCell(cell: UICollectionViewCell, isFocus: Bool ) {
        UIView.animate( withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            if isFocus {
                cell.transform = .identity
            } else {
                cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }, completion: nil)
    }
}

